//
//  LibraryData.h
//  Library
//
//  Created by Alison Clarke on 20/11/2013.
//  Copyright (c) 2013 Alison Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LibraryManagedObject.h"

@interface LibraryDataHelper : NSObject

-(id)initWithContext:(NSManagedObjectContext*)context;
-(NSArray*)fetchAllEntitiesOfType:(Class <LibraryManagedObject>)type;
-(void)saveChanges;

@end
