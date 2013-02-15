//
//  ABTestImageCache.m
//  ABTestSampleApp
//
//  Created by Chris Maddern on 22/09/2012.
//  Copyright (c) 2012 Chris Maddern. All rights reserved.
//

#import "ABTestImageCache.h"
#import "NSString+MD5.h"

@implementation ABTestImageCache

-(BOOL)hasCachedImageWithUrl:(NSString*)url
{
    NSString *imgPath = [self filePathForImageAtUrl:url];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:imgPath])
    {
        [self downloadImageForUrl:url];
        return NO;
    }
    return YES;
}

-(UIImage*)imageWithUrl:(NSString*)url
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imgPath = [self filePathForImageAtUrl:url];
    if(![fileManager fileExistsAtPath:imgPath])
    {
        [self downloadImageForUrl:url];
        return nil;
    }
    
    NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
    UIImage *img = [[UIImage alloc] initWithData:imgData];
    return img;
}

-(NSString*)filePathForImageAtUrl:(NSString*)url
{
    NSString *imageDirectory = [self cacheDirectory];
    NSString *fileHash = [url md5];
    
    NSString *imgPath = [imageDirectory stringByAppendingString:fileHash];
    return imgPath;
}

-(void)downloadImageForUrl:(NSString*)remoteUrl
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *saveUrl = [self filePathForImageAtUrl:remoteUrl];
        
        NSURL *url = [NSURL URLWithString:remoteUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];
        [responseData writeToFile:saveUrl atomically:NO];
    });
}

-(NSString*)cacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *finalPath = [documentsDirectory stringByAppendingString:@"/ABTestImageCache/"];
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    BOOL isDir = true;
    if(![fileManager fileExistsAtPath:finalPath isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:finalPath withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"ABTestLibrary:: Could not create image cache folder at %@", finalPath);
    
    return finalPath;
}


@end
