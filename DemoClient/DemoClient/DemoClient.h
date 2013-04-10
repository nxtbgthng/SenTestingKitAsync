//
//  DemoClient.h
//  DemoClient
//
//  Created by Tobias Kräntzer on 10.04.13.
//  Copyright (c) 2013 nxtbgthng GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DemoClient;

@protocol DemoClientDelegate <NSObject>
- (NSString *)passwordForClient:(DemoClient *)aClient;
- (void)clientDidConnect:(DemoClient *)aClient;
- (void)client:(DemoClient *)aClient connectDidFailWithError:(NSError *)error;
@end


@interface DemoClient : NSObject

@property (nonatomic, weak) id delegate;

- (void)connect;

@end
