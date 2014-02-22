//
//  DataStore.h
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataStore : NSObject

@property(nonatomic, strong) NSManagedObjectContext* context;

+(DataStore*)dataStore;
-(BOOL)saveChanges;


@end
