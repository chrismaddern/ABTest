//
//  ABTestCase.h
//  ABTestSampleApp
//
//  Created by Chris Maddern on 22/09/2012.
//  Copyright (c) 2012 Chris Maddern. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABTestCase : NSObject

@property (nonatomic, retain) NSString* testCaseIdentifier;
@property (nonatomic, retain) id testCaseValue;
@property (nonatomic) BOOL isTesting;
-(id)initWithTestCase:(NSString*)testCaseId andControlValue:(id)controlObject;
-(NSString*)value;
@end
