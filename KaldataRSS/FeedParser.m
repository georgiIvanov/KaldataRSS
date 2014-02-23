//
//  FeedSerializer.m
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import "FeedParser.h"
#import "FeedXMLItem.h"


@interface FeedParser()
<NSXMLParserDelegate>

@property (nonatomic) FeedXMLItem* currentItem;
@property (nonatomic) NSMutableArray* currentParseBatch;
@property (nonatomic) NSMutableString *currentParsedCharacterData;


@end

@implementation FeedParser
{
    NSDateFormatter* _dateFormatter;
    NSDateFormatter* _dateForUser;
    BOOL _accumulatingParsedCharacterData;
    BOOL _didAbortParsing;
    NSUInteger _parsedFeedsCounter;
    NSDate* _mostRecentFeedDate;
}

-(id)init
{
    self = [super init];
    
    _currentParsedCharacterData = [[NSMutableString alloc] init];
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateForUser = [[NSDateFormatter alloc] init];
//     Sat, 22 Feb 2014 13:54:13 +0000
    [_dateFormatter setDateFormat:@"ccc, d LLL yyyy H:m:s +0000"];
    [_dateForUser setDateFormat:@"d.MM.yyyy"];
    return self;
}

-(NSArray*)parseData:(NSData*)data afterDate:(NSDate*) date
{
    _mostRecentFeedDate = date;
    _currentParseBatch = [[NSMutableArray alloc] init];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
    
    [parser setDelegate:self];
    [parser parse];
    
    return _currentParseBatch;
}

static NSString * const feedElementName = @"item";
static NSString * const titleElementName = @"title";
static NSString * const descriptionElementName = @"description";
static NSString * const linkElementName = @"link";
static NSString * const pubDateElementName = @"pubDate";

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:feedElementName])
    {
        self.currentItem = [[FeedXMLItem alloc] init];
    }
    else if([elementName isEqualToString:titleElementName] || [elementName isEqualToString:descriptionElementName] || [elementName isEqualToString:linkElementName] || [elementName isEqualToString:pubDateElementName])
    {
        _accumulatingParsedCharacterData = YES;
        [self.currentParsedCharacterData setString:@""];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:feedElementName])
    {
        self.currentItem.formattedDate = [_dateForUser stringFromDate:self.currentItem.publishDate];
        [self.currentParseBatch addObject:self.currentItem];
    }
    else if([elementName isEqualToString:titleElementName])
    {
        if(self.currentItem != nil)
        {
            self.currentItem.title = [[NSString alloc] initWithString:self.currentParsedCharacterData];
        }
    }
    else if([elementName isEqualToString:descriptionElementName])
    {
        if(self.currentItem != nil)
        {
            self.currentItem.feedDescription = [[NSString alloc] initWithString:self.currentParsedCharacterData];
        }
    }
    else if([elementName isEqualToString:linkElementName])
    {
        if(self.currentItem != nil)
        {
            self.currentItem.link = [[NSString alloc] initWithString:self.currentParsedCharacterData];
        }
    }
    else if([elementName isEqualToString:pubDateElementName])
    {
        if(self.currentItem != nil)
        {
            NSDate* date = [_dateFormatter dateFromString:self.currentParsedCharacterData];
            if(_mostRecentFeedDate == nil || [date compare:_mostRecentFeedDate] == NSOrderedDescending)
            {
                self.currentItem.publishDate = date;
            }
            else
            {
                _didAbortParsing = YES;
                [parser abortParsing];
            }
            
        }
    }
    _accumulatingParsedCharacterData = NO;
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_accumulatingParsedCharacterData) {
        [self.currentParsedCharacterData appendString:string];
    }
}

@end
