//
//  DataStore.m
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import "DataStore.h"
#import "FileSystemHelper.h"

@interface DataStore()


@end

@implementation DataStore
{
    NSManagedObjectModel* _model;
}
static DataStore* mainDataStore;

+(DataStore*)dataStore
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainDataStore = [[DataStore alloc] init];
    });
    
    return mainDataStore;
}

-(id)init
{
    self = [super init];
    
    if(self)
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RssModel" withExtension:@"momd"];
        _model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        
        NSURL* dataStoreUrl = [FileSystemHelper pathForDocumentsFile:@"kaldatarss.sqlite"];
        
        
        // clears the db each time the app starts	
//        [[NSFileManager defaultManager] removeItemAtURL:dataStoreUrl error:nil];

        NSError* error = nil;
        if(![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dataStoreUrl options:nil error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        _context = [[NSManagedObjectContext alloc]init];
        [_context setPersistentStoreCoordinator:psc];
    }
    
    
    return self;
}

-(BOOL)saveChanges
{
    NSError* error = nil;
    BOOL saveSuccessful = [_context save:&error];
    if(!saveSuccessful)
    {
        NSLog(@"An error occurred while saving data. Error: %@", [error localizedDescription]);
    }
    
    return saveSuccessful;
}
@end

