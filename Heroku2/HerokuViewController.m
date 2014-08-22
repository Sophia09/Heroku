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
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    refreshButton.enabled = YES;
    self.navigationItem.leftBarButtonItem = refreshButton;
    
    self.view.backgroundColor = [UIColor grayColor];

    // Add a table view to show contents
    self.herokuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)
                                                        style:UITableViewStylePlain];
    self.herokuTableView.delegate = self;
    self.herokuTableView.dataSource = self;
    [self.view addSubview:self.herokuTableView];
    
    // Add a spinner to the view
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame = CGRectMake(100, 100, 23, 23);
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
//    self.herokuTableView.allowsSelection = NO;
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
        
        NSDictionary *theDictionary = [NSDictionary dictionaryWithJSONString:theJSONString error:&error];

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
    UIFont *titleFont =  [UIFont systemFontOfSize:17];
    CGSize constraint = CGSizeMake(kTitleLableWidth, 20000);
    return [title sizeWithFont:titleFont
                       constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)descritionLabelSie:(NSString *)description
{
    UIFont *descriptionFont =  [UIFont systemFontOfSize:12];
    CGSize constraint = CGSizeMake(kDescriptionLabelWidth, 20000);
    return [description sizeWithFont:descriptionFont
                                   constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return 44.0;
    
    CGFloat cellHeight = 0;
    Hero *hero = [dataSource objectAtIndex:indexPath.row];
    NSString *title = hero.title;
    NSString *description = hero.description;
    NSString *imageHref = hero.imageHref;
    
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
        cellHeight += descriptionLabelSize.height;
    
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
    
    Hero *hero = [dataSource objectAtIndex:indexPath.row];
    NSString *title = hero.title;
    NSString *description = hero.description;
    NSString *imageHref = hero.imageHref;
    
    if (!title) {
        [[cell.contentView viewWithTag:1] removeFromSuperview];
    }
    else
    {
        // Show title label
        UILabel *titleLabel =  (UILabel *)[cell.contentView viewWithTag:1];
        
        UIFont *titleFont =  [UIFont systemFontOfSize:17];//[UIFont fontWithName:""  size:];

        if (!titleLabel) {
            titleLabel = [[UILabel alloc] init];
            titleLabel.font = titleFont;
            titleLabel.textColor = [UIColor blueColor];
            titleLabel.tag = 1;
            titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            titleLabel.backgroundColor = [UIColor redColor];
            
            // Set numberOfLines to zero to show multiple lines
            titleLabel.numberOfLines = 0;
            [cell.contentView addSubview:titleLabel];
        }
        // update title label frame and text
       
        CGSize size = [self titleLabelSize:title];
        titleLabel.frame = CGRectMake(0, 0, kTitleLableWidth, size.height);
        
        titleLabel.text = title;
    }
    
    if (!description) {
        [[cell.contentView viewWithTag:2] removeFromSuperview];
    }
    else
    {
        // Show description label
        UILabel *descriptionLabel =  (UILabel *)[cell.contentView viewWithTag:2];
        UIFont *descriptionFont = [UIFont systemFontOfSize:12];//[UIFont fontWithName: size:];
        
        if (!descriptionLabel) {
            descriptionLabel = [[UILabel alloc] init];
            descriptionLabel.font = descriptionFont;
            descriptionLabel.textColor = [UIColor blackColor];
            descriptionLabel.tag = 2;
            descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
            descriptionLabel.numberOfLines = 0;
            descriptionLabel.backgroundColor = [UIColor greenColor];
            [cell.contentView addSubview:descriptionLabel];
        }
        
        CGSize size = [self descritionLabelSie:description];
        UILabel *titleLabel =  (UILabel *)[cell.contentView viewWithTag:1];
        CGFloat yOffset = titleLabel ? (titleLabel.frame.origin.y + titleLabel.frame.size.height) : 0;
        descriptionLabel.frame = CGRectMake(0, yOffset, kDescriptionLabelWidth, size.height);
        descriptionLabel.text = description;
    }
    
    if (!imageHref) {
        [[cell.contentView viewWithTag:3] removeFromSuperview];
    }
    else
    {
        // Show image view
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:3];
        if (!imageView) {
            imageView = [[UIImageView alloc] init];
            imageView.tag = 3;
            [cell.contentView addSubview:imageView];
        }
        
        // Do not show the image from resuable cell
        imageView.image = nil;
        
        NSString *urlString = ((Hero *)[dataSource objectAtIndex:indexPath.row]).imageHref;
        NSString *imageName = [NSString stringWithFormat:@"%@%d", kCachedImagePrefix, indexPath.row];
        NSString *extension = [urlString substringFromIndex:(urlString.length - 3)];
        
        // If the image for this cell is already exist, show it directly.
        if ([ImageUtility imageExists:imageName
                               ofType:extension])
        {
            imageView.image = [ImageUtility loadImage:imageName ofType:extension];
        }
        else
        {
            // Download image from server
            UIActivityIndicatorView *imageSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            imageSpinner.frame = CGRectMake(20, 20, 23, 23);
            [imageView addSubview:imageSpinner];
            [imageSpinner startAnimating];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSURL *url = [NSURL URLWithString:urlString];
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                if (imageData) {
                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                    
                    UITableViewCell *cell = [self.herokuTableView cellForRowAtIndexPath:indexPath];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:3];
                        imageView.image = image;
                        [imageSpinner stopAnimating];
                        [imageSpinner removeFromSuperview];
                        
                        [ImageUtility saveImage:image withFileName:imageName ofType:extension];
                    });
                }
                else
                {
                    NSLog(@"cell %d %@ is unavailable.", indexPath.row, urlString);
                    [imageSpinner stopAnimating];
                    [imageSpinner removeFromSuperview];
                    imageView.image = [UIImage imageNamed:@"noImage.png"];
                }
            });
        }
        
        UILabel *titleLabel =  (UILabel *)[cell.contentView viewWithTag:1];
        CGFloat yOffset = titleLabel ? (titleLabel.frame.origin.y + titleLabel.frame.size.height) : 0;
        
        CGFloat xOffset = cell.frame.size.width - kImageWidth - kMargin;
        
        imageView.frame = CGRectMake(xOffset, yOffset, kImageWidth, kImageHeight);
        imageView.contentMode = UIViewContentModeScaleToFill;
        
    }
    return cell;
}

@end
