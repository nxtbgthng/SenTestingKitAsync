//
//  DemoClient.m
//  DemoClient
//
//  Created by Tobias Kräntzer on 10.04.13.
//  Copyright (c) 2013 nxtbgthng GmbH. All rights reserved.
//

#import "DemoClient.h"

@implementation DemoClient

- (void)connect
{
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSString *password = [self.delegate passwordForClient:self];
        
        if ([password isEqualToString:@"test"]) {
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.delegate clientDidConnect:self];
            });
        } else {
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                NSError *error = [NSError errorWithDomain:@"DemoClientErrorDomain" code:10 userInfo:nil];
                [self.delegate client:self connectDidFailWithError:error];
            });
        }
    });
}

@end
