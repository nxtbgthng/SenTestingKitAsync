# SenTestingKitAsync

__SenTestingKitAsync__ is an extension to the built-in unit testing framework in Xcode that enables real asynchronous testing. While other patterns (or frameworks) for asynchronous testing usually just wait in a while loop on the main thread, this extension breaks up the synchronous call stack of the test suite. With this in hand, testing of delegate-based APIs or other asynchronus methods is easy.

## Getting started

There are only 4 steps which have to be done in addition to _normal_ unit tests with `SenTestingKit`:

1. The extension has to be linked into your test target (best by using [CocoaPods](http://cocoapods.org)):
	<pre>
	target :test, :exclusive => true do
	    pod 'SenTestingKitAsync', '~> 1.0'
	end</pre>
	If you want to do it by hand, just include `SenTestingKitAsync.h` and `SenTestingKitAsync.m` in your test target.

2. Import the header:
   <pre>#import &lt;SenTestingKitAsync/SenTestingKitAsync.h&gt;</pre>

3. Let the test method end with `Async`:
	<pre>- (void)testSelectorAsync
	{
    	[self performSelector:@selector(mySelector) withObject:nil afterDelay:2.0];
	}</pre>

4. Tell the test runner when a test succeeds:
	<pre>- (void)mySelector
	{
		STSuccess();
	}</pre>
	This is needed because the test runner waits until a test explicitly fails (by calling one of the macros like `STFail(…)` or `STAssertEqualObjects(…)`) or succeeds (by calling `STSuccess()`). If none of these occur, the test runner waits forever.

All other tests are done with the normal set of tools as usual. For example, you can check the arguments of a delegate call:

<pre>
- (void)testSelectorAsync
{
	[self performSelector:@selector(myOtherSelector:) withObject:@(2) afterDelay:2.0];
}

- (void)myOtherSelector:(NSNumber *)value
{
	STAssertEqualObjects(value, @(3), @"Expecting the number '3'.");
	STSuccess();
}</pre>

Finally, because this is just an extension to the built-in testing framework, we benefit from the error logs. If a test did not succeed, it is highlighted just as the other synchronus tests.

![Screenshot of Xcode showing a failed test.](https://raw.github.com/nxtbgthng/SenTestingKitAsync/master/images/log.png)

## Additional macros

In addition to the exsiting macros like `STAssertTrue(…)` or `STAssertEqualObjects(…)`, this extension introduces two more macros:

- `STFailAfter(timeout, description, …)`: This macro starts a timer and lets the test fail with the given description, if nothing else (`STAssert…` or `STSuccess`) has been called.
- `STSuccess()`: This macro must be called to indicate that the test did succeed. If you don't call this and no other failure occured, the test runs forever.

## Asynchronous set up and tear down of test cases

If the setup needed by you test is also handled asynchronous, you can now do this with the extension to SenTestCase. Simply implement `-[SenTest setUpWithCompletionHandler:]` or `-[SenTest tearDownWithCompletionHandler:]` in you test case and do the setup (or tear down). If you are done with that, call the completion handler (and do not forget to call the setup or tear down of super).

```
- (void)setUpWithCompletionHandler:(void(^)())handler
{
    [super setUpWithCompletionHandler:^{
        // Your set up
        handler();
    }];
}

- (void)tearDownWithCompletionHandler:(void (^)())handler
{
    [super tearDownWithCompletionHandler:^{
        // Your tear down
        handler();
    }];
}
```

Because there is no timeout or error catching, you have to be sure, that your implementation that is used for set up and tear down is well tested. In case of an error exit the test with an assertion. 

---

Copyright (c) 2012, 2013 nxtbgthng GmbH.
All rights reserved.
        
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
        
- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
        
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
