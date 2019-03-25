#import "FunctionalBootTests.h"
#import "parrotTests-Swift.h"

@implementation TestData
@end

NSArray<NSInvocation *> *_invocations;
NSMutableArray<TestData *> *testDataList;

@implementation FunctionalBootTests

+ (NSArray<NSInvocation *> *)testInvocations {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _invocations = [FunctionalBootTests createInvocations];
    });
    
    return _invocations;
}

+ (NSArray<NSInvocation *> *)createInvocations {
    NSMutableArray<NSInvocation *> *invocations = [[NSMutableArray alloc] init];
    testDataList = [[NSMutableArray alloc] init];
    
    NSArray<NSString *> *goodFeatures = [[NSBundle bundleForClass:[TestData class]] pathsForResourcesOfType:@"feature" inDirectory:@"good"];
    NSArray<NSString *> *badFeatures = [[NSBundle bundleForClass:[TestData class]] pathsForResourcesOfType:@"feature" inDirectory:@"bad"];

    [[goodFeatures arrayByAddingObjectsFromArray:badFeatures] enumerateObjectsUsingBlock:^(id file, NSUInteger idx, BOOL *stop) {
        NSString *filePath = (NSString *)file;
        NSString *extension = [[filePath pathExtension] lowercaseString];
        
        if ([extension isEqualToString:@"feature"]) {
            TestData *testData = [[TestData alloc] init];
            testData.featurePath = filePath;
            testData.good = [filePath containsString:@"good"];
            
            [testDataList addObject:testData];
        }
    }];
    
    NSMutableArray<NSString *> *selectors = [NSMutableArray new];
    
    for (NSInteger i = 0; i < testDataList.count; i++) {
        TestData *testData = testDataList[i];
        SEL selector = [FunctionalBootTests addInstanceMethodForTest:testData classSelectorNames:selectors];
        NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = self;
        invocation.selector = selector;
        [invocation setArgument:&i atIndex:2];
        [invocation retainArguments];
        
        [invocations addObject:invocation];
    }
    
    return invocations;
}

+ (SEL)addInstanceMethodForTest:(TestData *)testData classSelectorNames:(NSMutableArray<NSString*> *)selectorNames {
    IMP implementation = imp_implementationWithBlock(^(id _self, NSUInteger testIndex) {
        TestData *testData = testDataList[testIndex];
        
        if (testData.good) {
            [[AcceptanceTests new] parseGoodWithFeature:testData.featurePath];
        } else {
            [[AcceptanceTests new] parseBadWithFeature:testData.featurePath];
        }
    });
    
    const char *types = [[NSString stringWithFormat:@"v@:%s", @encode(NSUInteger)] UTF8String];
    
    NSString *originalName = testData.featurePath.lastPathComponent.c99ExtendedIdentifier;
    NSString *selectorName = originalName;
    
    NSUInteger i = 2;
    
    while ([selectorNames containsObject:selectorName]) {
        selectorName = [NSString stringWithFormat:@"%@_%tu", originalName, i++];
    }
    
    [selectorNames addObject:selectorName];
    
    SEL selector = NSSelectorFromString(selectorName);
    class_addMethod([self class], selector, implementation, types);

    return selector;
}

@end
