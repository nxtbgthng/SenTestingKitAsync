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

- (void)testExample;
{
    STFail(@"Normal test are working as expected.");
}

- (void)testExampleAsync;
{
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        STFail(@"But if your test methods ends with 'Async', you can do this!");
        STSuccess();
    });
}

//- (void)testAfterAsync;
//{
//    STFailAfter(5, @"Timeout!");
//}

@end
