//
//  ABTestButton.m
//  ABTestSampleApp
//
//  Created by Chris Maddern on 22/09/2012.
//  Copyright (c) 2012 Chris Maddern. All rights reserved.
//

#import "ABTestButton.h"
#import "ABTestCaseOutcome.h"
#import <QuartzCore/QuartzCore.h>

@implementation ABTestButton
@synthesize testCaseIdentifier, testCase, controlValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithTestName:(NSString*)testCaseId andControlValue:(NSString*)controlValueIn
{
    self = [super init];
    
    if(self)
    {
        [self configureButton];
        self.testCaseIdentifier = testCaseId;
        self.controlValue = controlValueIn;
        self.testCase = [[ABTestCase alloc] initWithTestCase:testCaseIdentifier andControlValue:controlValue];
        [self setTitle:[testCase value] forState:UIControlStateNormal];
        UILabel *l = self.titleLabel;
        l.textColor = [UIColor blackColor];
        if([testCase isTesting])
        {
            [self addTarget: self action: @selector(registerTestResult) forControlEvents: UIControlEventTouchUpInside];
        }
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self != nil)
    {
        [self configureButton];
    }
    return self;
}

-(void)configureButton
{
    [self setBackgroundColor:[UIColor whiteColor]];
    self.layer.cornerRadius = 10;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.clipsToBounds = YES;
    
    [self setBackgroundImage:[self highlightImage] forState:UIControlStateHighlighted];
}

-(UIImage*)highlightImage
{
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 0.021, 0.548, 0.962, 1.000, 0.008, 0.364, 0.900, 1.000 };
    
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef selectionGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, selectionGradient, startPoint, endPoint, 0);
    
    CGGradientRelease(selectionGradient);
    CGColorSpaceRelease(rgbColorspace);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(void) setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"testCase"])
    {
        self.testCaseIdentifier = value;
    }
    else if([key isEqualToString:@"default"])
    {
        self.controlValue = value;
    }
    
    if(self.testCaseIdentifier != nil && self.controlValue != nil)
    {
        testCase = [[ABTestCase alloc] initWithTestCase:self.testCaseIdentifier andControlValue:self.controlValue];
        [self setTitle:[testCase value] forState:UIControlStateNormal];
        if([testCase isTesting])
        {
            [self addTarget: self action: @selector(registerTestResult) forControlEvents: UIControlEventTouchUpInside];
        }
    }
}

-(void)registerTestResult
{
    ABTestCaseOutcome *result = [[ABTestCaseOutcome alloc] initWithTestCase:testCase.testCaseIdentifier andOutcomeResponse:ABPositiveResponse];
    [result send];
}

-(UIButtonType)buttonType
{
    return UIButtonTypeRoundedRect;
}

-(void)awakeFromNib
{
    
}

@end
