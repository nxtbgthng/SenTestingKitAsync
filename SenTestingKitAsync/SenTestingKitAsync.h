//
//  SenTestingKitAsync.h
//  SenTestingKitAsync
//
//  Created by Tobias Kräntzer on 07.01.13.
//  Copyright (c) 2013 nxtbgthng GmbH. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#define STSuccess() [self failWithException:nil]


#define STFailAfter(timeout, description, ...) \
do { \
int64_t delayInSeconds = timeout; \
dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); \
dispatch_after(popTime, dispatch_get_main_queue(), ^(void){ \
[self failWithException:([NSException failureInFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:@"%@", STComposeString(description, ##__VA_ARGS__)])]; \
}); \
} while(0)

@interface SenTest (AsyncExtension)
- (void)setUpWithCompletionHandler:(void(^)())handler;
- (void)tearDownWithCompletionHandler:(void(^)())handler;
@end
