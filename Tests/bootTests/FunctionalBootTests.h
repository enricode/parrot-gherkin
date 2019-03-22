#import <XCTest/XCTest.h>
#import <objc/runtime.h>

@interface TestData : NSObject

@property(nonatomic, strong) NSString *featurePath;

@end

@interface FunctionalBootTests : XCTestCase

@end
