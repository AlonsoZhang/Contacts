//
//  ViewController.m
//  Checklists
//
//  Created by Alonso Zhang on 5/26/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import "ChecklistViewController.h"
#import "ChecklistItem.h"
#import "Checklist.h"
#import "NirKxMenu.h"
#import "Checklists-swift.h"

@interface ChecklistViewController ()

@end

@implementation ChecklistViewController{
    Contacts * contactclass;
    NSMutableArray *contacts;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.checklist.name;
}

- (void)viewWillAppear:(BOOL)animated{
    contactclass = [[Contacts alloc] init];
    contacts = [[NSMutableArray alloc] init];
    contacts = [contactclass fetchcontact];
    [self.tableView reloadData];
}  

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.checklist.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChecklistItem"];
    ChecklistItem *item = self.checklist.items[indexPath.row];
    for (CNContact *contact in contacts) {
        if ([item.name isEqualToString:[NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName]] &&[item.engname isEqualToString:contact.nickname] && [item.groupname isEqualToString:contact.departmentName] ) {
            NSString *phoneNumber = [[[contact.phoneNumbers firstObject] value] stringValue];
            if ([item.phonenumber isEqualToString:phoneNumber]) {
                item.checked = YES;
            }else{
                if (item.phonenumber == nil) {
                    item.checked = YES;
                }else{
                    item.checked = NO;
                }
            }
            [self configureTextForCell:cell withChecklistItem:item];
            [self configureCheckmarkForCell:cell withChecklistItem:item];
            return cell;
        }
    }
    item.checked = NO;
    [self configureTextForCell:cell withChecklistItem:item];
    [self configureCheckmarkForCell:cell withChecklistItem:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    ChecklistItem *item = self.checklist.items[indexPath.row];
//    [item toggleChecked];
//    [self configureCheckmarkForCell:cell withChecklistItem:item];
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ChecklistItem *checklistitem = self.checklist.items[indexPath.row];
    //NSLog(@"%@",checklistitem.name);
    [self performSegueWithIdentifier:@"ItemInfo" sender:checklistitem];
}

- (void)configureCheckmarkForCell:(UITableViewCell *)cell withChecklistItem:(ChecklistItem *)item
{
    UILabel *label = (UILabel *)[cell viewWithTag:1001];
    if (item.checked)
    {
        label.text = @"✅";
    }
    else
    {
        label.text = @"";
    }
    label.textColor = self.view.tintColor;//修改颜色
}

- (void)configureTextForCell:(UITableViewCell *)cell withChecklistItem:(ChecklistItem *)item
{
    UILabel *label = (UILabel *)[cell viewWithTag:1000];
    label.text = item.text;
}

//左滑删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChecklistItem *checklistitem = self.checklist.items[indexPath.row];
    for (CNContact *existconst in contacts) {
        if ([[NSString stringWithFormat:@"%@%@",existconst.familyName,existconst.givenName] isEqualToString:checklistitem.name] && [existconst.nickname isEqualToString:checklistitem.engname] && [existconst.departmentName isEqualToString:checklistitem.groupname]) {
            [contactclass deleteContact:existconst];
            NSLog(@"已删除%@",checklistitem.name);
            break;
        }
    }
    [self noticeTop:@"已删除" autoClear:YES];
    [self.checklist.items removeObjectAtIndex:indexPath.row];
    NSArray *indexPaths = @[indexPath];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    int checknum = 0;
    for (int i = 0; i < [self.checklist.items count]; i++) {
        ChecklistItem * cc = self.checklist.items[i];
        if (cc.checked) {
            checknum++;
        }
    }
    if (checknum == 0){
        [contactclass deleteGroup:checklistitem.groupname];
    }
}

