//
//  ContactsListViewController.m
//  Checklists
//
//  Created by Alonso Zhang on 16/3/8.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import "ContactsListViewController.h"
#import "Checklists-Swift.h"

@interface ContactsListViewController ()

@end

@implementation ContactsListViewController{
    NSMutableArray *getContact;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    getContact = [[NSMutableArray alloc]init];
    NSString *documentsDirectory = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents"];
    NSString * contactscsvpath = [documentsDirectory stringByAppendingPathComponent:@"contact.csv"];
    NSString *contactscsv = [[NSString alloc] initWithContentsOfFile:contactscsvpath encoding:NSUTF8StringEncoding error:nil];
    if ([contactscsv rangeOfString:@"-"].location != NSNotFound){
        contactscsv = [contactscsv stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CNContactStore *cstore = [[CNContactStore alloc]init];
    [cstore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted,NSError *error){
        if (granted) {
            NSLog(@"Granted Permission");
            NSMutableArray *key = [[NSMutableArray alloc]initWithObjects:CNContactGivenNameKey,CNContactFamilyNameKey,CNContactDepartmentNameKey, CNContactPhoneNumbersKey,CNContactNicknameKey,nil];
            CNContactFetchRequest *fr = [[CNContactFetchRequest alloc]initWithKeysToFetch:key];
            [cstore enumerateContactsWithFetchRequest:fr error:nil usingBlock:^(CNContact *ct,BOOL *stop){
                if (![ct.departmentName isEqualToString: @""] && ![ct.nickname isEqualToString: @""]){
                    NSString * phoneNum = [[NSString alloc]init];
                    phoneNum = [self getPhoneNum:ct];
                    if([contactscsv rangeOfString:phoneNum].location == NSNotFound){
                        [self->getContact addObject:ct];
                    }
                    [self.tableView reloadData];
                }
            }];
        }else{
            NSLog(@"Denied Permission");
        }
        if (error) {
            NSLog(@"Error");
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.tableView reloadData];
    if ([getContact count] > 0) {
        [self.clearBtn setEnabled:YES];
    }else{
        [self.clearBtn setEnabled:NO];
        [self noticeOnlyText:@"暫無人員" autoClear:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getPhoneNum:(CNContact *)contact{
    CNPhoneNumber *pn;
    CNLabeledValue *lv;
    NSString * phoneNum = [[NSString alloc]init];
    for (lv in contact.phoneNumbers) {
        pn = lv.value;
        
        if (pn.stringValue.length == 14)
        {
            phoneNum = [pn.stringValue substringFromIndex:3];
            break;
        }
        else if (pn.stringValue.length == 9 || pn.stringValue.length == 8)
        {
            phoneNum = pn.stringValue;
            break;
        }
        else
        {
            phoneNum = pn.stringValue;
        }
    }
    if (phoneNum.length < 2) {
        phoneNum = @"無電話號碼";
    }
    return phoneNum;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return 0;
    return  [getContact count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];//初始化时在主表情的下⾯添加一个次级的⼩一点的标签
    cell.backgroundColor = [UIColor clearColor];
    CNContact *contact = getContact[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self getPhoneNum:contact]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CNContact *contact = getContact[indexPath.row];
    NSString *phonenumber = [self getPhoneNum:contact];
    NSString *name = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:name message:[NSString stringWithFormat:@"%@\n所在群組\"%@\"",contact.nickname,contact.departmentName] preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *callaction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"📞:%@",phonenumber] style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if (phonenumber.length > 6) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phonenumber]] options:@{} completionHandler:nil];
            NSLog(@"call phonenumber");
        }
    }];
    UIAlertAction *deleteaction = [UIAlertAction actionWithTitle:@"刪除（此操作不可撤銷）" style: UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        
        //初始化方法
        CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
        //删除联系人
        CNMutableContact * mutableContact = [contact mutableCopy];
        [saveRequest deleteContact:mutableContact];
        CNContactStore * store = [[CNContactStore alloc]init];
        [store executeSaveRequest:saveRequest error:nil];
        [self->getContact removeObject:contact];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView reloadData];
    }];
    UIAlertAction *cancelaction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
    }];
    
    [alert addAction:callaction];
    [alert addAction:deleteaction];
    [alert addAction:cancelaction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)clear:(UIBarButtonItem *)sender {
    [PXAlertView showAlertWithTitle:@"清空離職及無號碼人員"
                            message:@"該操作不可撤銷"
                        cancelTitle:@"取消"
                         otherTitle:@"刪除"
                         completion:^(BOOL cancelled) {
                             if (cancelled) {
                                 
                             } else {
                                 //初始化方法
                                 CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
                                 for (NSUInteger i = [self->getContact count]; i > 0; i--) {
                                     CNContact *contact = self->getContact[i - 1];
                                     //删除联系人
                                     CNMutableContact * mutableContact = [contact mutableCopy];
                                     [saveRequest deleteContact:mutableContact];
                                     [self->getContact removeObject:contact];
                                 }
                                 CNContactStore * store = [[CNContactStore alloc]init];
                                 [store executeSaveRequest:saveRequest error:nil];
                                 [self.tableView reloadData];
                                 [self.clearBtn setEnabled:NO];
                             }
                         }];
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self.delegate contactsListViewControllerDidCancel:self];
}

@end
