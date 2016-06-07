//
//  ListDetailViewController.m
//  Checklists
//
//  Created by Alonso Zhang on 6/5/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import "ListDetailViewController.h"
#import "Checklist.h"

@interface ListDetailViewController ()

@end

@implementation ListDetailViewController
{
    NSString *_iconName;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.checklistToEdit != nil)
    {
        self.title = @"修改部門";
        self.textField.text = self.checklistToEdit.name;
        self.doneBarButton.enabled = YES;
        _iconName = self.checklistToEdit.iconName;//将checklist对象的图标名称赋予_iconName这个实例变量
    }
    self.iconImageView.image = [UIImage imageNamed:_iconName];//显示图标
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)done:(id)sender
{
    if (self.checklistToEdit == nil)
    {
        Checklist *checklist = [[Checklist alloc] init];
        checklist.name = self.textField.text;
        checklist.iconName = _iconName;//关闭当前界面时,将所选中的图标名称放到checklist对象的iconName属性中
        [self.delegate listDetailViewController:self didFinishAddingChecklist:checklist];
    }
    else
    {
        self.checklistToEdit.name = self.textField.text;
        self.checklistToEdit.iconName = _iconName;//
        [self.delegate listDetailViewController:self didFinishEditingChecklist:self.checklistToEdit];
    }
}

- (IBAction)cancel:(id)sender
{
    [self.delegate listDetailViewControllerDidCancel:self];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)//触碰文字行依旧无效，触碰图片行返回cell的index-path
    {
        return indexPath;
    }
    else
    {
        return nil;
    }
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [theTextField.text stringByReplacingCharactersInRange:range withString:string];
    self.doneBarButton.enabled = ([newText length] > 0);
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        _iconName = @"M5";//对于新的checklist默认情况下会获得一个Folder图标
    }
    return self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender//通知IconPickerViewController该界面将成为它的代理对象
{
    if ([segue.identifier isEqualToString:@"PickIcon"])
    {
        IconPickerViewController *controller = segue.destinationViewController;
        controller.delegate = self;
    }
}

- (void)iconPicker:(IconPickerViewController *)picker didPickIcon:(NSString *)theIconName//实现代理协议的回调方法
{
    _iconName = theIconName;
    self.iconImageView.image = [UIImage imageNamed:_iconName];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
