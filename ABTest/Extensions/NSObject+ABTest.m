//
//  NSObject+ABTest.m
//  ABTestSampleApp
//
//  Created by Chris Maddern on 22/09/2012.
//  Copyright (c) 2012 Chris Maddern. All rights reserved.
//

#import "NSObject+ABTest.h"

@implementation NSObject (ABTest)

- (NSString *)describeTestCase {
    // Colors
    if([self isKindOfClass:[UIColor class]]) {
        const CGFloat *_components = CGColorGetComponents(((UIColor*)self).CGColor);
        CGFloat red     = _components[0];
        CGFloat green = _components[1];
        CGFloat blue   = _components[2];
        CGFloat alpha = _components[3];
        
        return [NSString stringWithFormat:@"%f,%f,%f,%f",red,green,blue,alpha];
    }
    
    if([self isKindOfClass:[NSString class]]) {
        return (NSString*)self;
    }
    
    if([self isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@", self];
    }
    else {
        @try {
            return [NSString stringWithFormat:@"%@", self];
        }
        @catch (NSException *exception) {
            return [NSString stringWithFormat:@"Unknown Test Case Object - %@", [self class]];
        }
    }
}

@end
