//
//  ABTestManager.m
//  ABTestSampleApp
//
//  Created by Chris Maddern on 22/09/2012.
//  Copyright (c) 2012 Chris Maddern. All rights reserved.
//

#import "ABTestManager.h"
#include <math.h>
#import "OpenUDID.h"
#import "NSString+MD5.h"

#define BASE_URL_KEY @"server_base_url"
#define APPLICATION_TOKEN_KEY @"application_token"
#define FIX_TEST_CASES_KEY @"fix_case_per_device"
#define MINIMUM_SECONDS_BETWEEN_REFRESH @"minimum_seconds_between_fetch"

#define TEST_CASES_STORE_KEY @"com.chrismaddern.abtestlibrary.testcaseskey"
#define TEST_CASES_FIXED_STORE_KEY @"com.chrismaddern.abtestlibrary.testcasesfixedkey"
#define TEST_CASES_LAST_SUCCESFULLY_REFRESHED_KEY @"com.chrismaddern.abtestlibrary.lastsuccessfetchkey"

@interface ABTestManager()

- (BOOL) shouldRefreshTestData;
- (void) updateLastSyncrhonizedDate;
- (void) saveTestCases;

@end

@implementation ABTestManager
@synthesize serverBaseURL, applicationToken, shouldFixCasesForDevice, minimumRefreshSeconds, userIdentifier;
@synthesize updateQueue, testCases, testCasesFixed, responsesForUpload;

+ (ABTestManager*)testManager {
    static ABTestManager *testManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        testManager = [[self alloc] init];
    });
    
    return testManager;
}

#pragma mark -
#pragma mark Setup Test Manager

- (id)init {
    if (self = [super init]) {
        updateQueue = [NSOperationQueue new];
        responsesForUpload = [[NSMutableArray alloc] init];
        BOOL configurationLoaded =false;
        BOOL testCasesLoaded = false;
        
        userIdentifier = [OpenUDID value];
        configurationLoaded = [self loadLibraryConfiguration];
        
        if(configurationLoaded){ testCasesLoaded = [self restoreTestCases]; }
        
        [self refreshTestCaseConfigurations];
        [self startBackgroundUploader];
    }
    return self;
}

-(void)startBackgroundUploader
{
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, backgroundQueue);
    dispatch_source_set_timer(timerSource, dispatch_time(DISPATCH_TIME_NOW, 0), 60.0*NSEC_PER_SEC, 0*NSEC_PER_SEC);
    dispatch_source_set_event_handler(timerSource, ^{
        [self uploadAllResponses];
    });
    dispatch_resume(timerSource);
    
}

-(BOOL)restoreTestCases
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *fixedToLoad = [defaults objectForKey:TEST_CASES_FIXED_STORE_KEY];
    if(fixedToLoad && [fixedToLoad isKindOfClass:[NSMutableDictionary class]])
    {
        testCasesFixed = [[NSMutableDictionary alloc] initWithDictionary:fixedToLoad];
    }
    else
    {
        testCasesFixed = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableDictionary *dictToLoad = [defaults objectForKey:TEST_CASES_STORE_KEY];
    if(dictToLoad && [dictToLoad isKindOfClass:[NSMutableDictionary class]] && [dictToLoad count] > 0)
    {
        testCases = [[NSMutableDictionary alloc] initWithDictionary:dictToLoad];
        return true;
    }
    
    testCases = [[NSMutableDictionary alloc] init];
    return false;
}

-(BOOL)loadLibraryConfiguration
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ABTestSettings" ofType:@"plist"];
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    BOOL configurationComplete = true;
    
    if([plistDictionary objectForKey:BASE_URL_KEY])
    {
        serverBaseURL = [plistDictionary objectForKey:BASE_URL_KEY];
    }
    else
    { configurationComplete = false; }
    
    if([plistDictionary objectForKey:APPLICATION_TOKEN_KEY])
    {
        applicationToken = [plistDictionary objectForKey:APPLICATION_TOKEN_KEY];
    }
    else { configurationComplete = false; }
    
    if([plistDictionary objectForKey:FIX_TEST_CASES_KEY])
    {
        // @TODO: It's currently impossible to disable shouldFixCasesForDevice - need to implement tracking of an ABTestCase -> a ABTestCaseOutcome without having to keep the ABTestCase around as that would be messy
        shouldFixCasesForDevice = true; // [[NSNumber numberWithBool:YES] isEqualToNumber:(NSNumber*)[plistDictionary objectForKey:FIX_TEST_CASES_KEY]]?true:false;
    }
    else { configurationComplete = false; }
    
    if([plistDictionary objectForKey:MINIMUM_SECONDS_BETWEEN_REFRESH])
    {
        minimumRefreshSeconds = [plistDictionary objectForKey:MINIMUM_SECONDS_BETWEEN_REFRESH];
    }
    else { configurationComplete = false; }
    
    if(!configurationComplete)
    {
        NSLog(@"ABTestLibrary :: Could not load configuration from ABTestSettings.plist");
    }
    return configurationComplete;
}

