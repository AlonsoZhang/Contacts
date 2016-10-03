//
//  ItemAddContactsViewController.m
//  Checklists
//
//  Created by Alonso Zhang on 16/1/26.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import "ItemAddContactsViewController.h"
#import "ChecklistItem.h"
#import "Checklists-swift.h"
#import "NirKxMenu.h"


@interface ItemAddContactsViewController ()
@end

@implementation ItemAddContactsViewController

Contacts * contact;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.itemToEdit != nil)
    {
        self.title = @"個人信息";
        self.textField.text = self.itemToEdit.text;
        self.phoneShortNum.text = self.itemToEdit.shortnumber;
        self.departNum.text = self.itemToEdit.departmentnumber;
        self.fenjiNum.text = self.itemToEdit.fenji;
        self.suboNum.text = self.itemToEdit.subo;
        self.twphoneNum.text = self.itemToEdit.twphonenumber;
        self.usaphoneNum.text = self.itemToEdit.usaphonenumber;
        self.otherphoneNum.text = self.itemToEdit.otherphonenumber;
        if (self.itemToEdit.phonenumber == nil)
        {
            [self.phonetable setHidden:YES];
            self.hideCell = self.phonetable;
        }else
        {
            self.phoneNum.text = self.itemToEdit.phonenumber;
        }
        if (self.itemToEdit.twphonenumber == nil)
        {
            [self.twphonetable setHidden:YES];
            self.twhideCell = self.twphonetable;
        }else
        {
            self.twphoneNum.text = self.itemToEdit.twphonenumber;
        }
        if (self.itemToEdit.usaphonenumber == nil)
        {
            [self.usaphonetable setHidden:YES];
            self.usahideCell = self.usaphonetable;
        }else
        {
            self.usaphoneNum.text = self.itemToEdit.usaphonenumber;
        }
        if (self.itemToEdit.otherphonenumber == nil)
        {
            [self.otherphonetable setHidden:YES];
            self.otherhideCell = self.otherphonetable;
        }else
        {
            self.otherphoneNum.text = self.itemToEdit.otherphonenumber;
        }
        self.doneBarButton.enabled = YES;
    }
}

//讲号码那一块没有的 cell 隐藏掉
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if(cell == self.hideCell) return 0;
    if(cell == self.twhideCell) return 0;
    if(cell == self.usahideCell) return 0;
    if(cell == self.otherhideCell) return 0;
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    
    view.backgroundColor = [UIColor clearColor];
    
    [tableView setTableFooterView:view];
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
    [self.delegate itemAddContactsViewControllerDidCancel:self];
}

- (IBAction)addContacts:(UIBarButtonItem *)sender
{
    UIView *barButtonView = [sender valueForKey:@"view"];
    CGRect frame = barButtonView.frame;
    frame.origin.y = frame.origin.y +30;
    //内容配置
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"一鍵添加"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(autoAddContact)],
      [KxMenuItem menuItem:@"手動添加"
                     image:[UIImage imageNamed:@"add"]
                    target:self
                    action:@selector(manualAddContact)],
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

- (void)autoAddContact
{
    contact = [[Contacts alloc] init];
    //1.创建Contact对象，必须是可变的
    CNMutableContact *c = [[CNMutableContact alloc] init];
    //2.为contact赋值
    [contact setNewContact:c name:self.itemToEdit.name engname:self.itemToEdit.engname phoneNum:self.itemToEdit.phonenumber shortNum:self.itemToEdit.shortnumber twNum:self.itemToEdit.twphonenumber usaNum:self.itemToEdit.usaphonenumber otherNum:self.itemToEdit.otherphonenumber department:self.itemToEdit.groupname];
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    contacts = [contact fetchcontact];
    for (CNContact *existconst in contacts) {
        if ([[NSString stringWithFormat:@"%@%@",existconst.familyName,existconst.givenName] isEqualToString:self.itemToEdit.name] && [existconst.nickname isEqualToString:self.itemToEdit.engname] && [existconst.departmentName isEqualToString:self.itemToEdit.groupname]) {
            [self errorNotice:@"请勿重复添加" autoClear:YES];
            [self.delegate itemAddContactsViewControllerDidCancel:self];
            return;
        }
    }
    [contact savecontact:c];
    [self noticeTop:@"添加成功！" autoClear:YES];
    self.itemToEdit.checked = YES;
    [self.delegate itemAddContactsViewControllerDidCancel:self];
}

- (void)manualAddContact
{
    [self noticeOnlyText:@"手动添加不能设置分组，请慎用" autoClear:YES];
    contact = [[Contacts alloc] init];
    //1.创建Contact对象，必须是可变的
    CNMutableContact *c = [[CNMutableContact alloc] init];
    //2.为contact赋值
    [contact setNewContact:c name:self.itemToEdit.name engname:self.itemToEdit.engname phoneNum:self.itemToEdit.phonenumber shortNum:self.itemToEdit.shortnumber twNum:self.itemToEdit.twphonenumber usaNum:self.itemToEdit.usaphonenumber otherNum:self.itemToEdit.otherphonenumber department:self.itemToEdit.groupname];
    CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:c];
    //代理内容根据自己需要实现
    controller.delegate = contact;
    //4.跳转
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigation animated:YES completion:^{
    }];
    //[contact addgroup:c toGroup:self.itemToEdit.groupname];
}

//点击号码拨打电话
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPathe
{
    if (indexPathe.section == 2){
        if (indexPathe.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.itemToEdit.phonenumber] ]options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @YES} completionHandler:nil];
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.itemToEdit.phonenumber]]];
            NSLog(@"phonenumber");
        }
        if (indexPathe.row == 1){
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.itemToEdit.twphonenumber]]];
        }
        if (indexPathe.row == 2){
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.itemToEdit.usaphonenumber]]];
        }
        if (indexPathe.row == 3){
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.itemToEdit.otherphonenumber]]];
        }
    }
    if (indexPathe.section == 3){
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.itemToEdit.shortnumber]]];
    }
    return nil;
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [theTextField.text stringByReplacingCharactersInRange:range withString:string];
    self.doneBarButton.enabled = ([newText length] > 0);
    return YES;
}
@end
