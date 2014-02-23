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
    
    
    UIImage *background = [UIImage imageNamed:@"dogeBg"];
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

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.scrollView.frame = CGRectMake(screenBounds.origin.x, screenBounds.origin.y + 60, screenBounds.size.width, screenBounds.size.height - 100);
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.feedItems.count, pagesScrollViewSize.height);
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    CGPoint newOffset = CGPointMake(self.scrollView.bounds.origin.x + (pageWidth *  _feedIndex), self.scrollView.bounds.origin.y);
    self.scrollView.contentOffset = newOffset;
    
    [self loadVisiblePages];
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.feedItems.count) {
        return;
    }
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {

        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        FeedItem* item = self.feedItems[page];
        UITextView *newPageView = [[UITextView alloc] initWithFrame:frame];
        newPageView.contentMode = UIViewContentModeScaleAspectFit;
        newPageView.frame = frame;
        newPageView.text = item.feedDescription;
        [self.scrollView addSubview:newPageView];
  
        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
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
