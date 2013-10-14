## iOS A/B Split Test Library

This is an Objective-C library for performing A-B testing in iOS Apps. Data is configured and results are collected remotely using the companion PHP Server project (https://github.com/chrismaddern/A-B-Split-Test-Server). This project contains a sql export of the state of the database to match the test app in this repository.

#### Podfile
```ruby
platform :ios, '5.0'
pod "ABTest", "~> 0.0.5"
```

## Sample Application
There is a basic Sample Application which contains examples of each of the ways to perform an A/B Test.

You can perform a split test in a number of ways:

- Custom control in Interface builder.
	- Add a `UIButton` to the View
	- Change it's Class to either `ABTestButton` or `ABImageTestButton`
	- Set the User Defined Runtime Attributes:
		- <code>testCase</code> - the token of the test case
		- <code>default</code> - the control value and used when no test data is available
		- <code>type</code> (`UIImageTestButton` only) - "url" or "local" - determines whether to load the images in the test case from the bundle or the web.

<img src="http://cloud.chrismaddern.com/image/1V3X2w441o31/Screen%20Shot%202012-09-23%20at%2009.27.02.png">

The button will report a positive outcome for that test case whenever it is tapped.

- Test Anything that can be determined with a String using ABTestCase

Code:

    //Create a test case
    ABTestCase *testCase = [[ABTestCase alloc] 
        initWithTestCase:YOUR_TEST_CASE_ID
        andControlValue:THE_DEFAULT_STRING_TO_FALL_BACK_ON];
    NSString* testValue = [testCase value];
    //Do whatever you want with testValue here 

And then to report the outcome…

    //Something good has happened because of this value
    ABTestCaseOutcome *outcome = [[ABTestCaseOutcome alloc] 
        initWithTestCase:YOUR_TEST_CASE_ID
        andOutcomeResponse:ABPositiveResponse];
    [outcome send];

## License

The iOS A/B Split Test Library is licensed under the MIT License.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
