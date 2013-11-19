//
//  ViewController.m
//  Library
//
//  Created by Alison Clarke on 18/11/2013.
//  Copyright (c) 2013 Alison Clarke. All rights reserved.
//

#import "ViewController.h"
#import "Publisher.h"
#import "Author.h"
#import "Book.h"
#import "AppDelegate.h"
#import <ShinobiGrids/SDataGridMultiLineTextCell.h>

@interface ViewController ()

@end

@implementation ViewController
{
    //ShinobiDataGrid *_shinobiDataGrid;
    SDataGridDataSourceHelper* _datasourceHelper;
    NSManagedObjectContext *_context;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    // Get the managed object context from the app delegate
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _context = [appDelegate managedObjectContext];

    // Set up the library data
    [self setupData];

    // Set up the grid
    _shinobiDataGrid.defaultRowHeight = @70;
    
    // Find the properties of a Book and add them as columns
    NSEntityDescription *bookEntity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:_context];
    NSDictionary* bookProperties = [bookEntity propertiesByName];

    for (NSString* propertyName in bookProperties) {
        NSString* columnTitle = [[propertyName stringByReplacingOccurrencesOfString:@"_"withString:@" "] capitalizedString];
        SDataGridColumn* column = [[SDataGridColumn alloc] initWithTitle:columnTitle forProperty:propertyName cellType:[SDataGridMultiLineTextCell class] headerCellType:[SDataGridHeaderMultiLineCell class]];
        
        // Set widths
        if ([propertyName isEqualToString:@"year"]) {
            column.width = @105;
        } else if ([propertyName isEqualToString:@"author"]) {
            column.width = @150;
        } else {
            column.width = @220;
        }
        
        [_shinobiDataGrid addColumn:column];
    }

    // Fetch all the books
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book"
                                              inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [_context executeFetchRequest:fetchRequest error:&error];

    // Create a datasource helper and hand it the books
    _datasourceHelper = [[SDataGridDataSourceHelper alloc] initWithDataGrid:_shinobiDataGrid];
    _datasourceHelper.data = fetchedObjects;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Sets up the data, if there aren't any books already in the library
- (void) setupData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book"
                                              inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesSubentities:NO];
    NSError *error = nil;
    NSUInteger count = [_context countForFetchRequest:fetchRequest error:&error];
    if(count == 0) {
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
        
        // Save everything
        error = nil;
        if ([_context save:&error]) {
            NSLog(@"The save was successful!");
        } else {
            NSLog(@"The save wasn't successful: %@", [error userInfo]);
        }
    }

}

#pragma mark - UIViewController methods
// < iOS6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

// >= iOS6
- (BOOL)shouldAutorotate {
    return NO;
}


@end