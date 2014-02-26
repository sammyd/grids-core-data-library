//
//  Book+Description.m
//  Library
//
//  Created by Alison Clarke on 17/02/2014.
//  Copyright (c) 2014 Alison Clarke. All rights reserved.
//

#import "Book+LibraryManagedObject.h"

@implementation Book (Description)

+ (NSString*) sortField {
    return @"title";
}

- (NSString *)description {
    return self.title;
}

@end
