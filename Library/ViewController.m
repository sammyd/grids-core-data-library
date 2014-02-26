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
#import "PickerCell.h"

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
    
    // Get the managed object context from the app delegate, and create a LibraryDataHelper
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _libraryDataHelper = [[LibraryDataHelper alloc] initWithContext:[appDelegate managedObjectContext]];

    // Set up the grid
    _shinobiDataGrid.delegate = self;
    _shinobiDataGrid.singleTapEventMask = SDataGridEventNone;
    
    // Fetch all the books and keep hold of them in our _data array
    _data = [_libraryDataHelper fetchAllEntitiesOfType:[Book class]];
    
    // Create a datasource helper and hand it the books
    _datasourceHelper = [[SDataGridDataSourceHelper alloc] initWithDataGrid:_shinobiDataGrid];
    _datasourceHelper.data = _data;
    _datasourceHelper.delegate = self;
    
    // Find the attributes of a Book and add them as text columns
    NSArray* bookAttributes = [_libraryDataHelper getAttributeNamesForEntityName:@"Book"];
    
    SDataGridCellStyle *cellStyle = [[SDataGridCellStyle alloc] init];
    cellStyle.font = [UIFont systemFontOfSize:13];
    
    for (NSString* attributeName in bookAttributes) {
        NSString* columnTitle = [[attributeName stringByReplacingOccurrencesOfString:@"_"withString:@" "] capitalizedString];
        SDataGridColumn* column = [[SDataGridColumn alloc] initWithTitle:columnTitle forProperty:attributeName cellType:[SDataGridMultiLineTextCell class] headerCellType:[SDataGridHeaderMultiLineCell class]];
        column.editable = YES;
        column.cellStyle = cellStyle;
        
        if ([attributeName isEqualToString:@"year"]) {
            column.width = @105;
        } else {
            column.width = @190;
        }
        
        [_shinobiDataGrid addColumn:column];
    }
    
    // Find the relationships of a Book and add them as picker columns
    NSArray* bookRelationships = [_libraryDataHelper getRelationshipEntityNamesForEntityName:@"Book"];

    for (NSString* relationshipName in bookRelationships) {
        NSString* columnTitle = [[relationshipName stringByReplacingOccurrencesOfString:@"_"withString:@" "] capitalizedString];
        SDataGridColumn* column = [[SDataGridColumn alloc] initWithTitle:columnTitle forProperty:relationshipName cellType:[PickerCell class] headerCellType:[SDataGridHeaderMultiLineCell class]];
        column.editable = YES;
        column.width = @200;
        
        [_shinobiDataGrid addColumn:column];
    }

    [_shinobiDataGrid reload];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SDataGridDelegate methods

- (void)shinobiDataGrid:(ShinobiDataGrid *)grid didFinishEditingCellAtCoordinate:(SDataGridCoord *)coordinate
{
    // Locate the model object for this row
    Book* book = _data[coordinate.row.rowIndex];
    
    // Get the cell that was edited
    SDataGridCell* cell = (SDataGridCell*)[_shinobiDataGrid visibleCellAtCoordinate:coordinate];
    
    // Determine which column this cell belongs to, and handle the edit appropriately
    NSString *cellTitle = cell.coordinate.column.title;
    
    if ([cellTitle isEqualToString:@"Title"] || [cellTitle isEqualToString:@"Year"])
    {
        // Find the cell that was edited
        SDataGridMultiLineTextCell* textCell = (SDataGridMultiLineTextCell*) cell;
        
        // Find the text entered by the user
        NSString* updatedText = textCell.text;
        
        if ([cellTitle isEqualToString:@"Title"]) {
            // Just update the text of the book's title
            book.title = updatedText;
            
        } else if ([cellTitle isEqualToString:@"Year"]) {
            // Parse the input text to make sure it's numeric
            NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber* newYear = [formatter numberFromString:updatedText];
            
            if (newYear)
            {
                // If the input was valid, update the model
                book.year = newYear;
            } else {
                // Input was invalid so alert the user and reset to the old value
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid year" message:@"That's not a valid year. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                textCell.text = book.year.stringValue;
            }
        }
    } else {
        PickerCell* pickerCell = (PickerCell*) cell;
        NSManagedObject* obj = pickerCell.values[pickerCell.selectedIndex];
        
        if ([cellTitle isEqualToString:@"Publisher"]) {
            // Update the book's Publisher object
            [book.publisher removeBooksObject:book];
            Publisher *publisher = (Publisher*) obj;
            book.publisher = publisher;
            [publisher addBooksObject:book];
        } else if ([cellTitle isEqualToString:@"Author"]) {
            // Update the book's Author object
            [book.author removeBooksObject:book];
            Author *author = (Author*) obj;
            book.author = author;
            [author addBooksObject:book];
        }
    }
    
    // Save everything
    [_libraryDataHelper saveChanges];
}

// Called when the data source helper is populating a cell
- (BOOL)dataGridDataSourceHelper:(SDataGridDataSourceHelper *)helper populateCell:(SDataGridCell *)cell withValue:(id)value forProperty:(NSString *)propertyKey sourceObject:(id)object
{
    if ([cell isKindOfClass:[PickerCell class]])
    {
        // Create a picker cell to display the property
        PickerCell* pickerCell = (PickerCell*)cell;
        pickerCell.dataGrid = self.shinobiDataGrid;
        pickerCell.values = [_libraryDataHelper fetchAllEntitiesOfType:NSClassFromString(propertyKey)];
        for (int i=0; i<pickerCell.values.count; i++)
        {
            NSString* selectedDescription = [pickerCell.values[i] description];
            if ([selectedDescription isEqualToString:[value description]])
            {
                pickerCell.selectedIndex = i;
                break;
            }
        }
        
        return YES;
    }
    
    // Return 'NO' so that the datasource helper populates all the other cells in the grid.
    return NO;
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
