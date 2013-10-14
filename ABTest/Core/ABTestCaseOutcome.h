//
//  ABTestCaseOutcome.h
//  ABTestSampleApp
//
//  Created by Chris Maddern on 22/09/2012.
//  Copyright (c) 2012 Chris Maddern. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum
{
    ABNegativeResponse,
    ABNeutralResponse,
    ABPositiveResponse
}ABTestCaseOutcomeResponse;

@interface ABTestCaseOutcome : NSObject

@property (nonatomic, retain) NSString *testCaseIdentifier;
@property (nonatomic, retain) id testCaseValue;
@property (nonatomic) ABTestCaseOutcomeResponse testCaseOutcomeResponse;
@property (nonatomic) BOOL sent;

- (id)initWithTestCase:(NSString *)testId andOutcomeResponse:(ABTestCaseOutcomeResponse)response;
- (void) send;
@end