-(void)refreshTestCaseConfigurations
{
    if(![self shouldRefreshTestData])
    {
        NSLog(@"ABTestLibrary :: Notice :: Not updating as minimum seconds have not been reached.");
        return;
    }
    
    NSString *requestURL = [NSString stringWithFormat:@"%@tests/?application=%@", serverBaseURL, applicationToken];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURL]];
    
    [NSURLConnection sendAsynchronousRequest:req queue:updateQueue completionHandler:
     ^(NSURLResponse *urlResponse, NSData *responseData, NSError *err)
     {
         // Got response from request
         if(!(err==nil))
         {
             NSLog(@"ABTestLibrary :: Error retrieving test case configurations. %@", [err localizedDescription]);
             return;
         }
         
         NSError *error;
         NSDictionary* json = [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:kNilOptions
                               error:&error];
         if([json count] > 0)
         {
             testCases = [NSMutableDictionary dictionaryWithDictionary:json];
             [self saveTestCases];
             [self updateLastSyncrhonizedDate];
         }
         else
         {
             NSLog(@"ABTestLibrary :: Received a response with 0 test cases for Application Token");
         }
         
     }];
    
}

#pragma mark -
#pragma mark Running Tests

-(BOOL)hasConfigurationForTestCase:(NSString*)testCaseIdentifier
{
    if([testCases objectForKey:testCaseIdentifier])
    {
        return YES;
    }
    
    [self refreshTestCaseConfigurations];
    return NO;
}

-(id)valueForTestCase:(NSString*)testCaseIdentifier
{
    if(![self hasConfigurationForTestCase:testCaseIdentifier])
    {
        return nil;
    }
    
    if(shouldFixCasesForDevice && [testCasesFixed objectForKey:testCaseIdentifier])
    {
        if([(NSArray*)[testCases objectForKey:testCaseIdentifier] count] > [(NSNumber*)[testCasesFixed objectForKey:testCaseIdentifier] integerValue])
        {
            return [(NSArray*)[testCases objectForKey:testCaseIdentifier] objectAtIndex:[(NSNumber*)[testCasesFixed objectForKey:testCaseIdentifier] integerValue]];
        }
        else
        {
            NSLog(@"ABTestLibrary :: Notice :: Removed saved invalid test case fixed value.");
            [testCasesFixed removeObjectForKey:testCaseIdentifier];
        }
    }
    // No predetermined test case or predetermined tests disabled
    NSArray *optionsForTestCase = [testCases objectForKey:testCaseIdentifier];
    if(optionsForTestCase == nil || [optionsForTestCase count] == 0)
    {
        return nil;
    }
    double val = arc4random() / ((double) (((long long)2<<31) -1));
    
    int selectedCase = (int)round(((double)([optionsForTestCase count] - 1)) * val);
    
    if(shouldFixCasesForDevice)
    {
        [testCasesFixed setObject:[NSNumber numberWithInt:selectedCase] forKey:testCaseIdentifier];
        [self saveTestCases];
    }
    return [optionsForTestCase objectAtIndex:selectedCase];
}

-(void)addTestOutcomeToUploadQueue:(ABTestCaseOutcome*)testCaseOutcome
{
    [responsesForUpload addObject:testCaseOutcome];
}

-(void)uploadAllResponses
{
    int uploadAttempts = 0;
    while([responsesForUpload count] > 0)
    {
        NSString *requestURL = [NSString stringWithFormat:@"%@results/", serverBaseURL];
        ABTestCaseOutcome *currentTestCaseOutcome = [responsesForUpload objectAtIndex:0];
       [responsesForUpload removeObjectAtIndex:0];
        
        NSString *postPayload = [NSString stringWithFormat:@"application=%@&user=%@&testcase=%@&outcome=%d&value=%@", applicationToken, userIdentifier, currentTestCaseOutcome.testCaseIdentifier, currentTestCaseOutcome.testCaseOutcomeResponse, [currentTestCaseOutcome.testCaseValue base64String]];
        
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURL]];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[postPayload dataUsingEncoding:NSUTF8StringEncoding]];
        
        [NSURLConnection sendAsynchronousRequest:req queue:updateQueue completionHandler:
         ^(NSURLResponse *urlResponse, NSData *responseData, NSError *err)
         {
            if(err!= nil)
            {
                [responsesForUpload addObject:currentTestCaseOutcome];
                return;
            }
            else
                NSLog(@"ABTestLibrary :: Reported outcome for test with identifier: %@", currentTestCaseOutcome.testCaseIdentifier);
         }];
        
        uploadAttempts++;
    }
}

- (void)dealloc {
    //Let's be greedy :)
}

#pragma mark -
#pragma mark Helper Methods 

- (BOOL) shouldRefreshTestData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lastCheckedSecondsSince1970 = [defaults objectForKey:TEST_CASES_LAST_SUCCESFULLY_REFRESHED_KEY];
    return lastCheckedSecondsSince1970 != nil && ((((int)[[NSDate date] timeIntervalSince1970]) - [lastCheckedSecondsSince1970 integerValue]) > [minimumRefreshSeconds integerValue]);
}

- (void) updateLastSyncrhonizedDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:((int)[[NSDate date] timeIntervalSince1970])] forKey:TEST_CASES_LAST_SUCCESFULLY_REFRESHED_KEY];
    [defaults synchronize];
}

-(void)saveTestCases
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(testCases != nil)
        [defaults setObject:testCases forKey:TEST_CASES_STORE_KEY];
    
    if(testCasesFixed != nil)
        [defaults setObject:testCasesFixed forKey:TEST_CASES_FIXED_STORE_KEY];
    
    [defaults synchronize];
}


@end
