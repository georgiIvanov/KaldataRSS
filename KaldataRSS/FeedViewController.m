//
//  ViewController.m
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import "FeedViewController.h"
#import "ConnectionHelper.h"
#import "FeedManager.h"
#import "FeedItem.h"
#import "UIControlsFactory.h"
#import "FeedDetailsViewController.h"

@interface FeedViewController ()
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSDictionary* feed;
@property (nonatomic, strong) NSArray* sections;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UILabel *feedCountLabel;
@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, assign) CGFloat screenHeight;


@end

@implementation FeedViewController
{
    FeedManager* _fm;
    FeedItem* _selectedFeed;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _feed = [[NSDictionary alloc] init];
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(feedUpdated)
                                                 name:FeedFetched object:nil];
    _fm = [FeedManager feedManager];
    [_fm updateFeed];
    
    
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;

    UIImage *background = [UIImage imageNamed:@"dogeBg"];
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:self.backgroundImageView];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    [self.view addSubview:self.tableView];
    
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    CGFloat inset = 20;
    CGFloat feedCountHeight = 110;
    CGFloat textHeight = 40;
    CGRect newEntriesFrame = CGRectMake(inset,
                                  headerFrame.size.height - textHeight,
                                  headerFrame.size.width - (2 * inset),
                                  textHeight);
    CGRect feedCount = CGRectMake(inset ,
                                         headerFrame.size.height - (feedCountHeight + textHeight),
                                         headerFrame.size.width - (2 * inset),
                                         feedCountHeight);
    
    
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    NSString* helveticaLight = @"HelveticaNeue-Light";
    self.feedCountLabel = [UIControlsFactory createLabel:feedCount fontSize:120 fontName:helveticaLight];
    [header addSubview:self.feedCountLabel];
    
    UILabel *entriesTextLabel = [UIControlsFactory createLabel:newEntriesFrame fontSize:30 fontName:helveticaLight];
    entriesTextLabel.text = @"New Entries";
    [header addSubview:entriesTextLabel];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
//    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:FeedDetailsSegue])
    {
        FeedDetailsViewController* vc = (FeedDetailsViewController*)segue.destinationViewController;
        vc.feedItem = _selectedFeed;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)feedUpdated
{
    _feed = [_fm getFeed];
    _sections = [_fm getSections];
    [self.tableView reloadData];
    
    self.feedCountLabel.text = [[NSString alloc] initWithFormat:@"%d", [_fm newEntries]];
    NSLog(@"FU");
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_sections count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sections[section];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString* key = _sections[section];
    
    NSArray* arr = _feed[key];
    
    return [arr count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    FeedItem* feedItem = [self getFeedFromPathIndex:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    float alpha;
    if(feedItem.isRead)
    {
        alpha = 0.1;
    }
    else
    {
        alpha = 0.3;
    }
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = feedItem.title;
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedFeed = [self getFeedFromPathIndex:indexPath];
    
    [self performSegueWithIdentifier:FeedDetailsSegue sender:self];
    
}

-(FeedItem*)getFeedFromPathIndex:(NSIndexPath*)indexPath
{
    NSString* key = [_sections objectAtIndex:indexPath.section];
    NSArray* rowsInSection = [_feed valueForKey:key];
    FeedItem* feedItem = rowsInSection[indexPath.item];

    return feedItem;
}

@end
