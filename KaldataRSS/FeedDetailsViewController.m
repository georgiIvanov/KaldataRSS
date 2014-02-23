//
//  FeedDetailsViewController.m
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import "FeedDetailsViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "FeedManager.h"
#import "UIControlsFactory.h"
#import "WebViewController.h"

@interface FeedDetailsViewController()
<UIScrollViewDelegate>
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSArray* feedItems;
@property (nonatomic, strong) NSMutableArray *pageViews;

@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;

@end

@implementation FeedDetailsViewController
{
    FeedManager* _fm;
    FeedItem* _currentFeed;
    CGPoint _offsetBeforeSegue;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    _fm = [FeedManager feedManager];
    self.feedItems = [_fm getFeedAsArray];
    
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    
    NSInteger pageCount = [self.feedItems count];
    self.pageViews = [[NSMutableArray alloc] initWithCapacity:pageCount];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.pageViews addObject:[NSNull null]];
    }
    
    
    UIImage *background = [UIImage imageNamed:BackgroundImage];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0.7;
    [self.blurredImageView setImageToBlur:background blurRadius:1 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];

    [self.view addSubview:self.scrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.scrollView.frame = CGRectMake(bounds.origin.x, bounds.origin.y + 60, bounds.size.width, bounds.size.height - 100);
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.feedItems.count, pagesScrollViewSize.height);
    
    CGFloat pageWidth = bounds.size.width;
    
    if(_offsetBeforeSegue.x == 0)
    {
        CGPoint newOffset = CGPointMake(self.scrollView.bounds.origin.x + (pageWidth *  _feedIndex), self.scrollView.bounds.origin.y);
        self.scrollView.contentOffset = newOffset;
    }
    else
    {
        self.scrollView.contentOffset = _offsetBeforeSegue;
        _offsetBeforeSegue.x = 0;
    }
    [self loadVisiblePages];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:WebViewSegue])
    {
        WebViewController* vc = (WebViewController*)segue.destinationViewController;
        vc.link = _currentFeed.link;
        _offsetBeforeSegue = self.scrollView.contentOffset;
    }
}

-(void)goToWebView
{
    [self performSegueWithIdentifier:WebViewSegue sender:self];
}

#pragma mark - ScrollRelated

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.feedItems.count) {
        return;
    }
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        
        
        static CGFloat headerHeight = 80;
        static CGFloat headerInset = 10;
        static CGFloat buttonInset = 70;
        static CGFloat buttonWidth = 110;
        static CGFloat alpha = 0.6;
        
        FeedItem* item = self.feedItems[page];
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        UIView *detailsView = [[UIView alloc] initWithFrame:frame];
        detailsView.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
        CGRect detailBounds = detailsView.bounds;

        UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(detailBounds.origin.x + headerInset, detailBounds.origin.y, detailBounds.size.width - headerInset, headerHeight)];
        headerLabel.font = [UIFont fontWithName:HelveticaLight size:20];
        headerLabel.text = item.title;
        headerLabel.numberOfLines = 3;
        headerLabel.textColor = [UIColor whiteColor];
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(detailBounds.origin.x, detailBounds.origin.y + headerHeight, detailBounds.size.width, detailBounds.size.height)];
        textView.backgroundColor = [UIColor clearColor];
        
        textView.font = [UIFont fontWithName:HelveticaLight size:16];
        textView.contentMode = UIViewContentModeScaleAspectFit;
        textView.text = item.feedDescription;
        textView.textColor = [UIColor whiteColor];
        textView.editable = NO;
        
        UIButton *viewInWeb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        viewInWeb.frame = CGRectMake(detailBounds.size.width / 2 - buttonWidth / 2 , detailBounds.size.height - buttonInset, buttonWidth, buttonInset);
        [viewInWeb addTarget:self
                   action:@selector(goToWebView)
         forControlEvents:UIControlEventTouchUpInside];
        [viewInWeb setTitle:ViewOnlineText forState:UIControlStateNormal];
        
        [detailsView addSubview:headerLabel];
        [detailsView addSubview:textView];
        [detailsView addSubview:viewInWeb];
        [self.scrollView addSubview:detailsView];
  
        [self.pageViews replaceObjectAtIndex:page withObject:detailsView];
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= self.feedItems.count) {
        return;
    }
    
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

- (void)loadVisiblePages {
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    
    _currentFeed = self.feedItems[page];
    if(!_currentFeed.isRead)
    {
        _currentFeed.isRead = @1;
        [[NSNotificationCenter defaultCenter] postNotificationName:FeedReadThroughDetails object:nil];
        [_fm save];
    }
    
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    
    for (NSInteger i=lastPage+1; i<self.feedItems.count; i++) {
        [self purgePage:i];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
 
    [self loadVisiblePages];
}
@end
