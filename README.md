## iOS A/B Split Test Library

This is an Objective-C library for performing A-B testing in iOS Apps. Data is configured and results are collected remotely using the companion PHP Server project (https://github.com/chrismaddern/A-B-Split-Test-Server). This project contains a sql export of the state of the database to match the test app in this repository.

### Podfile
```ruby
platform :ios, '5.0'
pod "ABTest", "~> 0.0.5"
```

## Sample Application
There is a basic Sample Application which contains examples of each of the ways to perform an A/B Test.

## Ways to perform an A/B Test
#### Interface builder control
1. Add a `UIButton` to the View
2. Change it's Class to either `ABTestButton` or `ABImageTestButton`
3. Set the User Defined Runtime Attributes:

`testCase` -> the token of the test case

`default` -> the control value and used when no test data is available

`type`	-> "url" or "local" (UIImageTestButton only)



The button will report a positive outcome for that test case whenever it is tapped.

#### Test any string value in code
You can test anything that can be determined with a String using an ABTestCase in your own code.

Code:
```objc
// Create a test case
ABTestCase *testCase = [[ABTestCase alloc] initWithTestCase:YOUR_TEST_CASE_ID
                                            andControlValue:THE_DEFAULT_STRING_TO_FALL_BACK_ON];
NSString* testValue = [testCase value];
// Do whatever you want with testValue here 
```

And then to report the outcome…
```objc
// Something good has happened because of this value
ABTestCaseOutcome *outcome = [[ABTestCaseOutcome alloc] initWithTestCase:YOUR_TEST_CASE_ID
                                                      andOutcomeResponse:ABPositiveResponse];
[outcome send];
```

## License

The iOS A/B Split Test Library is licensed under the MIT License.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
