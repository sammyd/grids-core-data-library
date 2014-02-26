//
//  PickerViewHelper.m
//  CustomPickerCell
//
//  Created by Alison Clarke on 26/11/2013.
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

#import "PickerViewController.h"

@implementation PickerViewController
{
    UIPickerView *_pickerView;
}

- (void)loadView
{
    // Create and set up a UIPickerView if it hasn't already been created
    if (_pickerView == NULL)
    {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.frame = CGRectMake(0, 0, 200, _pickerView.frame.size.height);
    }
    
    // Select the row matching _selectedIndex
    [_pickerView selectRow:_selectedIndex inComponent:0 animated:NO];
    
    // Set our view to be _pickerView
    self.view = _pickerView;
    // Set our preferred size to that of our picker view
    self.preferredContentSize = _pickerView.frame.size;
}

#pragma mark UIPickerViewDataSource methods

// Returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// Returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return [_values count];
}

#pragma mark UIPickerViewDelegate methods

// Returns the display value for the relevant row
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_values[row] description];
}

// Called when the user selects a row
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // Call our PickerDelegate's didSelectRowAtIndex method
    if (_delegate != nil) {
        [_delegate didSelectRowAtIndex:row];
    }
}

@end
