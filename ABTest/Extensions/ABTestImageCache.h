//
//  ABTestImageCache.h
//  ABTestSampleApp
//
//  Created by Chris Maddern on 22/09/2012.
//  Copyright (c) 2012 Chris Maddern. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABTestImageCache : NSObject

-(BOOL)hasCachedImageWithUrl:(NSString*)url;
-(UIImage*)imageWithUrl:(NSString*)url;
@end
