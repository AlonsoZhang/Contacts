//
//  itemDetailViewController.m
//  Checklists
//
//  Created by Alonso Zhang on 6/2/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "ChecklistItem.h"
#import "Checklists-swift.h"

@interface ItemDetailViewController ()

@end

@implementation ItemDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.itemToEdit != nil)
    {
        self.title = @"編輯聯繫人";
        self.textField.text = self.itemToEdit.name;
        self.engName.text = self.itemToEdit.engname;
        self.departNum.text = self.itemToEdit.departmentnumber;
        self.phoneNum.text = self.itemToEdit.phonenumber;
        self.twphoneNum.text = self.itemToEdit.twphonenumber;
        self.usaphoneNum.text = self.itemToEdit.usaphonenumber;
        self.otherphoneNum.text = self.itemToEdit.otherphonenumber;
        self.phoneShortNum.text = self.itemToEdit.shortnumber;
        self.fenjiNum.text = self.itemToEdit.fenji;
        self.suboNum.text = self.itemToEdit.subo;
        self.doneBarButton.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.textField becomeFirstResponder];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate itemDetailViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender
{
    if (self.itemToEdit == nil)
    {
        ChecklistItem *item = [[ChecklistItem alloc] init];
        item.name = self.textField.text;
        item.engname = self.engName.text;
        item.text = [NSString stringWithFormat:@"%@ %@",item.name,item.engname];
        item.departmentnumber = self.departNum.text;
        item.phonenumber = self.phoneNum.text;
        item.twphonenumber = self.twphoneNum.text;
        item.usaphonenumber = self.usaphoneNum.text;
        item.otherphonenumber = self.otherphoneNum.text;
        item.shortnumber = self.phoneShortNum.text;
        item.fenji = self.fenjiNum.text;
        item.subo = self.suboNum.text;
        item.checked = NO;
        [self.delegate itemDetailViewController:self didFinishAddingItem:item];
    }
    else
    {
        [self noticeTop:@"保存成功" autoClear:YES];
        self.itemToEdit.name = self.textField.text;
        self.itemToEdit.engname = self.engName.text;
        self.itemToEdit.text = [NSString stringWithFormat:@"%@ %@",self.itemToEdit.name,self.itemToEdit.engname];
        self.itemToEdit.departmentnumber = self.departNum.text;
        self.itemToEdit.phonenumber = self.phoneNum.text;
        self.itemToEdit.twphonenumber = self.twphoneNum.text;
        self.itemToEdit.usaphonenumber = self.usaphoneNum.text;
        self.itemToEdit.otherphonenumber = self.otherphoneNum.text;
        self.itemToEdit.shortnumber = self.phoneShortNum.text;
        self.itemToEdit.fenji = self.fenjiNum.text;
        self.itemToEdit.subo = self.suboNum.text;
        [self.delegate itemDetailViewController:self didFinishEditingItem:self.itemToEdit];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPathe
{
    return nil;
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [theTextField.text stringByReplacingCharactersInRange:range withString:string];
    self.doneBarButton.enabled = ([newText length] > 0);
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![_textField isExclusiveTouch]) {
        [_textField resignFirstResponder];
    }
}

//- (IBAction) backgroundTap:(id)sender
//{
//    [_textField resignFirstResponder];
//    [_phoneNum resignFirstResponder];
//}

@end
