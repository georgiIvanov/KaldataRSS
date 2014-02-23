//
//  SearchViewController.m
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/23/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import "SearchViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "FeedManager.h"
#import "FeedItem.h"
#import "FeedDetailsViewController.h"

@interface SearchViewController()
<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) NSArray* searchResults;
@property (weak, nonatomic) IBOutlet UITextField *beforeTextBox;
@property (weak, nonatomic) IBOutlet UITextField *afterTextBox;
- (IBAction)searchButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *dateSearchSwitch;
- (IBAction)toggleDateSearch:(id)sender;


@end

@implementation SearchViewController
{
    NSUInteger _selectedRow;
    FeedManager* _fm;
    UILabel* _currentlyChangingLabel;
    NSDate* _dateBefore;
    NSDate* _dateAfter;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    _fm = [FeedManager feedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSearchResults)
                                                 name:SearchDone object:nil];
    
    UIImage *background = [UIImage imageNamed:BackgroundImage];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0.7;
    [self.blurredImageView setImageToBlur:background blurRadius:1 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    [self.view sendSubviewToBack:self.blurredImageView];
    [self.view sendSubviewToBack:self.backgroundImageView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect bounds = self.view.bounds;
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:FeedDetailsSegue])
    {
        FeedDetailsViewController* vc = (FeedDetailsViewController*)segue.destinationViewController;
        vc.feedIndex = _selectedRow;
        vc.feedItems = self.searchResults;
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)updateSearchResults
{
    self.searchResults = [_fm getSearchResult];
    [self.tableView reloadData];
}
- (IBAction)toggleDateSearch:(id)sender {
    if(self.dateSearchSwitch.isOn)
    {
        [self.afterTextBox setEnabled:YES];
        [self.beforeTextBox setEnabled:YES];
        
    }
    else
    {
        [self.afterTextBox setEnabled:NO];
        [self.beforeTextBox setEnabled:NO];
    }
}

-(void)sendSearch
{
//    22.02.2014
    if(self.dateSearchSwitch.isOn)
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"d.MM.yyyy"];
        
        _dateAfter = [df dateFromString:self.afterTextBox.text];
        _dateBefore = [df dateFromString:self.beforeTextBox.text];
    }
    [_fm searchByTitle:self.searchBar.text beforeDate:_dateBefore afterDate:_dateAfter];
    [self.view endEditing:YES];
    _dateAfter = nil;
    _dateBefore = nil;
}

- (IBAction)searchButtonPressed:(id)sender {
    [self sendSearch];
}

#pragma mark - SearchDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self sendSearch];
    [self.view endEditing:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.searchBar.text  = @"";
}

#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    FeedItem* feedItem = self.searchResults[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = feedItem.title;
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
    [self performSegueWithIdentifier:FeedDetailsSegue sender:self];
}
@end
