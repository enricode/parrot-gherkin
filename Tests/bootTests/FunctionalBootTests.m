#import "FunctionalBootTests.h"

@implementation TestData
@end

NSArray<NSInvocation *> *_invocations;
NSString * const FEATURE_DIR_ENVIRONMENT_KEY = @"feature_dir";


@implementation FunctionalBootTests

+ (NSArray<NSInvocation *> *)testInvocations {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _invocations = [FunctionalBootTests createInvocations];
    });
    
    NSAssert(_invocations.count != 0, @"You must pass `%@` environment variable with feature directory path.", FEATURE_DIR_ENVIRONMENT_KEY);
    
    return _invocations;
}

+ (NSArray<NSInvocation *> *)createInvocations {
    NSString *featureDir = [NSProcessInfo.processInfo.environment objectForKey:FEATURE_DIR_ENVIRONMENT_KEY];
    
    if (featureDir == nil) {
        return @[];
    }
    
    NSArray *featureDirectoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:featureDir error:NULL];
    
    NSMutableArray<NSInvocation *> *invocations = [[NSMutableArray alloc] init];
    NSMutableArray<TestData *> *tests = [[NSMutableArray alloc] init];

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
