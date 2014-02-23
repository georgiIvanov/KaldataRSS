//
//  FeedManager.m
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import "FeedManager.h"
#import "ConnectionHelper.h"
#import "FeedItem.h"
#import "FeedXMLItem.h"
#import "DataStore.h"
#import "FeedParser.h"
#import <TSMessage.h>

@interface FeedManager()

@property(nonatomic, strong) NSMutableDictionary* feed;
@property(nonatomic, strong) NSMutableArray* sections;
@property(nonatomic, strong) NSArray* feedArray;
@property(nonatomic, strong) NSArray* searchResult;

@end

@implementation FeedManager
{
    NSDate* _mostRecentFeedDate;
    FeedParser* _feedParser;
}

static FeedManager* _feedManager;

+(FeedManager*)feedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _feedManager = [[FeedManager alloc] init];
    });
    
    return _feedManager;
}

-(instancetype)init
{
    self = [super init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if( [defaults valueForKey:LastFetchedFeedDate])
    {
        _mostRecentFeedDate = [defaults valueForKey:LastFetchedFeedDate];
        
    }
//    _feed = [[NSMutableDictionary alloc] init];
    _feedParser = [[FeedParser alloc]init];
    
    return self;
}

-(BOOL)getFeedFromLocalStorage
{
    DataStore* ds = [DataStore dataStore];
    
    
    NSFetchRequest* fetch = [[NSFetchRequest alloc] initWithEntityName:@"FeedItem"];
    NSSortDescriptor* sortDesc = [[NSSortDescriptor alloc] initWithKey:@"publishDate" ascending:NO];
    fetch.sortDescriptors = @[sortDesc];
    
    NSError* error;
    self.feedArray = [ds.context executeFetchRequest:fetch error:&error];
    self.feed = [[NSMutableDictionary alloc] init];
    self.sections = [[NSMutableArray alloc] init];
    for (FeedItem* item in self.feedArray) {
        if([_feed objectForKey:item.formattedDate])
        {
            NSMutableArray* arr = [_feed objectForKey:item.formattedDate];
            [arr addObject:item];
        }
        else
        {
            NSMutableArray* arr = [[NSMutableArray alloc] init];
            [arr addObject:item];
            [self.feed setObject:arr forKey:item.formattedDate];
            [self.sections addObject:item.formattedDate];
        }
    }
    
    if(error) {
        
        return NO;
    }
    else{
        return YES;
    }
}

-(void)fetchFeedFromKaldata
{
    [[ConnectionHelper connection] getRSSAsync:KaldataRSSUrl completion:	^(NSData* data, NSError* error){
        NSArray* xmlFeedObjects = [_feedParser parseData:data afterDate:_mostRecentFeedDate];
        if(error == nil)
        {
            [self saveToLocalStorage:xmlFeedObjects];
        }
        else
        {
            [self reportError:NetworkProblem];
        }
        
        if([self getFeedFromLocalStorage])
        {
            self.newEntries = [xmlFeedObjects count];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self notifyUpdateIsDone];
            });
        }
        else
        {
            [self reportError:CouldNotGetLocalData];
        }

    }];

}

-(void)searchByTitle:(NSString*)title beforeDate:(NSDate*)beforeDate afterDate:(NSDate*)afterDate
{
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         
         NSPredicate *datePredicate;
         if(afterDate != nil && beforeDate != nil)
         {
             datePredicate = [NSPredicate predicateWithFormat:@"((publishDate <= %@) AND (publishDate >= %@))",afterDate, beforeDate];
         }
         else
         {
             if(afterDate)
             {
                 datePredicate = [NSPredicate predicateWithFormat:@"publishDate >= %@",afterDate];
             }
             else if(beforeDate)
             {
                 datePredicate = [NSPredicate predicateWithFormat:@"publishDate <= %@", beforeDate];
             }
         }
         
         NSPredicate* titlePredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", title];
         NSPredicate* compoundPredicate;
         if([title isEqualToString:@""] && datePredicate != nil)
         {
             compoundPredicate = datePredicate;
         }
         
         if(datePredicate != nil && ![title isEqualToString:@""])
         {
          compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[titlePredicate, datePredicate]];
         }
         
         if(datePredicate == nil)
         {
             compoundPredicate = titlePredicate;
         }
         
         DataStore* ds = [DataStore dataStore];
         NSFetchRequest* fetch = [[NSFetchRequest alloc] initWithEntityName:@"FeedItem"];
         
         
         
         [fetch setPredicate:compoundPredicate];
         
         
         NSError* error;
         self.searchResult = [ds.context executeFetchRequest:fetch error:&error];

         if(error == nil)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self searchDone];
             });
         }

     });
    
    
}

-(void)saveToLocalStorage:(NSArray*)xmlFeedObjects
{
    DataStore* ds = [DataStore dataStore];
    
    for (FeedXMLItem* item in xmlFeedObjects) {
        
        FeedItem* myFeed = (FeedItem*)[NSEntityDescription insertNewObjectForEntityForName:FeedEntityName inManagedObjectContext:ds.context];
        
        myFeed.title = item.title;
        myFeed.feedDescription = item.feedDescription;
        myFeed.link = item.link;
        myFeed.publishDate = item.publishDate;
        myFeed.formattedDate = item.formattedDate;
        myFeed.isRead = NO;
    }
    
    if([xmlFeedObjects count] > 0 && [ds saveChanges])
    {
        FeedXMLItem* feed = [xmlFeedObjects firstObject];
        _mostRecentFeedDate = [feed.publishDate copy];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_mostRecentFeedDate forKey:LastFetchedFeedDate];
        [defaults synchronize];

    }
}

-(void)reportError:(NSString*)subtitle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [TSMessage showNotificationWithTitle:@"Error"
                                    subtitle:subtitle
                                        type:TSMessageNotificationTypeError];
    });
    
}

-(void)searchDone
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SearchDone object:nil];
}

-(void)updateFeed
{
    [self fetchFeedFromKaldata];
}

-(void)save
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DataStore* ds = [DataStore dataStore];
        [ds saveChanges];
    });

}

-(NSDictionary*)getFeed
{
    return [[NSDictionary alloc]initWithDictionary:self.feed];
}

-(NSArray *)getSearchResult
{
    return self.searchResult;
}

-(NSArray*)getFeedAsArray
{
    return self.feedArray;
}

-(NSArray*)getSections
{
    return [[NSArray alloc] initWithArray:self.sections];
}

-(void)notifyUpdateIsDone
{
    [[NSNotificationCenter defaultCenter] postNotificationName:FeedFetched object:nil];
}

@end
