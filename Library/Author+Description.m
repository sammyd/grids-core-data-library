//
//  Author+Description.m
//  Library
//
//  Created by Alison Clarke on 18/11/2013.
//  Copyright (c) 2013 Alison Clarke. All rights reserved.
//

#import "Author+Description.h"

@implementation Author (Description)

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.forenames, self.surname];
}

@end
