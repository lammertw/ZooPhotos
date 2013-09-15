//
//  ZPMasterViewController.m
//  ZooPhotos
//
//  Created by Lammert Westerhoff on 9/15/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import "ZPMasterViewController.h"

#import "ZPDetailViewController.h"

#import <FlickrKit/FlickrKit.h>
#import "ZPFlickrPhoto.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <SDNetworkActivityIndicator/SDNetworkActivityIndicator.h>
#import "CBGLocationManager.h"

#warning Change Flickr API & SECRET

#define FLICKR_API_KEY @""
#define FLICKR_SECRET @""

#define PRAGUE_ZOO_COORDINATE CLLocationCoordinate2DMake(50.118154, 14.405133)
#define AMSTERDAM_ZOO_COORDINATE CLLocationCoordinate2DMake(52.36618, 4.91537)

@interface Tag : NSObject

@property (copy, nonatomic) NSString *tag;
@property (nonatomic) BOOL selected;

+(Tag*)tag:(NSString *)tag selected:(BOOL)selected;

@end

@implementation Tag

+(Tag *)tag:(NSString *)tagString selected:(BOOL)selected
{
    Tag *tag = [[Tag alloc] init];
    tag.tag = tagString;
    tag.selected = selected;
    return tag;
}

@end

@interface ZPMasterViewController ()<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *locationControl;
@property (strong, nonatomic) IBOutlet UITableView *tagsTableView;
@property (strong, nonatomic) IBOutlet UICollectionView *thumbsCollectionView;

@property (strong, nonatomic) NSMutableArray *tags;

@property (weak, nonatomic) NSOperation *currentRequest;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) IBOutlet UITextField *tagField;

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation ZPMasterViewController

- (void)awakeFromNib
{
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[FlickrKit sharedFlickrKit] initializeWithAPIKey:FLICKR_API_KEY sharedSecret:FLICKR_SECRET];

    self.detailViewController = (ZPDetailViewController *)[self.splitViewController.viewControllers lastObject];
    
    self.tags = @[[Tag tag:@"zoo" selected:YES], [Tag tag:@"animal" selected:YES]].mutableCopy;
    self.coordinate = PRAGUE_ZOO_COORDINATE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    _coordinate = coordinate;
    [self requestPhotos];
}

- (IBAction)changeLocation:(id)sender {
    if (self.locationControl.selectedSegmentIndex == 0)
    {
        self.coordinate = PRAGUE_ZOO_COORDINATE;
    }
    else if (self.locationControl.selectedSegmentIndex == 1)
    {
        self.coordinate = AMSTERDAM_ZOO_COORDINATE;
    }
    else
    {
        [[CBGLocationManager sharedManager] locationRequest:^(CLLocation * location, NSError * error) {
            if (!error)
            {
                self.coordinate = location.coordinate;
            }
        }];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Tag *tag = self.tags[indexPath.row];
    cell.textLabel.text = tag.tag;
    cell.accessoryType = tag.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tags removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self requestPhotos];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
- (IBAction)addTag:(id)sender {
    if (self.tagField.text.length > 1)
    {
        [self.tags insertObject:[Tag tag:self.tagField.text selected:YES] atIndex:0];
        [self.tagsTableView reloadData];
        [self requestPhotos];
        self.tagField.text = @"";
        [self.tagField resignFirstResponder];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
     Tag *tag = self.tags[indexPath.row];
     tag.selected = !tag.selected;
     [self.tagsTableView reloadData];
     
     [self requestPhotos];
}

#pragma mark - Collection View Delegate

-(int)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
    ZPPhoto *photo = self.photos[indexPath.row];
    
    [imageView setImageWithURL:photo.thumbURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    return cell;
}

#pragma mark - Collection View Delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZPFlickrPhoto *photo = self.photos[indexPath.row];
    self.detailViewController.photo = photo;
}

-(void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.thumbsCollectionView reloadData];
}

#pragma mark - Photos Request

-(void)requestPhotos
{
    FKFlickrPhotosSearch *photosSearch = [[FKFlickrPhotosSearch alloc] init];
    photosSearch.lat = [NSNumber numberWithDouble:self.coordinate.latitude].stringValue;
    photosSearch.lon = [NSNumber numberWithDouble:self.coordinate.longitude].stringValue;
    photosSearch.radius = @"1";
    photosSearch.license = @"4,5,6,7";
    
    NSMutableString *tags = [[NSMutableString alloc] init];
    BOOL first = YES;
    for (Tag *tag in self.tags)
    {
        if (tag.selected)
        {
            if (first)
            {
                first = NO;
            }
            else
            {
                [tags appendString:@","];
            }
            [tags appendString:tag.tag];
        }
    }
    
    if (tags.length > 0)
    {
        photosSearch.tags = tags;
    }
    
    [self.currentRequest cancel];
    self.currentRequest = [[FlickrKit sharedFlickrKit] call:photosSearch completion:^(NSDictionary *response, NSError *error) {
        NSMutableArray *photos;
        if (response)
        {
            photos = [NSMutableArray array];
            for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photos.photo"]) {
                
                ZPFlickrPhoto *photo = [[ZPFlickrPhoto alloc] init];
                photo.thumbURL = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeThumbnail100 fromPhotoDictionary:photoDictionary];
                photo.photoURL = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeMedium640 fromPhotoDictionary:photoDictionary];
                
                // Flickr specific
                photo.identifier = [photoDictionary objectForKey:@"id"];
                photo.owner = [photoDictionary objectForKey:@"owner"];
                photo.title = [photoDictionary objectForKey:@"title"];
                
                [photos addObject:photo];
            }
        }
        else
        {
            photos = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = photos;
        });
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.tagField resignFirstResponder];
    return YES;
}

@end
