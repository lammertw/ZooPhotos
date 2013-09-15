//
//  LWPhoto.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * A photo object with URL's to remote image locations.
 */
@interface ZPPhoto : NSObject

/**
 * The source identifier from the source of the image.
 */
@property (copy, nonatomic) NSString *source;

/**
 * The url to a thumbnail version of the image.
 */
@property (copy, nonatomic) NSURL *thumbURL;

/**
 * The url to the full photo image.
 */
@property (copy, nonatomic) NSURL *photoURL;

@end
