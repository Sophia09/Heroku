//
//  ImageUtility.h
//  Heroku2
//
//  Created by lisai  on 8/22/14.
//  Copyright (c) 2014 thoughtworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtility : NSObject

+ (BOOL)imageExists:(NSString *)imageName ofType:(NSString *)extension;

+(void)saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension;

+(UIImage *)loadImage:(NSString *)imageName ofType:(NSString *)extension;

+ (void)deleteImageWithPrefix:(NSString *)prefix;

@end
