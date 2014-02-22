//
//  ConnectionHelper.m
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import "ConnectionHelper.h"

@implementation ConnectionHelper

static ConnectionHelper* mainHelper;
static NSOperationQueue* queue;

+(ConnectionHelper*)connection
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainHelper = [[ConnectionHelper alloc] init];
    });
    
    return mainHelper;
}

-(NSOperationQueue*)internalQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
    });
    
    return queue;
}

-(void)getRSSAsync:(NSString*)url completion:(void (^)(NSData* data, NSError* error))completion
{
    NSURL* requestURL = [NSURL URLWithString:url];
    NSURLRequest* request = [NSURLRequest requestWithURL:requestURL];
    [NSURLConnection sendAsynchronousRequest:request queue:[self internalQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
            
        completion(data, connectionError);
        
    }];
}


@end
