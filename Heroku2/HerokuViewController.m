//
//  HerokuViewController.m
//  Heroku2
//
//  Created by lisai  on 8/21/14.
//  Copyright (c) 2014 thoughtworks. All rights reserved.
//

#import "HerokuViewController.h"
#import "Constants.h"
#import "NSDictionary_JSONExtensions.h"
#import "Hero.h"
#import "ImageUtility.h"

@interface HerokuViewController ()
{
    NSMutableArray *dataSource;
}

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UITableView *herokuTableView;

@end

@implementation HerokuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Set UI of navigationItem
    self.navigationItem.title = @"Heroku";
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    refreshButton.enabled = YES;
    self.navigationItem.leftBarButtonItem = refreshButton;
    
    self.view.backgroundColor = [UIColor grayColor];

    // Add a table view to show contents
    self.herokuTableView = [[UITableView alloc]
                            initWithFrame:CGRectMake(0,
                                                     0,
                                                     self.view.frame.size.width,
                                                     self.view.frame.size.height - 44)
                            style:UITableViewStylePlain];
    self.herokuTableView.allowsSelection = NO;
    self.herokuTableView.delegate = self;
    self.herokuTableView.dataSource = self;
    [self.view addSubview:self.herokuTableView];
    
    // Add a spinner to the view
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame = CGRectMake(150, 100, 23, 23);
    self.spinner.hidesWhenStopped = YES;
    [self.view addSubview:self.spinner];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helper methods

- (void)refresh:(id)sender
{
    [ImageUtility deleteImageWithPrefix:kCachedImagePrefix];
    [self.spinner startAnimating];
     self.navigationItem.leftBarButtonItem.enabled = NO;
    [self updateJSON];
}

- (void)updateJSON
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // Download data from server
        NSError *error;
        NSString *urlString = @"http://thoughtworks-ios.herokuapp.com/facts.json";
        NSString *theJSONString =[NSString stringWithContentsOfURL:[NSURL URLWithString:urlString]
                                                          encoding:NSUTF8StringEncoding
                                                             error:&error];
        
        NSDictionary *theDictionary = [NSDictionary dictionaryWithJSONString:theJSONString
                                                                       error:&error];

        NSArray *heroList = [theDictionary objectForKey:kRows];
        [self filterData:heroList];
        
        // Update UI when finished downloading data
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.title = [theDictionary objectForKey:kTitle];
            [self.spinner stopAnimating];
            self.navigationItem.leftBarButtonItem.enabled = YES;
            [self.herokuTableView reloadData];
        });
    });
}

// Remove item without any info
- (void)filterData:(NSArray *)heroData
{
    if (!dataSource)
    {
        dataSource = [[NSMutableArray alloc] init];
    }
    else
    {
        [dataSource removeAllObjects];
    }
    
    for (NSDictionary *dataDic in heroData)
    {
        NSString *title = [dataDic objectForKey:kTitle_subLayer];
        NSString *description = [dataDic objectForKey:kDescription];
        NSString *imageHref = [dataDic objectForKey:kImageHref];
        if (!([title isKindOfClass:[NSNull class]] &&
            [description isKindOfClass:[NSNull class]] &&
            [imageHref isKindOfClass:[NSNull class]]))
        {
            Hero *hero = [[Hero alloc] init];
            hero.title = [title isKindOfClass:[NSNull class]] ? nil : title;
            hero.description = [description isKindOfClass:[NSNull class]] ? nil : description;
            hero.imageHref = [imageHref isKindOfClass:[NSNull class]] ? nil : imageHref;
            [dataSource addObject:hero];
        }
    }
}

