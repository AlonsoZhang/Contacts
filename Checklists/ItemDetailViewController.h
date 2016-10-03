//
//  itemDetailViewController.h
//  Checklists
//
//  Created by Alonso Zhang on 6/2/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItemDetailViewController;
@class ChecklistItem;

@protocol itemDetailViewControllerDelegate <NSObject>
- (void)itemDetailViewControllerDidCancel:(ItemDetailViewController *)controller;
- (void)itemDetailViewController:(ItemDetailViewController *)controller didFinishAddingItem:(ChecklistItem *)item;
- (void)itemDetailViewController:(ItemDetailViewController *)controller didFinishEditingItem:(ChecklistItem *)item;
@end

@interface ItemDetailViewController : UITableViewController<UITextFieldDelegate>
@property (nonatomic, weak) id <itemDetailViewControllerDelegate> delegate;

@property (nonatomic, strong) ChecklistItem *itemToEdit;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *engName;
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

@end