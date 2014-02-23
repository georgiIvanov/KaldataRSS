//
//  WebViewController.m
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/23/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import "WebViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

@interface WebViewController()
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@end

@implementation WebViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] init];
    
    NSURL* url = [NSURL URLWithString:self.link];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:req];
    
    UIImage *background = [UIImage imageNamed:BackgroundImage];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0.7;
    [self.blurredImageView setImageToBlur:background blurRadius:1 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];

    [self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    static CGFloat topInset = 60;
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.webView.frame = CGRectMake(bounds.origin.x, bounds.origin.y + topInset, bounds.size.width, bounds.size.height - topInset);
   
}

@end
