//
//  UIControlsFactory.m
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import "UIControlsFactory.h"

@implementation UIControlsFactory

+(UILabel*)createLabel:(CGRect)rect fontSize:(NSUInteger)size fontName:(NSString*)name
{
    UILabel* newLabel = [[UILabel alloc] initWithFrame:rect];
    newLabel.backgroundColor = [UIColor clearColor];
    newLabel.textColor = [UIColor whiteColor];
    newLabel.font = [UIFont fontWithName:name size:size];

    return newLabel;
}

@end