- (void)itemDetailViewControllerDidCancel:(ItemDetailViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)itemAddContactsViewControllerDidCancel:(ItemAddContactsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)itemDetailViewController:(ItemDetailViewController *)controller didFinishAddingItem:(ChecklistItem *)item
{
    NSInteger newRowIndex = [self.checklist.items count];
    [self.checklist.items addObject:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
    NSArray *indexPaths = @[indexPath];
    [self.tableView insertRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)itemDetailViewController:(ItemDetailViewController *)controller didFinishEditingItem:(ChecklistItem *)item
{
    NSInteger index = [self.checklist.items indexOfObject:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self configureTextForCell:cell withChecklistItem:item];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddItem"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        ItemDetailViewController *controller = (ItemDetailViewController *) navigationController.topViewController;
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"EditItem"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        ItemDetailViewController *controller = (ItemDetailViewController *) navigationController.topViewController;
        controller.delegate = self;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        controller.itemToEdit = self.checklist.items[indexPath.row];
    }else if ([segue.identifier isEqualToString:@"ItemInfo"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        ItemAddContactsViewController *controller = (ItemAddContactsViewController *) navigationController.topViewController;
        controller.delegate = self;
        controller.itemToEdit = sender;
    }
}

- (IBAction)checkBtn:(UIButton *)sender {
    UITableViewCell * cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath * path = [self.tableView indexPathForCell:cell];
    //NSLog(@"index row%ld", (long)path.row);
    ChecklistItem *checklistitem = self.checklist.items[path.row];
    if (checklistitem.checked) {
        for (CNContact *existconst in contacts) {
            if ([[NSString stringWithFormat:@"%@%@",existconst.familyName,existconst.givenName] isEqualToString:checklistitem.name] && [existconst.nickname isEqualToString:checklistitem.engname] && [existconst.departmentName isEqualToString:checklistitem.groupname]) {
                [contactclass deleteContact:existconst];
                NSLog(@"已删除%@",checklistitem.name);
                checklistitem.checked = NO;
                break;
            }
        }
        [self noticeTop:@"已删除" autoClear:YES];
        int checknum = 0;
        for (int i = 0; i < [self.checklist.items count]; i++) {
            ChecklistItem * cc = self.checklist.items[i];
            if (cc.checked) {
                checknum++;
            }
        }
        if (checknum == 0){
            [contactclass deleteGroup:checklistitem.groupname];
        }
    }else{
        //1.创建Contact对象，必须是可变的
        CNMutableContact *c = [[CNMutableContact alloc] init];
        //2.为contact赋值
        [contactclass setNewContact:c name:checklistitem.name engname:checklistitem.engname phoneNum:checklistitem.phonenumber shortNum:checklistitem.shortnumber twNum:checklistitem.twphonenumber usaNum:checklistitem.usaphonenumber otherNum:checklistitem.otherphonenumber department:checklistitem.groupname];
        [contactclass savecontact:c];
        [self noticeTop:@"添加成功！" autoClear:YES];
        checklistitem.checked = YES;
    }
    contacts = [contactclass fetchcontact];
    for (int i = 0; i<3; i++) {
        [self.tableView reloadData];
    }
}

- (IBAction)nameListAction:(UIBarButtonItem *)sender {
    UIView *barButtonView = [sender valueForKey:@"view"];
    CGRect frame = barButtonView.frame;
    frame.origin.y = frame.origin.y +30;
    //内容配置
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"導入本部門通訊錄"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(addAllContacts)],
      
      [KxMenuItem menuItem:@"添加一位新成員"
                     image:[UIImage imageNamed:@"add"]
                    target:self
                    action:@selector(addNewMember)]
      
//      [KxMenuItem menuItem:@"瀏覽本機通訊錄"
//                     image:[UIImage imageNamed:@"search_icon"]
//                    target:self
//                    action:@selector(checkLocalContacts)],
      
//      [KxMenuItem menuItem:@"退回至桌面"
//                     image:[UIImage imageNamed:@"home_icon"]
//                    target:self
//                    action:@selector(backToDesktop)]
      ];
    
    //基础配置
    [KxMenu setTitleFont:[UIFont fontWithName:@"HelveticaNeue" size:22]];
    
    //拓展配置
    Color menucolor = {menucolor.R = 0.27,menucolor.G = 0.27,menucolor.B = 0.27,menucolor.A = 0.8};
    Color textcolor = {textcolor.R = 1.0,textcolor.G = 1.0,textcolor.B = 1.0,textcolor.A = 0.6};
    Color firsttextcolor = {firsttextcolor.R = 0.98,firsttextcolor.G = 0.73,firsttextcolor.B = 0.04,firsttextcolor.A = 1};
    OptionalConfiguration options = {
        options.arrowSize = 10, //指示箭头大小
        options.marginXSpacing = 10, //MenuItem左右边距
        options.marginYSpacing = 20, //MenuItem上下边距
        options.intervalSpacing = 25, //MenuItemImage与MenuItemTitle的间距
        options.menuCornerRadius = 8, //菜单圆角半径
        options.maskToBackground = true, //是否添加覆盖在原View上的半透明遮罩
        options.shadowOfMenu = true, //是否添加菜单阴影
        options.hasSeperatorLine = true, //是否设置分割线
        options.seperatorLineHasInsets = true, //是否在分割线两侧留下Insets
        options.textColor = textcolor, //menuItem字体颜色
        options.firsttextColor = firsttextcolor,//menuItem第一项字体颜色
        options.menuBackgroundColor = menucolor //菜单的底色
    };
    
    [KxMenu showMenuInView:self.view fromRect:frame menuItems:menuItems withOptions:options];
}

