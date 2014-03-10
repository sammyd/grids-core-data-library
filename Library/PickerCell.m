//
//  PickerCell.m
//  CustomPickerCell
//
//  Created by Alison Clarke on 25/11/2013.
//
//  Copyright 2013 Scott Logic
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "PickerCell.h"
#import "PickerViewController.h"

@implementation PickerCell
{
    UILabel* _label;
    PickerViewController* _pickerViewController;
    UIPopoverController* _popover;
}

- (id)initWithReuseIdentifier:(NSString *)identifier
{
    if (self = [super initWithReuseIdentifier:identifier]) {
        // Add a label
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:13];
        [self addSubview:_label];
        
        // Create a PickerViewController ready to display when in edit mode
        _pickerViewController = [[PickerViewController alloc] init];
        _pickerViewController.delegate = self;
    }
    return self;
}

- (void) setValues:(NSArray*)values
{
    // Sets the list of possible values for the cell
    _values = values;
    // Pass the list to the PickerViewController
    [_pickerViewController setValues:values];
}

- (void) setSelectedIndex:(int)selectedIndex
{
    // Check the index is in the bounds of our values array
    if ([_values count] > selectedIndex)
    {
        // Set the selected index, and pass it to the PickerViewController
        _selectedIndex = selectedIndex;
        _pickerViewController.selectedIndex = selectedIndex;
    
        // Update the displayed text with the new value
        //self.textField.text = [_values[selectedIndex] description];
        _label.text = [_values[selectedIndex] description];
    }
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    // Set up the label's frame so it's inset by 20px from left/right and 10px from top/bottom
    _label.frame = CGRectMake(20, 10, self.bounds.size.width-40, self.bounds.size.height-20);
}

#pragma mark SGridEventResponder methods

// Called when the grid's edit event is triggered on this cell
- (void) respondToEditEvent {
    // We need to call the grid's delegate methods for editing cells before doing any more
    
    // Call the shouldBeginEditingCellAtCoordinate method on the grid's delegate (if the method exists)
    if ([self.dataGrid.delegate respondsToSelector:@selector(shinobiDataGrid:shouldBeginEditingCellAtCoordinate:)]) {
        if([self.dataGrid.delegate shinobiDataGrid:self.dataGrid shouldBeginEditingCellAtCoordinate:self.coordinate] == NO) {
            return;
        }
    }
    
    // Call the willBeginEditingCellAtCoordinate method on the grid's delegate (if the method exists)
    if ([self.dataGrid.delegate respondsToSelector:@selector(shinobiDataGrid:willBeginEditingCellAtCoordinate:)]) {
        [self.dataGrid.delegate shinobiDataGrid:self.dataGrid willBeginEditingCellAtCoordinate:self.coordinate];
    }
    
    // Finally create and display the popover
    _popover = [[UIPopoverController alloc] initWithContentViewController:_pickerViewController];
    [_popover presentPopoverFromRect:self.bounds inView:self permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

#pragma mark PickerDelegate methods

// Called when the a new value has been selected in the UIPickerView
-(void)didSelectRowAtIndex:(int)newIndex {
    // Set the new index value
    [self setSelectedIndex:newIndex];
    
    // Dismiss the popover
    [_popover dismissPopoverAnimated:YES];
    _popover = nil;
    
    // Call the didFinishEditingCellAtCoordinate method on the grid's delegate (if the method exists)
    if ([self.dataGrid.delegate respondsToSelector:@selector(shinobiDataGrid:didFinishEditingCellAtCoordinate:)]) {
        [self.dataGrid.delegate shinobiDataGrid:self.dataGrid didFinishEditingCellAtCoordinate:self.coordinate];
    }
}

@end
