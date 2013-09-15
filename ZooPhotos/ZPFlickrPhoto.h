//
//  LWFlickrPhoto.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/7/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZPPhoto.h"

/**
 * Subclass of LWPhoto for Flickr.
 */
@interface ZPFlickrPhoto : ZPPhoto

@property (copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *owner;
@property (copy, nonatomic) NSString *title;

@end
