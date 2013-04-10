//
//  DemoClientTests.m
//  DemoClientTests
//
//  Created by Tobias Kräntzer on 10.04.13.
//  Copyright (c) 2013 nxtbgthng GmbH. All rights reserved.
//

#import <SenTestingKitAsync/SenTestingKitAsync.h>
#import <OCMock/OCMock.h>

#import "DemoClient.h"
#import "DemoClientTests.h"

@implementation DemoClientTests

- (void)testConnectAsync
{
    // Let the test fail if it didn't finished after 5 seconds.
    
    STFailAfter(5.0, @"Testing the client connection timed out.");
    
    
    // Create a mock object for the delegate of the client and keep a strong reference to it.
    // The strong reference is needed, because the test continues after leaving the scope of
    // this method. If there wouldn't bee a strong reference, the mock object would be
    // deallocated before the test finishes.
    
    OCMockObject *delegate = [OCMockObject niceMockForProtocol:@protocol(DemoClientDelegate)];
    self.delegate = delegate;
    
    
    // Stub the Protocol method to provide a password to the client
    
    [[[delegate stub] andReturn:@"test"] passwordForClient:OCMOCK_ANY];
    
    
    // Let the test fail, if the client could not connect
    
    [[[delegate stub] andDo:^(NSInvocation *invocation) {
        __unsafe_unretained NSError *error;
        [invocation getArgument:&error atIndex:3];
        STFail(@"Failed to connect with error: %@", [error localizedDescription]);
    }] client:OCMOCK_ANY connectDidFailWithError:OCMOCK_ANY];
    
    
    // Let the test succeed if the client could connect
    
    [[[delegate stub] andDo:^(NSInvocation *invocation) {
        STSuccess();
    }] clientDidConnect:OCMOCK_ANY];
    
    
    // Create an instance of the client and set the delegate
    
    DemoClient *client = [[DemoClient alloc] init];
    client.delegate = delegate;
    
    
    // Initiate the connection
    
    [client connect];
}

- (void)testConnectWithWrongPasswordAsync
{
    // Let the test fail if it didn't finished after 5 seconds.
    
    STFailAfter(5.0, @"Testing the client connection timed out.");
    
    
    // Create a mock object for the delegate of the client and keep a strong reference to it.
    // The strong reference is needed, because the test continues after leaving the scope of
    // this method. If there wouldn't bee a strong reference, the mock object would be
    // deallocated before the test finishes.
    
    OCMockObject *delegate = [OCMockObject niceMockForProtocol:@protocol(DemoClientDelegate)];
    self.delegate = delegate;
    
    
    // Stub the Protocol method to provide the client a wrong password
    
    [[[delegate stub] andReturn:@"test2"] passwordForClient:OCMOCK_ANY];
    
    
    // Let the test succeed, if the client failed to connect and the error has the correct error doamin and error code
    
    [[[delegate stub] andDo:^(NSInvocation *invocation) {
        __unsafe_unretained NSError *error;
        [invocation getArgument:&error atIndex:3];
        STAssertEqualObjects(error, [NSError errorWithDomain:@"DemoClientErrorDomain" code:10 userInfo:nil], @"Expecting an error.");
        STSuccess();
    }] client:OCMOCK_ANY connectDidFailWithError:OCMOCK_ANY];
    
    
    // Let the test fail, if the client did connect. This shouldn't happen because of the wrong password.
    
    [[[delegate stub] andDo:^(NSInvocation *invocation) {
        STFail(@"Client should not connect with a wrong password.");
    }] clientDidConnect:OCMOCK_ANY];
    
    
    // Create an instance of the client and set the delegate
    
    DemoClient *client = [[DemoClient alloc] init];
    client.delegate = delegate;
    
    
    // Initiate the connection
    
    [client connect];
}

@end
