//
//  ZPMasterViewController.h
//  ZooPhotos
//
//  Created by Lammert Westerhoff on 9/15/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZPDetailViewController;

@interface ZPMasterViewController : UITableViewController

@property (strong, nonatomic) ZPDetailViewController *detailViewController;

@end
