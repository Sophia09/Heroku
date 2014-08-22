//
//  ImageUtility.m
//  Heroku2
//
//  Created by lisai  on 8/22/14.
//  Copyright (c) 2014 thoughtworks. All rights reserved.
//

#import "ImageUtility.h"

@implementation ImageUtility

+ (BOOL)imageExists:(NSString *)imageName ofType:(NSString *)extension
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES)
                              objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:[NSString
                                                                       stringWithFormat:@"%@.%@", imageName, extension]];
    
   return [fileManager fileExistsAtPath:filePath];
}

+(void)saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES)
                              objectAtIndex:0];
    
    if ([[extension lowercaseString] isEqualToString:@"png"])
    {
        [UIImagePNGRepresentation(image) writeToFile:[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]]
                                             options:NSAtomicWrite
                                               error:nil];
    }
    else if ([[extension lowercaseString] isEqualToString:@"jpg"]
             || [[extension lowercaseString] isEqualToString:@"jpeg"])
    {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]]
                                                   options:NSAtomicWrite
                                                     error:nil];
    }
}

+(UIImage *)loadImage:(NSString *)imageName ofType:(NSString *)extension
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES)
                              objectAtIndex:0];
 
    return [UIImage imageWithContentsOfFile:[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, extension]]];
}

+ (void)deleteImageWithPrefix:(NSString *)prefix
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES)
                              objectAtIndex:0];
     NSArray *fileNameArray = [[[NSFileManager alloc] init] subpathsAtPath:documentPath];
    
    // Delele image file if it's name starts with prefix
    for (NSString *imageName in fileNameArray)
    {
        if ([imageName rangeOfString:prefix].location != NSNotFound)
        {
            [[NSFileManager defaultManager] removeItemAtPath:[documentPath stringByAppendingPathComponent:imageName] error:nil];
        }
    }
}

@end
