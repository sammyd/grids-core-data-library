//
//  LibraryData.h
//  Library
//
//  Created by Alison Clarke on 20/11/2013.
//  Copyright (c) 2013 Alison Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface LibraryDataHelper : NSObject

-(id)initWithContext:(NSManagedObjectContext*)context;
-(NSArray*)getPropertyNamesForEntityName:(NSString*)entityName;
-(NSArray*)getAttributeNamesForEntityName:(NSString*)entityName;
-(NSArray*)getRelationshipEntityNamesForEntityName:(NSString*)entityName;
-(NSArray*)fetchAllEntitiesOfType:(Class)type;
-(void)saveChanges;

@end
