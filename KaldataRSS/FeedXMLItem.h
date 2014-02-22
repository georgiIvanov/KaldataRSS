//
//  FeedXMLItem.h
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedXMLItem : NSObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * feedDescription;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSDate * publishDate;
@property (nonatomic, retain) NSString * formattedDate;

@end