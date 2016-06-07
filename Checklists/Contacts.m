//
//  Contacts.m
//  Checklists
//
//  Created by Alonso Zhang on 16/2/17.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import "Contacts.h"

@implementation Contacts

//设置要保存的contact对象
- (void)setNewContact:(CNMutableContact *)contact name:(NSString *)fullname engname:(NSString *)englishname phoneNum:(NSString *)phonenumber shortNum:(NSString *)shortphonenumber twNum:(NSString *)twphonenumber usaNum:(NSString *)usaphonenumber otherNum:(NSString *)otherphonenumber department:(NSString *)department{
    //设置姓氏
    contact.familyName = [fullname substringToIndex:1];//是开始位置截取到指定位置但是不包含指定位置
    //设置名字
    contact.givenName = [fullname substringFromIndex:1];//从指定的字符串开始到尾部
    
    contact.nickname = englishname;
    
    NSMutableArray *mutablephonearray = [[NSMutableArray alloc]init];
    //CNLabelPhoneNumberMobile手机号
    if (phonenumber != nil) {
        CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:phonenumber]];
        [mutablephonearray addObject:phoneNumber];
    }
    if (shortphonenumber != nil) {
        CNLabeledValue *shortNumber = [CNLabeledValue labeledValueWithLabel:@"短號" value:[CNPhoneNumber phoneNumberWithStringValue:shortphonenumber]];
        [mutablephonearray addObject:shortNumber];
    }
    if (twphonenumber != nil) {
        CNLabeledValue *twNumber = [CNLabeledValue labeledValueWithLabel:@"TW" value:[CNPhoneNumber phoneNumberWithStringValue:twphonenumber]];
        [mutablephonearray addObject:twNumber];
    }
    if (usaphonenumber != nil) {
        CNLabeledValue *usaNumber = [CNLabeledValue labeledValueWithLabel:@"USA" value:[CNPhoneNumber phoneNumberWithStringValue:usaphonenumber]];
        [mutablephonearray addObject:usaNumber];
    }
    if (otherphonenumber != nil) {
        CNLabeledValue *otherNumber = [CNLabeledValue labeledValueWithLabel:CNLabelOther value:[CNPhoneNumber phoneNumberWithStringValue:otherphonenumber]];
        [mutablephonearray addObject:otherNumber];
    }
    NSArray *myArray = [mutablephonearray copy];
    contact.phoneNumbers = myArray;
    contact.departmentName = department;
}

//添加一个联系人到指定分组
- (void)savecontact:(CNMutableContact *)contact{
    //初始化方法
    CNSaveRequest * saveContactRequest = [[CNSaveRequest alloc]init];
    CNContactStore * store = [[CNContactStore alloc]init];
    //添加联系人
    [saveContactRequest addContact:contact toContainerWithIdentifier:nil];
    [store executeSaveRequest:saveContactRequest error:nil];
    if ([contact.departmentName isEqualToString:@""]) {
        return;
    }
    
    CNSaveRequest * saveGroupRequest = [[CNSaveRequest alloc]init];
    //添加到分组
    NSArray *groups = [store groupsMatchingPredicate:nil error:nil];
    for (CNMutableGroup * existgroup in groups) {
        if ([contact.departmentName isEqualToString:existgroup.name]) {
            //添加联系人
            [saveGroupRequest addMember:contact toGroup:existgroup];
            [store executeSaveRequest:saveGroupRequest error:nil];
            return;
        }
    }
    
    CNSaveRequest * saveNewGroupRequest = [[CNSaveRequest alloc]init];
    //新建分组并添加
    CNMutableGroup *newgroup = [[CNMutableGroup alloc]init];
    newgroup.name = contact.departmentName;
    [saveNewGroupRequest addGroup:newgroup toContainerWithIdentifier:nil];
    [store executeSaveRequest:saveNewGroupRequest error:nil];
    //先保存再重新 request
    [saveGroupRequest addMember:contact toGroup:newgroup];
    [store executeSaveRequest:saveGroupRequest error:nil];
}

//删除一个联系人从指定分组
- (void)deleteContact:(CNContact *)contact{
    //初始化方法
    CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
    //删除联系人
    CNMutableContact * mutableContact = [contact mutableCopy];
    [saveRequest deleteContact:mutableContact];
    CNContactStore * store = [[CNContactStore alloc]init];
    [store executeSaveRequest:saveRequest error:nil];
}

- (void)deleteGroup:(NSString *)group{
    //初始化方法
    CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
    //删除分组
    CNContactStore * store = [[CNContactStore alloc]init];
    NSArray *groups = [store groupsMatchingPredicate:nil error:nil];
    for (CNMutableGroup * existgroup in groups) {
        if ([group isEqualToString:existgroup.name]) {
            [saveRequest deleteGroup:existgroup];
            @try {
                [store executeSaveRequest:saveRequest error:nil];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
            NSLog(@"已删除分组:%@",existgroup.name);
            break;
        }
    }
}

//匹配通讯录所有联系人
- (NSMutableArray *)fetchcontact{
    //先创建一个semaphore
    //dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CNContactStore *store = [[CNContactStore alloc] init];
    NSMutableArray *contacts = [NSMutableArray array];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        // make sure the user granted us access
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // user didn't grant access;
                // so, again, tell user here why app needs permissions in order  to do it's job;
                // this is dispatched to the main queue because this request could be running on background thread
            });
            return;
        }
        // build array of contacts
        NSError *fetchError;
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactPhoneNumbersKey, [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactDepartmentNameKey]];
        BOOL success = [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
            [contacts addObject:contact];
        }];
        if (!success) {
            NSLog(@"error = %@", fetchError);
        }
        // you can now do something with the list of contacts, for example, to show the names
        //CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
        //发出已完成的信号
        dispatch_semaphore_signal(semaphore);
    }];
    //等待执行，不会占用资源
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return contacts;
}

#pragma mark - CNContactViewControllerDelegate
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact{
    [viewController dismissViewControllerAnimated:YES completion:^{
    }];
}

//#pragma mark - CNContactPickerDelegate
//2.实现点选的代理，其他代理方法根据自己需求实现
//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
//    [picker dismissViewControllerAnimated:YES completion:^{
//        //3.copy一份可写的Contact对象，不要尝试alloc一类，mutableCopy独此一家
//        CNMutableContact *c = [contact mutableCopy];
//        //4.为contact赋值
//        //[self setValue4Contact:c existContect:YES];
//        //5.跳转到新建联系人页面
//        CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:c];
//        controller.delegate = self;
//        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
////        [self presentViewController:navigation animated:YES completion:^{
////        }];
//    }];
//}

@end
