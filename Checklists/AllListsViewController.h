//
//  AllListsViewController.h
//  Checklists
//
//  Created by Alonso Zhang on 6/5/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListDetailViewController.h"
#import "aboutViewController.h"
#import "SettingViewController.h"
#import "ContactsListViewController.h"
#import "CHCSVParser.h"
#import "PXAlertView.h"
#import <ContactsUI/CNContactViewController.h>
#import <ContactsUI/CNContactPickerViewController.h>

@class DataModel;

@interface AllListsViewController : UITableViewController<ListDetailViewControllerDelegate,UINavigationControllerDelegate,CNContactViewControllerDelegate,CNContactPickerDelegate,AboutViewControllerDelegate,SettingViewControllerDelegate,ContactsListViewControllerDelegate>
- (IBAction)actionList:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionlist;
//- (IBAction)searchcontact:(UIBarButtonItem *)sender;
@property (assign, nonatomic) BOOL touchIDLoginDisabled;
@property (nonatomic, strong) DataModel *dataModel;
@end
