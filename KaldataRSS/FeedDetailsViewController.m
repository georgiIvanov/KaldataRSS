//
//  FeedDetailsViewController.m
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import "FeedDetailsViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

@interface FeedDetailsViewController()

@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;

@end

@implementation FeedDetailsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *background = [UIImage imageNamed:@"dogeBg"];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0.7;
    [self.blurredImageView setImageToBlur:background blurRadius:1 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];

}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;

}
@end
