//
//  Configuration.m
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import "Configuration.h"

NSString* const KaldataRSSUrl = @"http://www.kaldata.com/rosebud/rss.php?catid=2";

NSString* const LastFetchedFeedDate = @"lffd";

NSString* const FeedEntityName = @"FeedItem";


// event names
NSString* const FeedFetched = @"feedFetched";

// segue names
NSString* const FeedDetailsSegue = @"feedDetailsSegue";

// error texts
NSString* const NetworkProblem = @"There was a problem fetching feed.";

NSString* const CouldNotGetLocalData = @"There was a problem fetching local data.";