//
//  FileSystemHelper.m
//  KaldataRSS
//
//  Created by Georgi Ivanov on 2/22/14.
//  Copyright (c) 2014 Georgi Ivanov. All rights reserved.
//

#import "FileSystemHelper.h"

@implementation FileSystemHelper

+(NSURL *)pathForDocumentsFile:(NSString *)filename {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentPath = [directories objectAtIndex:0];
    
    return [documentPath URLByAppendingPathComponent:filename];
    
}

@end
