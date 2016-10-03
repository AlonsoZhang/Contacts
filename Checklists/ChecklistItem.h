//
//  ChecklistItem.h
//  Checklists
//
//  Created by Alonso Zhang on 5/28/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChecklistItem : NSObject <NSCoding>
@property (nonatomic, strong) NSMutableArray *itemdetails;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *engname;
@property (nonatomic, copy) NSString *phonenumber;
@property (nonatomic, copy) NSString *twphonenumber;
@property (nonatomic, copy) NSString *usaphonenumber;
@property (nonatomic, copy) NSString *otherphonenumber;
@property (nonatomic, copy) NSString *shortnumber;
@property (nonatomic, copy) NSString *fenji;
@property (nonatomic, copy) NSString *subo;
@property (nonatomic, copy) NSString *departmentnumber;
@property (nonatomic, copy) NSString *groupname;
@property (nonatomic, assign) BOOL checked;

- (void)toggleChecked;
@end