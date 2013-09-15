//
//  ZPDetailViewController.h
//  ZooPhotos
//
//  Created by Lammert Westerhoff on 9/15/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZPDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
