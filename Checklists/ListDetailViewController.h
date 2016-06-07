//
//  ListDetailViewController.h
//  Checklists
//
//  Created by Alonso Zhang on 6/5/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IconPickerViewController.h"//导⼊头文件

@class ListDetailViewController;
@class Checklist;
@protocol ListDetailViewControllerDelegate <NSObject>
- (void)listDetailViewControllerDidCancel: (ListDetailViewController *)controller;
- (void)listDetailViewController:
(ListDetailViewController *)controller
        didFinishAddingChecklist:(Checklist *)checklist;
- (void)listDetailViewController:
(ListDetailViewController *)controller
       didFinishEditingChecklist:(Checklist *)checklist;
@end

@interface ListDetailViewController : UITableViewController<UITextFieldDelegate,IconPickerViewControllerDelegate>//添加⼀个协议遵循声明
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneBarButton;
@property (nonatomic, weak) id <ListDetailViewControllerDelegate> delegate;
@property (nonatomic, strong) Checklist *checklistToEdit;
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end