- (void)addAllContacts
{
    int count = 0;
    Contacts *contact = [[Contacts alloc] init];
    CNContactStore * store = [[CNContactStore alloc]init];
    CNSaveRequest * saveContactRequest = [[CNSaveRequest alloc]init];
    CNSaveRequest * addGroupRequest = [[CNSaveRequest alloc]init];
    CNMutableGroup *group = [[CNMutableGroup alloc]init];
    NSArray *groups = [store groupsMatchingPredicate:nil error:nil];
    BOOL addnewgroup = true;
    for (CNMutableGroup * existgroup in groups) {
        if ([self.checklist.group isEqualToString:existgroup.name]) {
            group = existgroup;
            addnewgroup = NO;
            break;
        }
    }
    if (addnewgroup) {
        CNSaveRequest * saveNewGroupRequest = [[CNSaveRequest alloc]init];
        //新建分组并添加
        //CNMutableGroup *newgroup = [[CNMutableGroup alloc]init];
        group.name = self.checklist.group;
        [saveNewGroupRequest addGroup:group toContainerWithIdentifier:nil];
        [store executeSaveRequest:saveNewGroupRequest error:nil];
    }
    for (ChecklistItem* item in self.checklist.items) {
        if (!item.checked) {
            //1.创建Contact对象，必须是可变的
            CNMutableContact *c = [[CNMutableContact alloc] init];
            [contact setNewContact:c name:item.name engname:item.engname phoneNum:item.phonenumber shortNum:item.shortnumber twNum:item.twphonenumber usaNum:item.usaphonenumber otherNum:item.otherphonenumber department:item.groupname];
            //添加联系人
            [saveContactRequest addContact:c toContainerWithIdentifier:nil];
            //联系人添加分组
            [addGroupRequest addMember:c toGroup:group];
            NSLog(@"已添加%@到%@",item.name,group.name);
            item.checked = YES;
            count ++;
        }
    }
    [store executeSaveRequest:saveContactRequest error:nil];
    [store executeSaveRequest:addGroupRequest error:nil];
    [self clearAllNotice];
    if (count == 0) {
        [self noticeOnlyText:@"已全部添加" autoClear:YES];
    }else{
        [self noticeOnlyText:[NSString stringWithFormat:@"新添加%d人",count] autoClear:YES];
    }
    contacts = [contact fetchcontact];
    [self.tableView reloadData];
}

- (void)checkLocalContacts
{
    [self saveExistContact];
}

//保存现有联系人实现
- (void)saveExistContact{
    //1.跳转到联系人选择页面，注意这里没有使用UINavigationController
    CNContactPickerViewController *controller = [[CNContactPickerViewController alloc] init];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:^{}];
}

- (void)addNewMember
{
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier: @"AddMemberNavigationController"];
    ItemAddContactsViewController *controller = (ItemAddContactsViewController *) navigationController.topViewController;
    controller.delegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)backToDesktop
{
    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
}

@end
