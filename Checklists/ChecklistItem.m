//
//  ChecklistItem.m
//  Checklists
//
//  Created by Alonso Zhang on 5/28/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import "ChecklistItem.h"

@implementation ChecklistItem

- (id)init
{
    if ((self = [super init]))
    {
        self.itemdetails = [[NSMutableArray alloc] initWithCapacity:20];
    }
    return self;
}


- (void)toggleChecked
{
    self.checked = !self.checked;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        self.text = [aDecoder decodeObjectForKey:@"Text"];
        self.checked = [aDecoder decodeBoolForKey:@"Checked"];
        self.name = [aDecoder decodeObjectForKey:@"Name"];
        self.engname = [aDecoder decodeObjectForKey:@"Engname"];
        self.phonenumber = [aDecoder decodeObjectForKey:@"Phonenumber"];
        self.twphonenumber = [aDecoder decodeObjectForKey:@"TWPhonenumber"];
        self.usaphonenumber = [aDecoder decodeObjectForKey:@"USAPhonenumber"];
        self.otherphonenumber = [aDecoder decodeObjectForKey:@"OtherPhonenumber"];
        self.shortnumber = [aDecoder decodeObjectForKey:@"Shortnumber"];
        self.fenji = [aDecoder decodeObjectForKey:@"Fenji"];
        self.subo = [aDecoder decodeObjectForKey:@"Subo"];
        self.departmentnumber = [aDecoder decodeObjectForKey:@"Departmentnumber"];
        self.groupname = [aDecoder decodeObjectForKey:@"Groupname"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.text forKey:@"Text"];
    [aCoder encodeBool:self.checked forKey:@"Checked"];
    [aCoder encodeObject:self.name forKey:@"Name"];
    [aCoder encodeObject:self.engname forKey:@"Engname"];
    [aCoder encodeObject:self.phonenumber forKey:@"Phonenumber"];
    [aCoder encodeObject:self.twphonenumber forKey:@"TWPhonenumber"];
    [aCoder encodeObject:self.usaphonenumber forKey:@"USAPhonenumber"];
    [aCoder encodeObject:self.otherphonenumber forKey:@"OtherPhonenumber"];
    [aCoder encodeObject:self.shortnumber forKey:@"Shortnumber"];
    [aCoder encodeObject:self.fenji forKey:@"Fenji"];
    [aCoder encodeObject:self.subo forKey:@"Subo"];
    [aCoder encodeObject:self.departmentnumber forKey:@"Departmentnumber"];
    [aCoder encodeObject:self.groupname forKey:@"Groupname"];
}

@end