- (CGSize)titleLabelSize:(NSString *)title
{
    UIFont *titleFont =  [UIFont systemFontOfSize:kTitleLabelFontSize];
    CGSize constraint = CGSizeMake(kTitleLableWidth, 20000);
    return [title sizeWithFont:titleFont
                       constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)descritionLabelSie:(NSString *)description
{
    UIFont *descriptionFont =  [UIFont systemFontOfSize:kDescriptionLabelFontSize];
    CGSize constraint = CGSizeMake(kDescriptionLabelWidth, 20000);
    return [description sizeWithFont:descriptionFont
                                   constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get info to show at index path
    Hero *hero = [dataSource objectAtIndex:indexPath.row];
    NSString *title = hero.title;
    NSString *description = hero.description;
    NSString *imageHref = hero.imageHref;
    
    CGFloat cellHeight = 0;
    
    CGSize titleLabelSize = CGSizeZero;
    CGSize descriptionLabelSize = CGSizeZero;
    
    if (title)
    {
        titleLabelSize = [self titleLabelSize:title];
        cellHeight += titleLabelSize.height;
    }
    if (description)
    {
        descriptionLabelSize = [self descritionLabelSie:description];
    }
    if (imageHref)
    {
        cellHeight += (descriptionLabelSize.height > kImageHeight ? descriptionLabelSize.height : kImageHeight);
    }
    else
    {
        cellHeight += descriptionLabelSize.height;
    }
    
    return cellHeight;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HerokuCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Get info to show at index path
    Hero *hero = [dataSource objectAtIndex:indexPath.row];
    NSString *title = hero.title;
    NSString *description = hero.description;
    NSString *imageHref = hero.imageHref;
    
    // Remove title label if there is no title for the current cell
    if (!title)
    {
        [[cell.contentView viewWithTag:kTitleLabelTag] removeFromSuperview];
    }
    else
    {
        // Show title label
        UILabel *titleLabel =  (UILabel *)[cell.contentView viewWithTag:kTitleLabelTag];

        if (!titleLabel)
        {
            // Set attribute of title label
            titleLabel = [[UILabel alloc] init];
            titleLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];//[UIFont fontWithName:""  size:];;
            titleLabel.textColor = [UIColor blueColor];
            titleLabel.tag = kTitleLabelTag;
            titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//            titleLabel.backgroundColor = [UIColor redColor];
            
            // Set numberOfLines to zero to show multiple lines
            titleLabel.numberOfLines = 0;
            
            // Add a title label to cell.contentView
            [cell.contentView addSubview:titleLabel];
        }
        
        // update frame and text of title label
        CGSize size = [self titleLabelSize:title];
        titleLabel.frame = CGRectMake(0, 0, kTitleLableWidth, size.height);
        titleLabel.text = title;
    }
    
    if (!description)
    {
        [[cell.contentView viewWithTag:kDescriptionLabelTag] removeFromSuperview];
    }
    else
    {
        // Show description label
        UILabel *descriptionLabel =  (UILabel *)[cell.contentView viewWithTag:kDescriptionLabelTag];
        
        if (!descriptionLabel)
        {
            // Set attributes of description label
            descriptionLabel = [[UILabel alloc] init];
            descriptionLabel.font = [UIFont systemFontOfSize:kDescriptionLabelFontSize];//[UIFont fontWithName: size:];;
            descriptionLabel.textColor = [UIColor blackColor];
            descriptionLabel.tag = kDescriptionLabelTag;
            descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
            descriptionLabel.numberOfLines = 0;
//            descriptionLabel.backgroundColor = [UIColor greenColor];
            [cell.contentView addSubview:descriptionLabel];
        }
        
        // update frame and text of description label
        CGSize size = [self descritionLabelSie:description];
        UILabel *titleLabel =  (UILabel *)[cell.contentView viewWithTag:kTitleLabelTag];
        CGFloat yOffset = titleLabel ? (titleLabel.frame.origin.y + titleLabel.frame.size.height) : 0;
        descriptionLabel.frame = CGRectMake(0, yOffset, kDescriptionLabelWidth, size.height);
        descriptionLabel.text = description;
    }
    
    if (!imageHref)
    {
        [[cell.contentView viewWithTag:kImageViewTag] removeFromSuperview];
    }
    else
    {
        // Show image view
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kImageViewTag];
        if (!imageView)
        {
            imageView = [[UIImageView alloc] init];
            imageView.backgroundColor = [UIColor lightGrayColor];
            imageView.tag = kImageViewTag;
            [cell.contentView addSubview:imageView];
        }
        
        // Do not show the image from resuable cell
        imageView.image = nil;
        
        NSString *urlString = ((Hero *)[dataSource objectAtIndex:indexPath.row]).imageHref;
        NSString *imageName = [NSString stringWithFormat:@"%@%d", kCachedImagePrefix, (int)indexPath.row];
        NSString *extension = [urlString substringFromIndex:(urlString.length - 3)];
        
        // If the image for this cell is already exist, show it directly.
        if ([ImageUtility imageExists:imageName
                               ofType:extension])
        {
            imageView.image = [ImageUtility loadImage:imageName ofType:extension];
        }
        else
        {
            // Download image from server and save them for reuse
            UIActivityIndicatorView *imageSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            imageSpinner.frame = CGRectMake((kImageWidth - 23) / 2.0f,
                                            (kImageHeight - 23) / 2.0f,
                                            23,
                                            23);
            [imageView addSubview:imageSpinner];
            [imageSpinner startAnimating];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSURL *url = [NSURL URLWithString:urlString];
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                if (imageData) {
                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                    
                    UITableViewCell *cell = [self.herokuTableView cellForRowAtIndexPath:indexPath];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kImageViewTag];
                        imageView.image = image;
                        [imageSpinner stopAnimating];
                        [imageSpinner removeFromSuperview];
                        
                        [ImageUtility saveImage:image withFileName:imageName ofType:extension];
                    });
                }
                else
                {
                    NSLog(@"cell %d %@ is unavailable.", (int)indexPath.row, urlString);
                    [imageSpinner stopAnimating];
                    [imageSpinner removeFromSuperview];
                    imageView.image = [UIImage imageNamed:@"noImage.jpg"];
                }
            });
        }
        
        // Update frame of image view
        UILabel *titleLabel =  (UILabel *)[cell.contentView viewWithTag:kTitleLabelTag];
        CGFloat yOffset = titleLabel ? (titleLabel.frame.origin.y + titleLabel.frame.size.height) : 0;
        CGFloat xOffset = cell.frame.size.width - kImageWidth - kMargin;
        imageView.frame = CGRectMake(xOffset, yOffset, kImageWidth, kImageHeight);
        imageView.contentMode = UIViewContentModeScaleToFill;
        
    }
    return cell;
}

@end
