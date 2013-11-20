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
#import "LibraryDataHelper.h"
#import <ShinobiGrids/SDataGridMultiLineTextCell.h>

@interface ViewController ()

@end

@implementation ViewController
{
    SDataGridDataSourceHelper* _datasourceHelper;
    LibraryDataHelper *_libraryDataHelper;
    NSArray *_data;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    // Get the managed object context from the app delegate
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _libraryDataHelper = [[LibraryDataHelper alloc] initWithContext:[appDelegate managedObjectContext]];

    // Set up the grid
    _shinobiDataGrid.defaultRowHeight = @70;
    _shinobiDataGrid.singleTapEventMask = SDataGridEventNone;
    _shinobiDataGrid.doubleTapEventMask = SDataGridEventEdit;
    
    // Find the properties of a Book and add them as columns
    NSArray* bookProperties = [_libraryDataHelper getPropertyNamesForEntityName:@"Book"];

    for (NSString* propertyName in bookProperties) {
        NSString* columnTitle = [[propertyName stringByReplacingOccurrencesOfString:@"_"withString:@" "] capitalizedString];
        SDataGridColumn* column = [[SDataGridColumn alloc] initWithTitle:columnTitle forProperty:propertyName cellType:[SDataGridMultiLineTextCell class] headerCellType:[SDataGridHeaderMultiLineCell class]];
        column.editable = YES;
        
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

    // Fetch all the books and keep hold of them in our _data array
    _data = [_libraryDataHelper fetchAllEntitiesWithName:@"Book"];

    // Create a datasource helper and hand it the books
    _datasourceHelper = [[SDataGridDataSourceHelper alloc] initWithDataGrid:_shinobiDataGrid];
    _datasourceHelper.data = _data;
    
    _shinobiDataGrid.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SDataGridDelegate methods

- (void)shinobiDataGrid:(ShinobiDataGrid *)grid didFinishEditingCellAtCoordinate:(SDataGridCoord *)coordinate
{
    // Find the cell that was edited
    SDataGridMultiLineTextCell* cell = (SDataGridMultiLineTextCell*)[_shinobiDataGrid visibleCellAtCoordinate:coordinate];
    
    // Find the text entered by the user
    UITextView * textView = cell.editingTextView;
    NSString* updatedText = textView.text;
    
    // Locate the model object for this row
    Book* book = _data[coordinate.row.rowIndex];
    
    // Determine which column this cell belongs to, and handle the edit appropriately
    NSString *cellTitle = cell.coordinate.column.title;
    
    if ([cellTitle isEqualToString:@"Title"]) {
        // Just update the text of the book's title
        book.title = updatedText;
        
    } else if ([cellTitle isEqualToString:@"Year"]) {
        // Parse the input text to make sure it's numeric
        NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber* newYear = [formatter numberFromString:updatedText];
        
        if (newYear != nil)
        {
            // If the input was valid, update the model
            book.year = newYear;
        }
        
    } else if ([cellTitle isEqualToString:@"Publisher"]) {
        // Update the name of the book's Publisher object
        book.publisher.name = updatedText;
        
    } else if ([cellTitle isEqualToString:@"Author"]) {
        // Work out where to split the string into forename and surname
        // We'll assume simplistically that everything up to the last space is surname
        NSUInteger splitLocation = [updatedText rangeOfString:@" " options:NSBackwardsSearch].location;
        
        // Update the book's author object with the relevant substrings
        book.author.forenames = [updatedText substringToIndex:splitLocation];
        book.author.surname = [updatedText substringFromIndex:(splitLocation+1)];
    }
    
    // Save everything
    [_libraryDataHelper saveChanges];
    
    // Reload the data to reflect any changes in author or publisher
    [_shinobiDataGrid reload];
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
