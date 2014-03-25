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

    // Initialize and set up the grid
    _shinobiDataGrid = [[ShinobiDataGrid alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_shinobiDataGrid];
    _shinobiDataGrid.delegate = self;
    _shinobiDataGrid.singleTapEventMask = SDataGridEventNone;
    
    // Fetch all the books and keep hold of them in our _data array
    _data = [_libraryDataHelper fetchAllEntitiesOfType:[Book class]];
    
    // Create a datasource helper and hand it the books
    _datasourceHelper = [[SDataGridDataSourceHelper alloc] initWithDataGrid:_shinobiDataGrid];
    _datasourceHelper.data = _data;
    _datasourceHelper.delegate = self;
    
    // Create a cell style with the font size we want
    SDataGridCellStyle *cellStyle = [[SDataGridCellStyle alloc] init];
    cellStyle.font = [UIFont systemFontOfSize:13];
    
    // Add Title column
    SDataGridColumn* titleColumn = [[SDataGridColumn alloc] initWithTitle:@"Title" forProperty:@"Title" cellType:[SDataGridMultiLineTextCell class] headerCellType:[SDataGridHeaderMultiLineCell class]];
    titleColumn.editable = YES;
    titleColumn.cellStyle = cellStyle;
    titleColumn.width = @190;
    [_shinobiDataGrid addColumn:titleColumn];
    
    // Add Author column
    SDataGridColumn* authorColumn = [[SDataGridColumn alloc] initWithTitle:@"Author" forProperty:@"Author" cellType:[PickerCell class] headerCellType:[SDataGridHeaderMultiLineCell class]];
    authorColumn.editable = YES;
    authorColumn.cellStyle = cellStyle;
    authorColumn.width = @200;
    [_shinobiDataGrid addColumn:authorColumn];
    
    // Add Publisher column
    SDataGridColumn* publisherColumn = [[SDataGridColumn alloc] initWithTitle:@"Publisher" forProperty:@"Publisher" cellType:[PickerCell class] headerCellType:[SDataGridHeaderMultiLineCell class]];
    publisherColumn.editable = YES;
    publisherColumn.cellStyle = cellStyle;
    publisherColumn.width = @200;
    [_shinobiDataGrid addColumn:publisherColumn];
    
    // Add Year column
    SDataGridColumn* yearColumn = [[SDataGridColumn alloc] initWithTitle:@"Year" forProperty:@"Year" cellType:[SDataGridMultiLineTextCell class] headerCellType:[SDataGridHeaderMultiLineCell class]];
    yearColumn.editable = YES;
    yearColumn.cellStyle = cellStyle;
    yearColumn.width = @105;
    [_shinobiDataGrid addColumn:yearColumn];
    
    // Reload the data grid to display the data
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
    SDataGridCell* cell = [_shinobiDataGrid visibleCellAtCoordinate:coordinate];
    
    // Determine which column this cell belongs to, and handle the edit appropriately
    NSString *cellTitle = cell.coordinate.column.title;
    
    if ([cellTitle isEqualToString:@"Title"] || [cellTitle isEqualToString:@"Year"]) {
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
            
            if (newYear) {
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
            if ([[pickerCell.values[i] objectID] isEqual:[value objectID]])
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
