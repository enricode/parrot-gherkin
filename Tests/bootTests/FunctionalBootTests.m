#import "FunctionalBootTests.h"

@implementation TestData
@end

NSArray<NSInvocation *> *_invocations;

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
    NSMutableArray<TestData *> *tests = [[NSMutableArray alloc] init];
    
    NSArray<NSString *> *features = [[NSBundle bundleForClass:[TestData class]] pathsForResourcesOfType:@"feature" inDirectory:nil];

    [featureDirectoryContent enumerateObjectsUsingBlock:^(id file, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)file;
        NSString *extension = [[filename pathExtension] lowercaseString];
        
        if ([extension isEqualToString:@"feature"]) {
            TestData *testData = [[TestData alloc] init];
            testData.featurePath = [featureDir stringByAppendingPathComponent:filename];
            
            [tests addObject:testData];
        }
    }];
    
    NSMutableArray<NSString *> *selectors = [NSMutableArray new];
    
    for (TestData *testData in tests) {
        [FunctionalBootTests addInstanceMethodForTest:testData classSelectorNames:selectors];
    }
    
    for (NSString *selectorName in selectors) {
        SEL selector = NSSelectorFromString(selectorName);
        NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.selector = selector;
        
        [invocations addObject:invocation];
        break;
    }
    
    return invocations;
}

+ (void)addInstanceMethodForTest:(TestData *)testData classSelectorNames:(NSMutableArray<NSString*> *)selectorNames {
    /*
    IMP implementation = imp_implementationWithBlock(^(TestData *testData) {
        [[FunctionalTests new] parseGoodWithFeature:testData.featurePath];
    });
    
    const char *types = [[NSString stringWithFormat:@"%s%s%s", @encode(void), @encode(TestData), @encode(SEL)] UTF8String];
    
    NSString *originalName = testData.featurePath.c99ExtendedIdentifier;
    NSString *selectorName = originalName;
    
    NSUInteger i = 2;
    
    while ([selectorNames containsObject:selectorName]) {
        selectorName = [NSString stringWithFormat:@"%@_%tu", originalName, i++];
    }
    
    [selectorNames addObject:selectorName];
    
    SEL selector = NSSelectorFromString(selectorName);
    class_addMethod(self, selector, implementation, types);
    
    return selector;
     */
}

@end
