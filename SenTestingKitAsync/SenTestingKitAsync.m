//
//  SenTestingKitAsync.m
//  SenTestingKitAsync
//
//  Created by Tobias Kräntzer on 07.01.13.
//  Copyright (c) 2013 nxtbgthng GmbH. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "SenTestingKitAsync.h"

static const char * kSenTestCaseAsyncCompletionHandlerKey = "kSenTestCaseAsyncCompletionHandlerKey";
static const char * kSenTestCaseTestRunKey = "kSenTestCaseTestRunKey";

typedef void(^SenTestCompletionHandler)(SenTestRun *run);

@interface SenTest (Async)
- (void)runWithCompletionHandler:(SenTestCompletionHandler)aCompletionHandler;
- (void)performTest:(SenTestRun *)aTestRun withCompletionHandler:(SenTestCompletionHandler)aCompletionHandler;
@end

@interface SenTestCase (Async)
- (void)performTest:(SenTestRun *)aTestRun withCompletionHandler:(SenTestCompletionHandler)aCompletionHandler;
@end

@interface SenTestSuite (Async)
@end

@interface SenTestProbe (Async)
@end

@interface SenTestProbe ()
+ (SenTestSuite *)specifiedTestSuite;
@end

@implementation SenTest (AsyncExtension)

- (void)setUpWithCompletionHandler:(void(^)())handler
{
    handler();
}

- (void)tearDownWithCompletionHandler:(void(^)())handler
{
    handler();
}

@end

@implementation SenTest (Async)

- (void)runWithCompletionHandler:(SenTestCompletionHandler)aCompletionHandler;
{
    Class testRunClass = [self testRunClass];
    SenTestRun *testRun = [testRunClass testRunWithTest:self];
    [self performTest:testRun withCompletionHandler:^(SenTestRun *run) {
        aCompletionHandler(testRun);
    }];
}

- (void)performTest:(SenTestRun *)aRun withCompletionHandler:(SenTestCompletionHandler)aCompletionHandler;
{
    [self performTest:aRun];
    aCompletionHandler(aRun);
}

@end

@implementation SenTestCase (Async)

+ (void)load;
{
    Method oldMethod = class_getInstanceMethod([self class], @selector(failWithException:));
    if (oldMethod) {
        class_addMethod(objc_getClass(class_getName(self)),
                        @selector(syncFailWithException:),
                        method_getImplementation(oldMethod),
                        method_getTypeEncoding(oldMethod));
    }
    
    Method newMethod = class_getInstanceMethod([self class], @selector(asyncFailWithException:));
    if (newMethod) {
        class_replaceMethod(objc_getClass(class_getName(self)),
                            @selector(failWithException:),
                            method_getImplementation(newMethod),
                            method_getTypeEncoding(newMethod));
    }
}

- (void)performTest:(SenTestRun *)aRun withCompletionHandler:(SenTestCompletionHandler)aCompletionHandler;
{
    __unsafe_unretained SenTestCase *weak = self;
    
    __block NSException *exception = nil;
    
    [weak setValue:aRun forKey:@"run"];
    [weak setUp];
    
    [self setUpWithCompletionHandler:^{
        
        [aRun start];
        
        if ([NSStringFromSelector([[weak invocation] selector]) hasSuffix:@"Async"]) {
            weak.testRun = aRun;
            weak.completionHandler = aCompletionHandler;
            
            @try {
                [[weak invocation] invoke];
            }
            @catch (NSException *anException) {
                exception = anException;
            }
            
            if (exception != nil) {
                [aRun stop];
                [weak tearDownWithCompletionHandler:^{
                    [weak tearDown];
                    [weak performSelector:@selector(logException:) withObject:exception];
                    [weak setValue:nil forKey:@"run"];
                    aCompletionHandler(aRun);
                    weak.testRun = nil;
                    weak.completionHandler = nil;
                }];
            }
            
        } else {
            @try {
                [[weak invocation] invoke];
            }
            @catch (NSException *anException) {
                exception = anException;
            }
            
            [aRun stop];
            
            [weak tearDownWithCompletionHandler:^{
                [weak tearDown];
                
                if (exception != nil) {
                    [weak performSelector:@selector(logException:) withObject:exception];
                }
                
                [weak setValue:nil forKey:@"run"];
                
                aCompletionHandler(aRun); 
            }];
        }
    }];
}

