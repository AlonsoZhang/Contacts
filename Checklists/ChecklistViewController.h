//
//  ViewController.h
//  Checklists
//
//  Created by Alonso Zhang on 5/26/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemDetailViewController.h"
#import "ItemAddContactsViewController.h"
#import "CHCSVParser.h"
#import <ContactsUI/CNContactViewController.h>
#import <ContactsUI/CNContactPickerViewController.h>

@class Checklist;
@interface ChecklistViewController : UITableViewController<itemDetailViewControllerDelegate,itemAddContactsViewControllerDelegate,CNContactViewControllerDelegate,CNContactPickerDelegate>{
    NSArray *actual;
}
- (IBAction)checkBtn:(UIButton *)sender;
- (IBAction)nameListAction:(UIBarButtonItem *)sender;
@property (nonatomic, strong) Checklist *checklist;
@end