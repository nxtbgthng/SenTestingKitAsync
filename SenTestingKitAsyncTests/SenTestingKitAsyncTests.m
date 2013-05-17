//
//  SenTestingKitAsyncTests.m
//  SenTestingKitAsyncTests
//
//  Created by Tobias Kräntzer on 07.01.13.
//  Copyright (c) 2013 nxtbgthng GmbH. All rights reserved.
//

#import <SenTestingKitAsync/SenTestingKitAsync.h>

#import "SenTestingKitAsyncTests.h"

@implementation SenTestingKitAsyncTests

- (void)setUpWithCompletionHandler:(void(^)())handler
{
    __unsafe_unretained SenTestingKitAsyncTests *weak = self;
    [super setUpWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.timestamp = [NSDate date];
            handler();
        });
    }];
}

- (void)tearDownWithCompletionHandler:(void (^)())handler
{
    [super tearDownWithCompletionHandler:^{
        handler();
    }];
}

#pragma mark Tests

- (void)testAsyncSetUp
{
    STAssertNotNil(self.timestamp, nil);
}

- (void)testExample;
{
    STFail(@"Normal test are working as expected.");
}

- (void)testExampleAsync;
{
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        STFail(@"But if your test methods ends with 'Async', you can do this!");
        STSuccess();
    });
}

- (void)testAfterAsync;
{
    STFailAfter(1, @"Timeout!");
}

- (void)testSelectorAsync;
{
    [self performSelector:@selector(mySelector) withObject:nil afterDelay:2.0];
}

- (void)mySelector;
{
    STSuccess();
}

- (void)testOtherSelectorAsync;
{
    [self performSelector:@selector(myOtherSelector:) withObject:@(2) afterDelay:2.0];
}

- (void)myOtherSelector:(NSNumber *)value;
{
    STAssertEqualObjects(value, @(3), @"Expecting the number '3'.");
}

- (void)testFailImmediatelyAsync
{
    STFail(@"Fail immediately.");
}

@end
