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
NSString* const FeedReadThroughDetails = @"frtd";
NSString* const SearchDone = @"searchDone";

// segue names
NSString* const FeedDetailsSegue = @"feedDetailsSegue";
NSString* const WebViewSegue = @"webViewSegue";
NSString* const SearchSegue = @"searchSegue";


// error texts
NSString* const NetworkProblem = @"There was a problem fetching feed.";

NSString* const CouldNotGetLocalData = @"There was a problem fetching local data.";

// fonts
NSString* const HelveticaLight = @"HelveticaNeue-Light";
NSString* const HelveticaUltraLight = @"HelveticaNeue-UltraLight";

// ui text
NSString* const ViewOnlineText = @"View Full Article";

// image names
NSString* const BackgroundImage = @"dogeBg";
NSString* const SearchImage = @"searchIcon";