- (void)asyncFailWithException:(NSException *)anException;
{
    if (self.completionHandler == nil) {
        if (anException != nil) {
            [self performSelector:@selector(syncFailWithException:) withObject:anException];
        }
    } else {
        SenTestCompletionHandler aCompletionHandler = self.completionHandler;
        self.completionHandler = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            SenTestRun *testRun = self.testRun;
            self.testRun = nil;
            
            if (anException != nil) {
                [self performSelector:@selector(logException:) withObject:anException];
            }
            
            [testRun stop];
            [self tearDownWithCompletionHandler:^{
                [self tearDown];
                [self setValue:nil forKey:@"run"];
                
                aCompletionHandler(testRun);
            }];
        });
    }
}

- (void)setCompletionHandler:(SenTestCompletionHandler)completionHandler;
{
    objc_setAssociatedObject(self, kSenTestCaseAsyncCompletionHandlerKey, completionHandler, OBJC_ASSOCIATION_RETAIN);
}

- (SenTestCompletionHandler)completionHandler;
{
    return objc_getAssociatedObject(self, kSenTestCaseAsyncCompletionHandlerKey);
}

- (void)setTestRun:(SenTestRun *)testRun;
{
    objc_setAssociatedObject(self, kSenTestCaseTestRunKey, testRun, OBJC_ASSOCIATION_RETAIN);
}

- (SenTestRun *)testRun;
{
    return objc_getAssociatedObject(self, kSenTestCaseTestRunKey);
}

@end

@implementation SenTestSuite (Async)

- (void)performTest:(SenTestRun *)aTestRun withCompletionHandler:(SenTestCompletionHandler)aCompletionHandler;
{
    [self setUp];
    [aTestRun start];
    
    NSEnumerator *testEnumerator = [[self valueForKey:@"tests"] objectEnumerator];
    
    [self performTestRun:aTestRun
      withTestEnumerator:testEnumerator
       completionHandler:aCompletionHandler];
}

- (void)performTestRun:(SenTestRun *)aTestRun
    withTestEnumerator:(NSEnumerator *)aTestEnumerator
     completionHandler:(SenTestCompletionHandler)aCompletionHandler
{
    SenTest *aTest = [aTestEnumerator nextObject];
    
    if (aTest) {
        [aTest runWithCompletionHandler:^(SenTestRun *run) {
            [(SenTestSuiteRun *)aTestRun addTestRun:run];
            [self performTestRun:aTestRun
              withTestEnumerator:aTestEnumerator
               completionHandler:aCompletionHandler];
        }];
    } else {
        [aTestRun stop];
        [self tearDownWithCompletionHandler:^{
            [self tearDown];
            aCompletionHandler(aTestRun);
        }];
    }
}

@end

@implementation SenTestProbe (Async)

+ (void)load;
{
    Method newMethod = nil;
    newMethod = class_getClassMethod([self class], @selector(runTestsAsync:));
    if (newMethod) {
        class_replaceMethod(objc_getMetaClass(class_getName([self class])),
                            @selector(runTests:),
                            method_getImplementation(newMethod),
                            method_getTypeEncoding(newMethod));
    }
}

+ (void)runTestsAsync:(id)ignored;
{
    @autoreleasepool {
        [[NSBundle allFrameworks] makeObjectsPerformSelector:@selector(principalClass)];
        [SenTestObserver class];
        
        NSRunLoop *mainRunLoop = [NSRunLoop mainRunLoop];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self specifiedTestSuite] runWithCompletionHandler:^(SenTestRun *run) {
                BOOL hasFailed = [run hasSucceeded];
                exit((int)hasFailed);
            }];
        });
        
        [mainRunLoop run];
    }
}

@end