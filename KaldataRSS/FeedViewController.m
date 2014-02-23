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
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>


@interface FeedViewController ()
<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UILabel *theNewFeedCountLabel;
@property (nonatomic, assign) NSUInteger theNewFeedCount;
@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, assign) CGFloat screenHeight;


@property (nonatomic, strong) NSDictionary* feed;
@property (nonatomic, strong) NSArray* sections;

@end

@implementation FeedViewController
{
    FeedManager* _fm;
    NSIndexPath* _indexPathOfSelectedItem;
    BOOL _firstLoad;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _firstLoad = YES;
    _feed = [[NSDictionary alloc] init];
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(feedUpdated)
                                                 name:FeedFetched object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decrementNewFeedCounter) name:FeedReadThroughDetails object:nil];
    _fm = [FeedManager feedManager];
    [_fm updateFeed];
    
    
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;

    UIImage *background = [UIImage imageNamed:BackgroundImage];
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];

    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    [self.view addSubview:self.tableView];
    
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    static CGFloat inset = 20;
    static CGFloat feedCountHeight = 110;
    static CGFloat textHeight = 40;
    static CGFloat searchBtnSide = 60;
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
    
    self.theNewFeedCountLabel = [UIControlsFactory createLabel:feedCount fontSize:120 fontName:HelveticaLight];
    [header addSubview:self.theNewFeedCountLabel];
    
    UILabel *entriesTextLabel = [UIControlsFactory createLabel:newEntriesFrame fontSize:30 fontName:HelveticaLight];
    entriesTextLabel.text = @"New Entries";
    [header addSubview:entriesTextLabel];
    
    UIButton* searchButton = [[UIButton alloc] initWithFrame:CGRectMake(feedCount.origin.x, feedCount.origin.y - feedCountHeight, searchBtnSide, feedCount.size.height + textHeight)];
    [searchButton addTarget:self
                  action:@selector(goToSearch)
        forControlEvents:UIControlEventTouchUpInside];
        UIImage* btnImage = [UIImage imageNamed:SearchImage];
    [searchButton setImage:btnImage forState:UIControlStateNormal];
    [header addSubview:searchButton];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

-(void)viewWillAppear:(BOOL)animated
{
    if(!_firstLoad)
    {
        [_fm updateFeed];
    }
    else
    {
        _firstLoad = NO;
    }
}

-(void)goToSearch
{
    [self performSegueWithIdentifier:SearchSegue sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:FeedDetailsSegue])
    {
        FeedDetailsViewController* vc = (FeedDetailsViewController*)segue.destinationViewController;
        
        NSUInteger sectionsRows = 0;
        for (int i = 0; i < _indexPathOfSelectedItem.section; i++)
        {
            sectionsRows += [self tableView:self.tableView numberOfRowsInSection:i];
        }
        sectionsRows += _indexPathOfSelectedItem.row;
        
        
        vc.feedIndex = sectionsRows;
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
    [self updateNewFeedCounter:[_fm newEntries]];
}

-(void)updateNewFeedCounter:(NSUInteger)count
{
    self.theNewFeedCount += count;
    self.theNewFeedCountLabel.text = [[NSString alloc] initWithFormat:@"%d", self.theNewFeedCount];
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
    _indexPathOfSelectedItem = indexPath;
    FeedItem* item = [self getFeedFromPathIndex:indexPath];
    
    if(!item.isRead)
    {
        item.isRead = @1;
        [_fm save];
        [self.tableView reloadData];
        [self decrementNewFeedCounter];
    }
    
    [self performSegueWithIdentifier:FeedDetailsSegue sender:self];
    
}

-(void)decrementNewFeedCounter
{
    if(self.theNewFeedCount > 0)
    {
        [self updateNewFeedCounter:-1];
    }
}

-(FeedItem*)getFeedFromPathIndex:(NSIndexPath*)indexPath
{
    NSString* key = [_sections objectAtIndex:indexPath.section];
    NSArray* rowsInSection = [_feed valueForKey:key];
    FeedItem* feedItem = rowsInSection[indexPath.item];

    return feedItem;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    CGFloat percent = MIN(position / height, 1.0);
    self.blurredImageView.alpha = percent;
}

@end
