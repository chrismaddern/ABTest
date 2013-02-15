//
//  ABTestManager.h
//  ABTestSampleApp
//
//  Created by Chris Maddern on 22/09/2012.
//  Copyright (c) 2012 Chris Maddern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABTestCaseOutcome.h"

@interface ABTestManager : NSObject

@property (nonatomic, retain) NSString* serverBaseURL;
@property (nonatomic, retain) NSString* applicationToken;
@property (nonatomic) BOOL shouldFixCasesForDevice;
@property (nonatomic, retain) NSNumber* minimumRefreshSeconds;
@property (nonatomic, retain) NSString *userIdentifier;

@property (nonatomic, retain) NSOperationQueue *updateQueue;
@property (nonatomic, retain) NSMutableDictionary *testCases;
@property (nonatomic, retain) NSMutableDictionary *testCasesFixed;
@property (nonatomic, retain) NSMutableArray *responsesForUpload;

+(ABTestManager*)testManager;

-(BOOL)hasConfigurationForTestCase:(NSString*)testCaseIdentifier;
-(void)refreshTestCaseConfigurations;
-(id)valueForTestCase:(NSString*)testCaseIdentifier;
-(void)addTestOutcomeToUploadQueue:(ABTestCaseOutcome*)testCaseOutcome;


@end
