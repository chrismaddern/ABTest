//
//  ABTestButton.h
//  ABTestSampleApp
//
//  Created by Chris Maddern on 22/09/2012.
//  Copyright (c) 2012 Chris Maddern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABTestCase.h"

@interface ABTestButton : UIButton
@property (nonatomic, retain) NSString *testCaseIdentifier;
@property (nonatomic, retain) ABTestCase *testCase;
@property (nonatomic, retain) NSString *controlValue;

- (id)initWithTestName:(NSString *)testCaseId andControlValue:(NSString *)controlValueIn;
@end
