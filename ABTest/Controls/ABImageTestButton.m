//
//  ABTestButton.m
//  ABTestSampleApp
//
//  Created by Chris Maddern on 22/09/2012.
//  Copyright (c) 2012 Chris Maddern. All rights reserved.
//

#import "ABImageTestButton.h"
#import "ABTestCaseOutcome.h"
#import <QuartzCore/QuartzCore.h>

@implementation ABImageTestButton
@synthesize testCaseIdentifier, testCase, controlValue;
@synthesize imageCache, shouldLoadNonControlFromUrl, _hasSetShouldLoadImageFromUrl;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTestName:(NSString *)testCaseId andControlValue:(NSString *)controlValueIn {
    self = [super init];
    
    if(self) {
        [self configureButton];
        self.imageCache = [[ABTestImageCache alloc] init];
        self.testCaseIdentifier = testCaseId;
        self.controlValue = controlValueIn;
        self.testCase = [[ABTestCase alloc] initWithTestCase:testCaseIdentifier
                                             andControlValue:controlValue];
        [self configureBackgroundImage];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self != nil)
    {
        self.imageCache = [[ABTestImageCache alloc] init];
        [self configureButton];
    }
    return self;
}

- (void)configureButton {
    self.layer.cornerRadius = 10;
    self.clipsToBounds = YES;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"testCase"]) {
        self.testCaseIdentifier = value;
    }
    else if([key isEqualToString:@"default"]) {
        self.controlValue = value;
    }
    else if([key isEqualToString:@"type"]) {
        _hasSetShouldLoadImageFromUrl = true;
        if([value isEqualToString:@"url"]) {
            shouldLoadNonControlFromUrl = true;
        }
    }
    
    if(self.testCaseIdentifier != nil
       && self.controlValue != nil
       && _hasSetShouldLoadImageFromUrl) {
        
        testCase = [[ABTestCase alloc] initWithTestCase:self.testCaseIdentifier
                                        andControlValue:self.controlValue];
        [self configureBackgroundImage];
        
    }
}

- (void)configureBackgroundImage {
    
    if([testCase isTesting]) {
        if(shouldLoadNonControlFromUrl) {
            if([imageCache hasCachedImageWithUrl:[testCase value]]) {
                [self setBackgroundImage:[imageCache imageWithUrl:[testCase value]]
                                forState:UIControlStateNormal];
                [self addTarget: self
                         action: @selector(registerTestResult)
               forControlEvents: UIControlEventTouchUpInside];
            }
            else {
                [self setBackgroundImage:[UIImage imageNamed:controlValue]
                                forState:UIControlStateNormal];
            }
        }
        else {
            [self setBackgroundImage:[UIImage imageNamed:[testCase value]]
                            forState:UIControlStateNormal];
        }
    }
    else
    {
        [self setBackgroundImage:[UIImage imageNamed:[testCase value]] forState:UIControlStateNormal];
    }
}

- (void)registerTestResult {
    ABTestCaseOutcome *result = [[ABTestCaseOutcome alloc] initWithTestCase:testCase.testCaseIdentifier andOutcomeResponse:ABPositiveResponse];
    [result send];
}

- (UIButtonType)buttonType {
    return UIButtonTypeRoundedRect;
}

-(void)awakeFromNib {
    
}

@end
