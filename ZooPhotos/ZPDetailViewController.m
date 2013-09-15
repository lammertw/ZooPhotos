//
//  ZPDetailViewController.m
//  ZooPhotos
//
//  Created by Lammert Westerhoff on 9/15/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import "ZPDetailViewController.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <SDNetworkActivityIndicator/SDNetworkActivityIndicator.h>

#import <FlickrKit/FlickrKit.h>

@interface ZPDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *tagsLabel;
@property (weak, nonatomic) NSOperation *tagsOperation;
@end

@implementation ZPDetailViewController

#pragma mark - Managing the detail item

-(void)setPhoto:(ZPFlickrPhoto *)newPhoto
{
    if (_photo != newPhoto) {
        _photo = newPhoto;
        
        [self loadTags];
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.photo) {
        __weak ZPDetailViewController *weakSelf = self;
        
        // first set thumbnail since it's probably in cache or else else should be downloaded fast
        [self.imageView setImageWithURL:self.photo.thumbURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image)
            {
                [weakSelf.imageView setImageWithURL:weakSelf.photo.photoURL placeholderImage:image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    if (image)
                    {
                    }
                } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            }
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    self.tagsLabel.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    self.tagsLabel.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load Tags

-(void)loadTags
{
    self.tagsLabel.text = @"";
    [self.tagsOperation cancel];
    
    FKFlickrTagsGetListPhoto *tagsMethod = [[FKFlickrTagsGetListPhoto alloc] init];
    tagsMethod.photo_id = self.photo.identifier;
    
    self.tagsOperation = [[FlickrKit sharedFlickrKit] call:tagsMethod completion:^(NSDictionary *response, NSError *error) {
        NSMutableString *tags = [[NSMutableString alloc] init];
        BOOL first = YES;
        for (NSString *tag in [response valueForKeyPath:@"photo.tags.tag._content"])
        {
            if (first)
            {
                first = NO;
            }
            else
            {
                [tags appendString:@", "];
            }
            [tags appendString:tag];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (tags.length == 0)
            {
                self.tagsLabel.text = @"No Tags!";
                self.tagsLabel.textColor = [UIColor redColor];
            }
            else
            {
                self.tagsLabel.text = tags;
                self.tagsLabel.textColor = [UIColor whiteColor];
            }
        });
    }];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
