//
//  ABTestCase.m
//  ABTestSampleApp
//
//  Created by Chris Maddern on 22/09/2012.
//  Copyright (c) 2012 Chris Maddern. All rights reserved.
//

#import "ABTestCase.h"
#import "ABTestManager.h"

@implementation ABTestCase
@synthesize testCaseIdentifier, testCaseValue, isTesting;

-(id)initWithTestCase:(NSString*)testCaseId andControlValue:(id)controlObject
{
    self = [super init];
    
    if(self)
    {
        testCaseIdentifier = testCaseId;
        testCaseValue = [[ABTestManager testManager] valueForTestCase:testCaseId];
        if(testCaseValue == nil)
        {
            isTesting = false;
            testCaseValue = controlObject;
        }
        else
        {
            isTesting = true;
        }
    }
    
    return self;
}

-(NSString*)value
{
    return testCaseValue;
}


@end
