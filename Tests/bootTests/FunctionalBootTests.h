#import <XCTest/XCTest.h>
#import <objc/runtime.h>

@interface TestData : NSObject

extern NSString * const FEATURE_DIR_ENVIRONMENT_KEY;

@property(nonatomic, strong) NSString *featurePath;

@end

@interface FunctionalBootTests : XCTestCase

@end
