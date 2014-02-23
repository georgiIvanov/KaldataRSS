//
//  FeedManager.h
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedManager : NSObject

+(FeedManager*)feedManager;

-(void)updateFeed;
-(NSDictionary*)getFeed;
-(NSArray*)getSections;
-(NSArray*)getFeedAsArray;
-(void)save;

@property(nonatomic) NSUInteger newEntries;

@end
