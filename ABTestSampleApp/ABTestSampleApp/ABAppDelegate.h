//
//  ABAppDelegate.h
//  ABTestSampleApp
//
//  Created by Chris Maddern on 22/09/2012.
//  Copyright (c) 2012 Chris Maddern. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABViewController;

@interface ABAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ABViewController *viewController;

@end
