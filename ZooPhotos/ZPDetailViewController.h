//
//  ZPDetailViewController.h
//  ZooPhotos
//
//  Created by Lammert Westerhoff on 9/15/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPFlickrPhoto.h"

@interface ZPDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) ZPFlickrPhoto *photo;

@end
