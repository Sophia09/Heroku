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
    
#warning change the height of table view
    // Add a table view to show contents
    self.herokuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480 - 44)
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

- (void)updateUI
{
    
}

- (void)refresh:(id)sender
{
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
//        dataSource = [theDictionary objectForKey:kRows];
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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
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
    cell.textLabel.text = hero.title;
    cell.detailTextLabel.text = hero.description;
   
    
    return cell;
}

@end
