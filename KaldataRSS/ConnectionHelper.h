//
//  ConnectionHelper.h
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionHelper : NSObject

+(ConnectionHelper*)connection;

-(void)getRSSAsync:(NSString*)url completion:(void (^)(NSData* data, NSError* error))completion;

@end
