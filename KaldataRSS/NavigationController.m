//
//  NavigationController.m
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import "NavigationController.h"

@implementation NavigationController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationBar setBackgroundImage:[UIImage new]
forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
}


@end
