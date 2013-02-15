//
//  ABTestCaseOutcome.m
//  ABTestSampleApp
//
//  Created by Chris Maddern on 22/09/2012.
//  Copyright (c) 2012 Chris Maddern. All rights reserved.
//

#import "ABTestCaseOutcome.h"
#import "ABTestManager.h"

@interface ABTestCaseOutcome()

-(void)addToUploadQueue;

@end

@implementation ABTestCaseOutcome
@synthesize testCaseValue,testCaseIdentifier, testCaseOutcomeResponse, sent;

-(id)initWithTestCase:(NSString*)testId andOutcomeResponse:(ABTestCaseOutcomeResponse)response
{
    self = [super init];

    if(self)
    {
        testCaseIdentifier = testId;
        testCaseOutcomeResponse = response;
        testCaseValue = [[ABTestManager testManager] valueForTestCase:testId];
    }
    
    return self;
}

-(void)send
{
    [self addToUploadQueue];
}

-(void)addToUploadQueue
{
    [[ABTestManager testManager] addTestOutcomeToUploadQueue:self];
}

@end
