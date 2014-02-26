//
//  Sortable.h
//  Library
//
//  Created by Alison Clarke on 26/02/2014.
//  Copyright (c) 2014 Alison Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LibraryManagedObject <NSObject>

- (NSString *) description;
+ (NSString *) sortField;

@end
