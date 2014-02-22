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

@interface FeedViewController ()


@property (nonatomic, strong) NSDictionary* feed;

@end

@implementation FeedViewController
{
    FeedManager* _fm;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(feedUpdated)
                                                 name:FeedFetched object:nil];
    _fm = [FeedManager feedManager];
    [_fm updateFeed];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)feedUpdated
{
    _feed = [_fm getFeed];
    NSLog(@"FU");
}




@end
