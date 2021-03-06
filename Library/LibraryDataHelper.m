//
//  LibraryData.m
//  Library
//
//  Created by Alison Clarke on 20/11/2013.
//  Copyright (c) 2013 Alison Clarke. All rights reserved.
//

#import "LibraryDataHelper.h"
#import "Author.h"
#import "Publisher.h"
#import "Book.h"
#import "LibraryManagedObject.h"

@implementation LibraryDataHelper
{
    NSManagedObjectContext *_context;
}

-(id)initWithContext:(NSManagedObjectContext *)context
{
    if (self = [super init]) {
        _context = context;
        
        // Set up the library data
        // If you want to reset the data, change the parameter to true
        [self setupData:false];
    }
    return self;
}

// Retrieves all entities of the given type
-(NSArray*)fetchAllEntitiesOfType:(Class <LibraryManagedObject>)type
{
    NSString* entityName = NSStringFromClass(type);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:[type sortField] ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    NSArray* data = [_context executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        NSLog(@"Unable to fetch entities with name %@: %@", entityName, [error userInfo]);
    }
    return data;
}

-(void)saveChanges {
    NSError *error = nil;
    if (![_context save:&error]) {
        NSLog(@"The save wasn't successful: %@", [error userInfo]);
    }
}

// Sets up the data, if there aren't any books already in the library, or if forceReset is true
- (void) setupData:(bool)forceReset
{
    NSUInteger count;
    
    if (forceReset) {
        [self deleteAllData];
    } else {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book"
                                                  inManagedObjectContext:_context];
        [fetchRequest setEntity:entity];
        [fetchRequest setIncludesSubentities:NO];
        NSError *error = nil;
        count = [_context countForFetchRequest:fetchRequest error:&error];
    }
    
    if(forceReset || count == 0) {
        // Create some Publisher entities
        Publisher *publisher1 = [NSEntityDescription insertNewObjectForEntityForName:@"Publisher"
                                                              inManagedObjectContext:_context];
        publisher1.name = @"Harper & Brothers";
        
        Publisher *publisher2 = [NSEntityDescription insertNewObjectForEntityForName:@"Publisher"
                                                              inManagedObjectContext:_context];
        publisher2.name = @"Chapman & Hall";
        
        Publisher *publisher3 = [NSEntityDescription insertNewObjectForEntityForName:@"Publisher"
                                                              inManagedObjectContext:_context];
        publisher3.name = @"Bradbury & Evans";
        
        Publisher *publisher4 = [NSEntityDescription insertNewObjectForEntityForName:@"Publisher"
                                                              inManagedObjectContext:_context];
        publisher4.name = @"American Publishing Company";
        
        Publisher *publisher5 = [NSEntityDescription insertNewObjectForEntityForName:@"Publisher"
                                                              inManagedObjectContext:_context];
        publisher5.name = @"James R Osgood & Co";
        
        Publisher *publisher6 = [NSEntityDescription insertNewObjectForEntityForName:@"Publisher"
                                                              inManagedObjectContext:_context];
        publisher6.name = @"Charles L Webster & Co";
        

        // Create some Author entities
        Author *author1 = [NSEntityDescription insertNewObjectForEntityForName:@"Author"
                                                        inManagedObjectContext:_context];
        author1.forenames = @"Charles";
        author1.surname = @"Dickens";
        
        Author *author2 = [NSEntityDescription insertNewObjectForEntityForName:@"Author"
                                                        inManagedObjectContext:_context];
        author2.forenames = @"Mark";
        author2.surname = @"Twain";
        
        Author *author3 = [NSEntityDescription insertNewObjectForEntityForName:@"Author"
                                                        inManagedObjectContext:_context];
        author3.forenames = @"Herman";
        author3.surname = @"Melville";
        
        // Create some books
        Book *book1 = [NSEntityDescription insertNewObjectForEntityForName:@"Book"
                                                    inManagedObjectContext:_context];
        book1.title = @"Bleak House";
        book1.year = @1853;
        [book1 setPublisher:publisher1];
        [publisher1 addBooksObject:book1];
        [book1 setAuthor:author1];
        [author1 addBooksObject:book1];
        
        Book *book2 = [NSEntityDescription insertNewObjectForEntityForName:@"Book"
                                                    inManagedObjectContext:_context];
        book2.title = @"The Old Curiosity Shop";
        book2.year = @1841;
        [book2 setPublisher:publisher2];
        [publisher2 addBooksObject:book2];
        [book2 setAuthor:author1];
        [author1 addBooksObject:book2];
        
        Book *book3 = [NSEntityDescription insertNewObjectForEntityForName:@"Book"
                                                    inManagedObjectContext:_context];
        book3.title = @"David Copperfield";
        book3.year = @1850;
        [book3 setPublisher:publisher3];
        [publisher3 addBooksObject:book3];
        [book3 setAuthor:author1];
        [author1 addBooksObject:book3];
        
        Book *book4 = [NSEntityDescription insertNewObjectForEntityForName:@"Book"
                                                    inManagedObjectContext:_context];
        book4.title = @"The Adventures of Tom Sawyer";
        book4.year = @1876;
        [book4 setPublisher:publisher4];
        [publisher4 addBooksObject:book4];
        [book4 setAuthor:author2];
        [author2 addBooksObject:book4];
        
        Book *book5 = [NSEntityDescription insertNewObjectForEntityForName:@"Book"
                                                    inManagedObjectContext:_context];
        book5.title = @"A Tramp Abroad";
        book5.year = @1880;
        [book5 setPublisher:publisher4];
        [publisher4 addBooksObject:book5];
        [book5 setAuthor:author2];
        [author2 addBooksObject:book5];
        
        Book *book6 = [NSEntityDescription insertNewObjectForEntityForName:@"Book"
                                                    inManagedObjectContext:_context];
        book6.title = @"Moby Dick";
        book6.year = @1851;
        [book6 setPublisher:publisher1];
        [publisher1 addBooksObject:book6];
        [book6 setAuthor:author3];
        [author3 addBooksObject:book6];
        
        Book *book7 = [NSEntityDescription insertNewObjectForEntityForName:@"Book"
                                                    inManagedObjectContext:_context];
        book7.title = @"The Prince and the Pauper";
        book7.year = @1881;
        [book7 setPublisher:publisher5];
        [publisher5 addBooksObject:book7];
        [book7 setAuthor:author2];
        [author2 addBooksObject:book7];
        
        Book *book8 = [NSEntityDescription insertNewObjectForEntityForName:@"Book"
                                                    inManagedObjectContext:_context];
        book8.title = @"Adventures of Huckleberry Finn";
        book8.year = @1885;
        [book8 setPublisher:publisher6];
        [publisher6 addBooksObject:book8];
        [book8 setAuthor:author2];
        [author2 addBooksObject:book8];
        
        
        Book *book9 = [NSEntityDescription insertNewObjectForEntityForName:@"Book"
                                                    inManagedObjectContext:_context];
        book9.title = @"A Connecticut Yankee in King Arthur's Court";
        book9.year = @1889;
        [book9 setPublisher:publisher6];
        [publisher6 addBooksObject:book9];
        [book9 setAuthor:author2];
        [author2 addBooksObject:book8];
        
        // Save everything
        NSError *error = nil;
        if (![_context save:&error]) {
            NSLog(@"The save wasn't successful: %@", [error userInfo]);
        }
    }
}

- (void) deleteAllData {
    NSArray *entityNames = @[@"Book", @"Author", @"Publisher"];
    
    for(NSString *entityName in entityNames) {
        NSFetchRequest * allItems = [[NSFetchRequest alloc] init];
        [allItems setEntity:[NSEntityDescription entityForName:entityName
                                        inManagedObjectContext:_context]];
        [allItems setIncludesPropertyValues:NO]; //only fetch the managedObjectID
        
        NSError * error = nil;
        NSArray * items = [_context executeFetchRequest:allItems error:&error];
        if(error) {
            NSLog(@"%@", error);
        }
        for (NSManagedObject * book in items) {
            [_context deleteObject:book];
        }
    }
    
    NSError *saveError = nil;
    [_context save:&saveError];
    if(saveError) {
        NSLog(@"%@", saveError);
    }
}

@end
