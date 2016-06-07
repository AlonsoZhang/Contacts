//
//  ContactsListViewController.h
//  Checklists
//
//  Created by Alonso Zhang on 16/3/8.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ContactsUI/CNContactViewController.h>
#import <ContactsUI/CNContactPickerViewController.h>
#import "CHCSVParser.h"
#import "PXAlertView.h"

@class ContactsListViewController;

@protocol ContactsListViewControllerDelegate <NSObject>
- (void)contactsListViewControllerDidCancel:(ContactsListViewController *)controller;
@end

@interface ContactsListViewController : UITableViewController<UITextFieldDelegate,CNContactViewControllerDelegate,CNContactPickerDelegate>
@property (nonatomic, weak) id <ContactsListViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearBtn;
@end