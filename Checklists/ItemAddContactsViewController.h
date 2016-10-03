//
//  ItemAddContactsViewController.h
//  Checklists
//
//  Created by Alonso Zhang on 16/1/26.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contacts.h"

@class ChecklistItem;

@class ItemAddContactsViewController;
@class ChecklistItem;

@protocol itemAddContactsViewControllerDelegate <NSObject,CNContactViewControllerDelegate,CNContactPickerDelegate>
- (void)itemAddContactsViewControllerDidCancel:(ItemAddContactsViewController *)controller;
@end

@interface ItemAddContactsViewController : UITableViewController<UITextFieldDelegate>
@property (nonatomic, weak) id <itemAddContactsViewControllerDelegate> delegate;
@property (nonatomic, strong) ChecklistItem *itemToEdit;

- (IBAction)cancel:(id)sender;
- (IBAction)addContacts:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *otherphoneNum;
@property (weak, nonatomic) IBOutlet UITextField *usaphoneNum;
@property (weak, nonatomic) IBOutlet UITextField *twphoneNum;
@property (weak, nonatomic) IBOutlet UITableViewCell *otherphonetable;
@property (weak, nonatomic) IBOutlet UITableViewCell *twphonetable;
@property (weak, nonatomic) IBOutlet UITableViewCell *usaphonetable;
@property (weak, nonatomic) IBOutlet UITableViewCell *phonetable;
@property (weak, nonatomic) IBOutlet UITextField *phoneNum;
@property (weak, nonatomic) IBOutlet UITextField *phoneShortNum;
@property (weak, nonatomic) IBOutlet UITextField *departNum;
@property (weak, nonatomic) IBOutlet UITextField *fenjiNum;
@property (weak, nonatomic) IBOutlet UITextField *suboNum;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UITableViewCell *hideCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *twhideCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *usahideCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *otherhideCell;

@end