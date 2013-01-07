__SenTestingKitAsync__ is an extension to the build in unit testing framework in Xcode, that enables real asynchronous testing. While other patterns (or frameworks) for asynchronous testing are usualy waiting in a while loop on the main thread, this extension breaks up the synchronous call stack of the test suite. With this in hand, testing of delegate-based APIs or other asynchronus methods is easy.

There are only three things, which have to be done in addition to _normal_ unit tests with `SenTestingKit`:

1. The extension has to be linked into your test target (best by using cocoapods):
	
	<pre>
	target :test, :exclusive => true do
	    pod 'SenTestingKitAsync', '~> 1.0'
	end
	</pre>

2. The test method must end with `Async`:
	
	<pre>- (void)testSelectorAsync;
	{
    	[self performSelector:@selector(mySelector) withObject:nil afterDelay:2.0];
	}
	</pre>

3. You have to tell the test runner, when a test succeeds:

	<pre>- (void)mySelector;
	{
		STSuccess();
	}
	</pre>

All other tests are done with the normal set of tools as usually. For example, you can check the arguments of an delegate call:

<pre>
- (void)testSelectorAsync;
{
	[self performSelector:@selector(myOtherSelector:) withObject:@(2) afterDelay:2.0];
}

- (void)myOtherSelector:(NSNumber *)value;
{
	STAssertEqualObjects(value, @(3), @"Expecting the number '3'.");
	STSuccess();
}
</pre>

Finally, because this is just an extension to the build in testing framework, we benefit from the error logs. If an test did not succeed, it is highlighted just as the other synchronus tests.

![Screenshot of Xcode showing a filed test.](https://raw.github.com/nxtbgthng/SenTestingKitAsync/master/images/log.png)
