//
//  AllListsViewController.m
//  Checklists
//
//  Created by Alonso Zhang on 6/5/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import "AllListsViewController.h"
#import "Checklist.h"
#import "ChecklistViewController.h"
#import "ChecklistItem.h"
#import "DataModel.h"
#import "Checklists-Swift.h"
#import "NirKxMenu.h"
#import "RZTouchID.h"
#import "AppDelegate.h"
#import "RZViewController.h"


@interface AllListsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *disableTouchIDButton;
@end

@implementation AllListsViewController{
    NSString *allname;
    NSMutableArray *contacts;
    NSString *documentsDirectory;
    NSArray *actual;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        self.touchIDLoginDisabled = NO;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    //创建文件管理器
    NSFileManager *fileMgr = [NSFileManager defaultManager];//指向文件目录
    documentsDirectory= [NSHomeDirectory()stringByAppendingPathComponent:@"Documents"];
    NSLog(@"Documentsdirectory: %@",[fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil]);
    //NSArray *array = [NSArray arrayWithObject:nil];
    if([[fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil]count] < 2){
        if ([self connectip]) {
            [self loaddata:[self returnContents]];
            [PXAlertView showAlertWithTitle:@"右上角為快捷菜單" message:@"首次登陸將會自動幫您彈出" cancelTitle:@"我已了解！" completion:^(BOOL cancelled) {
                if (cancelled) {
                    [self actionList:self.actionlist];
                }
            }];
        }
        else
        {
            //读取本地数据
            [self loaddata:[self returnLocalContents]];
            [PXAlertView showAlertWithTitle:@"無網絡連接，為您加載本地數據" message:@"首次登陸將會自動幫您彈出菜单" cancelTitle:@"我已了解！" completion:^(BOOL cancelled) {
                if (cancelled) {
                    [self actionList:self.actionlist];
                }
            }];
        }
    }else{
        NSLog(@"文件已创立");
    }

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉更新数据"];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
}

- (void)refresh{
    [self updateToLast];
    [self.refreshControl endRefreshing];
}

- (NSString *)returnLocalContents{
    [self clearAllNotice];
    //[self noticeTop:@"無網絡連接，為您加載本地數據" autoClear:YES];
    NSString *contents = [[NSString alloc]init];
    
//    NSString *localcontentsTPE = [[NSBundle mainBundle] pathForResource:@"TPE" ofType:@"csv"];
//    NSString *contentsTPE = [[NSString alloc] initWithContentsOfFile:localcontentsTPE encoding:NSUTF8StringEncoding error:nil];
//    NSString *localcontentsWKS = [[NSBundle mainBundle] pathForResource:@"WKS" ofType:@"csv"];
//    NSString *contentsWKS = [[NSString alloc] initWithContentsOfFile:localcontentsWKS encoding:NSUTF8StringEncoding error:nil];
//    if ([contentsTPE isEqualToString:@""]||[contentsWKS isEqualToString:@""]) {
//        contents = @"";
//    }else{
//        contents = [NSString stringWithFormat:@"%@\n%@",contentsTPE,contentsWKS];
//    }
    NSString *localcontents = [[NSBundle mainBundle] pathForResource:@"51" ofType:@"csv"];
    contents = [[NSString alloc] initWithContentsOfFile:localcontents encoding:NSUTF8StringEncoding error:nil];
    return contents;
}

- (NSString *)returnContents{
    NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [doc objectAtIndex:0];
    NSDictionary *dic = [ NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:@"setting.plist"]];
    NSString *ip = [dic objectForKey:@"ip"];
    //将云端csv保存在本地
    //NSURL *newURL =[NSURL URLWithString :@"http://7xrqwh.com1.z0.glb.clouddn.com/All.csv"];
    //NSURL *newURL =[NSURL URLWithString :@"http://127.0.0.1/WKS.csv"];
    
    __block NSString *contentsTPE = [[NSString alloc]init];
    //__block NSString *contentsWKS = [[NSString alloc]init];
    //先创建一个semaphore
    dispatch_semaphore_t semaphoreTPE = dispatch_semaphore_create(0);
    //dispatch_semaphore_t semaphoreWKS = dispatch_semaphore_create(0);

    NSURL *urlTPE =[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/51.csv",ip]];
    //NSURL *urlWKS =[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/M5/WKS.csv",ip]];
    //注意！准备 CSV 的格式为每行：(部門中文名),(序號),部門,(IDL/DL),姓名,英文名,工號,(職務),分機,手機,短號,速撥,\n
    //总共12个逗号，内容可有可无但必须对应，主要是老板那个 CSV 的档需要增加两个空白列。
    NSURLRequest *theRequestTPE=[NSURLRequest requestWithURL:urlTPE
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:2.0];
    [[[NSURLSession sharedSession]dataTaskWithRequest:theRequestTPE completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        //NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        if ([httpResponse statusCode] == 200) {
            NSString * responsedata = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            contentsTPE = responsedata;
        }
        //发出已完成的信号
        dispatch_semaphore_signal(semaphoreTPE);
    }]resume];
    //等待执行，不会占用资源
    dispatch_semaphore_wait(semaphoreTPE, DISPATCH_TIME_FOREVER);
    
//    NSURLRequest *theRequestWKS=[NSURLRequest requestWithURL:urlWKS
//                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                             timeoutInterval:2.0];
//    [[[NSURLSession sharedSession]dataTaskWithRequest:theRequestWKS completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//        //NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
//        if ([httpResponse statusCode] == 200) {
//            NSString * responsedata = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            contentsWKS = responsedata;
//        }
//        //发出已完成的信号
//        dispatch_semaphore_signal(semaphoreWKS);
//    }]resume];
//    //等待执行，不会占用资源
//    dispatch_semaphore_wait(semaphoreWKS, DISPATCH_TIME_FOREVER);
    //NSURL *newURL =[NSURL URLWithString :@"http://10.42.53.11/WKS.csv"];
    //NSString *contents = [[NSString alloc]initWithContentsOfURL:newURL encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"%@",contents);
    NSString *contents = [[NSString alloc]init];
    contents = contentsTPE;
//    if ([contentsTPE isEqualToString:@""]||[contentsWKS isEqualToString:@""]) {
//        contents = @"";
//    }else{
//        contents = [NSString stringWithFormat:@"%@\n%@",contentsTPE,contentsWKS];
//    }
    return contents;
}

- (BOOL)connectip{
    if ([[self returnContents] isEqualToString: @""]) {
        [self errorNotice:@"無網絡連接" autoClear:YES];
        [self noticeTop:@"請檢查網絡狀況或者服務器IP是否正確" autoClear:YES];
        return NO;
    }else{
        return YES;
    }
}

- (void)loaddata:(NSString*)contents{
    NSString *filePath= [documentsDirectory stringByAppendingPathComponent:@"contact.csv"];
    [contents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //通过CHCSVParser解析本地csv文件
    //NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    //NSURL *fileURL = [bundle URLForResource:@"WKS" withExtension:@"csv"];
    NSURL *fileURL =[NSURL URLWithString :[NSString stringWithFormat:@"file://%@",filePath]];
    actual = [NSArray arrayWithContentsOfCSVURL:fileURL];
    allname = @"";
    NSString *sortlabelPlistPath = [[NSBundle mainBundle] pathForResource:@"sortlabel" ofType:@"plist"];
    NSArray *sortlabelarray = [[NSArray alloc] initWithContentsOfFile:sortlabelPlistPath];
    
    for (int i = 0; i < [actual count]; i++) {
        NSString* departmentname = actual[i][1];
        //因为表格内 function 信息有误，确保正确的话可以重写一个通用方法。
        for (int departmentitem = 0; departmentitem < [sortlabelarray count]; departmentitem++)
        {
            [self showdepartment:[[sortlabelarray objectAtIndex:departmentitem] objectForKey:@"department"] rangekeyword:[[sortlabelarray objectAtIndex:departmentitem] objectForKey:@"rangekeyword"] withoutkeyword:[[sortlabelarray objectAtIndex:departmentitem] objectForKey:@"withoutkeyword"] withoutanother:[[sortlabelarray objectAtIndex:departmentitem] objectForKey:@"withoutanother"] picture:[[sortlabelarray objectAtIndex:departmentitem] objectForKey:@"picture"] name:departmentname];
        }
    }
    Contacts *contactclass = [[Contacts alloc] init];
    contacts = [[NSMutableArray alloc] init];
    contacts = [contactclass fetchcontact];
    [self noticeTop:@"已更新完毕" autoClear:YES];
}

- (void)showdepartment:(NSString *)departname rangekeyword:(NSString *)keyword withoutkeyword:(NSString *)without withoutanother:(NSString *)without2 picture:(NSString *)pic name:(NSString *)name
{
    if ([allname rangeOfString:keyword].location == NSNotFound && [name rangeOfString:keyword].location != NSNotFound && [name rangeOfString:without].location == NSNotFound && [name rangeOfString:without2].location == NSNotFound) {
        CNMutableGroup *group = [[CNMutableGroup alloc]init];
        group.name = [NSString stringWithFormat:@"51-%@",pic];
        allname = [NSString stringWithFormat:@"%@,%@",allname,name];
        Checklist *list;
        list = [[Checklist alloc] init];
        list.name = departname;
        list.group = group.name;
        [self.dataModel.lists addObject:list];
        list.iconName = pic;
        for (int j = 0; j < [actual count]; j++) {
            NSString* bmname = actual[j][1];
            ChecklistItem *item;
            item = [[ChecklistItem alloc] init];
            
            //中文名
            item.name = [actual[j][2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([item.name rangeOfString:@"（"].location != NSNotFound){
                NSRange range = [item.name rangeOfString:@"（"];
                item.name = [[item.name substringToIndex:range.location]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            if ([item.name rangeOfString:@"("].location != NSNotFound){
                NSRange range = [item.name rangeOfString:@"("];
                item.name = [[item.name substringToIndex:range.location]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            if ([item.name rangeOfString:@" "].location != NSNotFound){
                item.name = [[item.name stringByReplacingOccurrencesOfString:@" " withString:@""]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            
            
            
            if ([bmname rangeOfString:keyword].location != NSNotFound && [bmname rangeOfString:without].location == NSNotFound && [bmname rangeOfString:without2].location == NSNotFound){
                
                //英文名
                item.engname = [actual[j][3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([item.engname isEqualToString:@"/"]) {
                    item.engname = @"DL";
                }
                if ([item.engname rangeOfString:@"_"].location != NSNotFound){
                    item.engname = [item.engname stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                }
                if ([item.engname rangeOfString:@"."].location != NSNotFound){
                    item.engname = [item.engname stringByReplacingOccurrencesOfString:@"." withString:@""];
                }
                
                //显示名称：中文名 英文名
                item.text = [NSString stringWithFormat:@"%@ %@",item.name,item.engname];
                
                //手机号
                NSString *allphonenumber = @"";
                allphonenumber = [NSString stringWithFormat:@"%@/%@/%@",[actual[j][7]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],[actual[j][8]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],[actual[j][14]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                //allphonenumber = [actual[j][8]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                //NSLog(@"%@",item.phonenumber);
                if ([allphonenumber rangeOfString:@"-"].location != NSNotFound){
                    allphonenumber = [allphonenumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                }
                if ([allphonenumber rangeOfString:@"(USA)"].location != NSNotFound){
                    allphonenumber = [allphonenumber stringByReplacingOccurrencesOfString:@"(USA)" withString:@""];
                }
                if ([allphonenumber rangeOfString:@"(TW)"].location != NSNotFound){
                    allphonenumber = [allphonenumber stringByReplacingOccurrencesOfString:@"(TW)" withString:@""];
                }
                if ([allphonenumber rangeOfString:@" "].location != NSNotFound){
                    allphonenumber = [allphonenumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                }
                if ([allphonenumber rangeOfString:@"\""].location != NSNotFound){
                    allphonenumber = [allphonenumber stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                }
                if ([allphonenumber rangeOfString:@"\n"].location != NSNotFound){
                    allphonenumber = [allphonenumber stringByReplacingOccurrencesOfString:@"\n" withString:@"/"];
                }
                NSMutableArray *phoneArray = [NSMutableArray arrayWithArray:[allphonenumber componentsSeparatedByString:@"/"]];
                //NSLog(@"%@",phoneArray);
                for (int k = 0; k < [phoneArray count]; k++)
                {
                    if ([phoneArray[k] length] == 9)
                    {
                        if ([phoneArray[k] hasPrefix:@"9"])
                        {
                            if (item.twphonenumber == nil)
                            {
                                item.twphonenumber = phoneArray[k];
                            }
                            else
                            {
                                item.otherphonenumber = phoneArray[k];
                            }
                        }
                    }
                    else if ([phoneArray[k] length] == 10)
                    {
                        if ([phoneArray[k] hasPrefix:@"09"])
                        {
                            if (item.twphonenumber == nil)
                            {
                                item.twphonenumber = phoneArray[k];
                            }
                            else
                            {
                                item.otherphonenumber = phoneArray[k];
                            }
                        }
                        if ([phoneArray[k] hasPrefix:@"62"])
                        {
                            item.usaphonenumber = phoneArray[k];
                        }
                    }
                    else if([phoneArray[k] length] > 10)
                    {
                        if (item.phonenumber == nil)
                        {
                            item.phonenumber = [NSString stringWithFormat:@"+86%@",phoneArray[k]];
                        }
                        else
                        {
                            item.otherphonenumber = [NSString stringWithFormat:@"+86%@",phoneArray[k]];
                        }
                    }
                }
                
                //短号
                item.shortnumber = [actual[j][11]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([item.shortnumber isEqualToString:@"/"] || [item.shortnumber isEqualToString:@"无"] || [item.shortnumber isEqualToString:@""]) {
                    item.shortnumber = nil;
                }
                
                //部门/工号
                item.departmentnumber = [NSString stringWithFormat:@"%@/%@",actual[j][1],actual[j][4]];
                
                //速拨
                item.subo = [actual[j][9]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([item.subo isEqualToString:@"/"] || [item.subo isEqualToString:@"无"]) {
                    item.subo = @"";
                }
                if ([item.subo rangeOfString:@"-"].location != NSNotFound){
                    item.subo = [item.subo stringByReplacingOccurrencesOfString:@"-" withString:@""];
                }
                if ([item.subo rangeOfString:@"\""].location != NSNotFound){
                    item.subo = [item.subo stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                }
                if ([item.subo rangeOfString:@"\n"].location != NSNotFound){
                    item.subo = [item.subo stringByReplacingOccurrencesOfString:@"\n" withString:@"/"];
                }
                
                if (![actual[j][10] isEqualToString:@""] && ![actual[j][10] isEqualToString:@"/"]) {
                    item.subo = [NSString stringWithFormat:@"(WKS)%@/(WNH)%@",item.subo,[actual[j][10]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                }
                
                //分机
                item.fenji = [actual[j][5]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([item.fenji isEqualToString:@"/"] || [item.fenji isEqualToString:@"无"]) {
                    item.fenji = @"";
                }
                if ([item.fenji rangeOfString:@"\""].location != NSNotFound){
                    item.fenji = [item.fenji stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                }
                if ([item.fenji rangeOfString:@"\n"].location != NSNotFound){
                    item.fenji = [item.fenji stringByReplacingOccurrencesOfString:@"\n" withString:@"/"];
                }
                
                if (![actual[j][6] isEqualToString:@""] && ![actual[j][6] isEqualToString:@"/"]) {
                    if ([item.fenji isEqualToString:@""]) {
                        item.fenji = [NSString stringWithFormat:@"(WNH)%@",[actual[j][6]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    }else{
                         item.fenji = [NSString stringWithFormat:@"(WKS)%@/(WNH)%@",item.fenji,[actual[j][6]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    }
                }
                
                //群组
                item.groupname = group.name;
                
                //是否已在通讯录
                //关于判断更新的可以多加一个标志位 updated
                for (CNContact *contact in contacts) {
                    //&& [contact.phoneNumbers rangeOfString:item.phonenumber].location != NSNotFound
                    if ([item.name isEqualToString:[NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName]] && [item.engname isEqualToString:contact.nickname] && [item.groupname isEqualToString:contact.departmentName] ) {
                        item.checked = YES;
                        break;
                    }else{
                        item.checked = NO;
                    }
                }
                
                [list.items addObject:item];
            }
        }
    }
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    Contacts * contactclass = [[Contacts alloc] init];
    contacts = [[NSMutableArray alloc] init];
    contacts = [contactclass fetchcontact];
    
    [self.tableView reloadData];
    
    if (self.touchIDLoginDisabled){
        self.navigationItem.leftBarButtonItem = nil;
    }
    //self.disableTouchIDButton.hidden = self.touchIDLoginDisabled;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//首次登陆载入
/*- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
    NSInteger index = [self.dataModel indexOfSelectedChecklist];
    if (index >= 0 && index < [self.dataModel.lists count])
    {
        Checklist *checklist = self.dataModel.lists[index];
        [self performSegueWithIdentifier:@"ShowChecklist" sender:checklist];
    }
}*/

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataModel.lists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //if (cell == nil)
    //{
        //cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];//初始化时在主表情的下⾯添加一个次级的⼩一点的标签
    //}
    Checklist *checklist = self.dataModel.lists[indexPath.row];
    cell.textLabel.text = checklist.name;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Remaining", [checklist countUncheckedItems]];//设置标签的文本内容
    int count = [checklist countUncheckedItems];
    if ([checklist.items count] == 0)
    {
        cell.detailTextLabel.text = @"沒有人員";
    }
    else if (count == 0)
    {
        cell.detailTextLabel.text = @"已全部添加！";
    }
    else
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d人未添加", count];
    }
    cell.imageView.image = [UIImage imageNamed:checklist.iconName];//显示图片内容
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //cell.layer.transform = CATransform3DMakeTranslation(0, -100, 0);
    cell.layer.transform = CATransform3DMakeScale(1, 0, 1);
    [UIView animateWithDuration:0.2 animations:^{
        //cell.layer.transform = CATransform3DMakeTranslation(0, 0, 0);
        cell.layer.transform = CATransform3DMakeScale(1, 1, 1);
    }];
    
    
//    CATransform3D rotation;
//    rotation = CATransform3DMakeRotation( (90.0*M_PI)/180, 0.0, 0.7, 0.4);
//    rotation.m34 = 1.0/ -600;
//    
//    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
//    cell.layer.shadowOffset = CGSizeMake(10, 10);
//    cell.alpha = 0;
//    cell.layer.transform = rotation;
//    cell.layer.anchorPoint = CGPointMake(0, 0.5);
//    
//    
//    [UIView beginAnimations:@"rotation" context:NULL];
//    [UIView setAnimationDuration:0.8];
//    cell.layer.transform = CATransform3DIdentity;
//    cell.alpha = 1;
//    cell.layer.shadowOffset = CGSizeMake(0, 0);
//    [UIView commitAnimations];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.dataModel setIndexOfSelectedChecklist:indexPath.row];
    
    Checklist *checklist = self.dataModel.lists[indexPath.row];
    [self performSegueWithIdentifier:@"ShowChecklist" sender:checklist];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowChecklist"])
    {
        ChecklistViewController *controller = segue.destinationViewController;
        controller.checklist = sender;
    }
    else if ([segue.identifier isEqualToString:@"AddChecklist"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        ListDetailViewController *controller = (ListDetailViewController *)navigationController.topViewController;
        controller.delegate = self;
        controller.checklistToEdit = nil;
    }
}

- (void)listDetailViewControllerDidCancel: (ListDetailViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)listDetailViewController:(ListDetailViewController *)controller
        didFinishAddingChecklist:(Checklist *)checklist
{
    //NSInteger newRowIndex = [self.dataModel.lists count];
    [self.dataModel.lists addObject:checklist];
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
    //NSArray *indexPaths = @[indexPath];
    //[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //[self.dataModel sortChecklists];//排序
    [self.tableView reloadData];//只需要简单调⽤reloadData⽅法就可以更新整个表的内容
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)listDetailViewController:(ListDetailViewController *)controller didFinishEditingChecklist:(Checklist *)checklist
{
//    NSInteger index = [self.dataModel.lists indexOfObject:checklist];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    cell.textLabel.text = checklist.name;
    
    //[self.dataModel sortChecklists];//排序
    [self.tableView reloadData];//只需要简单调⽤reloadData⽅法就可以更新整个表的内容
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *indexPaths = @[indexPath];
    
    Contacts *contact = [[Contacts alloc] init];
    CNContactStore * store = [[CNContactStore alloc]init];
    CNSaveRequest * deleteContactRequest = [[CNSaveRequest alloc]init];
    [self.dataModel setIndexOfSelectedChecklist:indexPath.row];
    Checklist *checklist = self.dataModel.lists[indexPath.row];
    for (ChecklistItem* checklistitem in checklist.items){
        for (CNContact *existconst in contacts) {
            if ([[NSString stringWithFormat:@"%@%@",existconst.familyName,existconst.givenName] isEqualToString:checklistitem.name] && [existconst.nickname isEqualToString:checklistitem.engname] && [existconst.departmentName isEqualToString:checklistitem.groupname]) {
                //删除联系人
                CNMutableContact * mutableContact = [existconst mutableCopy];
                [deleteContactRequest deleteContact:mutableContact];
                NSLog(@"已删除%@",checklistitem.name);
                checklistitem.checked = NO;
                break;
            }
        }
    }
    [store executeSaveRequest:deleteContactRequest error:nil];
    [contact deleteGroup:checklist.group];
    [PXAlertView showAlertWithTitle:@"已將該部門從iPhone移除"
                            message:@"app內是否保留數據\(更新數據可恢復)"
                        cancelTitle:@"保留"
                         otherTitle:@"刪除"
                         completion:^(BOOL cancelled) {
                             if (cancelled) {
                                 [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
                             } else {
                                 [self.dataModel.lists removeObjectAtIndex:indexPath.row];
                                 [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                             }
                         }];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:
(NSIndexPath *)indexPath
{
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier: @"ListNavigationController"];
    ListDetailViewController *controller = (ListDetailViewController *) navigationController.topViewController;
    controller.delegate = self;
    Checklist *checklist = self.dataModel.lists[indexPath.row];
    controller.checklistToEdit = checklist;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self)
    {
        [self.dataModel setIndexOfSelectedChecklist:-1];
    }
}

- (IBAction)actionList:(UIBarButtonItem *)sender {
    UIView *barButtonView = [sender valueForKey:@"view"];
    CGRect frame = barButtonView.frame;
    frame.origin.y = frame.origin.y +30;
    //内容配置
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"一鍵導入51完整通訊錄"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(addAllContacts)],
      
      [KxMenuItem menuItem:@"更新數據"
                     image:[UIImage imageNamed:@"reload"]
                    target:self
                    action:@selector(updateToLast)],
      
      [KxMenuItem menuItem:@"添加一個新部門"
                     image:[UIImage imageNamed:@"add"]
                    target:self
                    action:@selector(addNewDepartment)],
      
      [KxMenuItem menuItem:@"瀏覽本機通訊錄"
                     image:[UIImage imageNamed:@"search_icon"]
                    target:self
                    action:@selector(checkLocalContacts)],
      
      [KxMenuItem menuItem:@"離職人員"
                     image:[UIImage imageNamed:@"group"]
                    target:self
                    action:@selector(offContacts)],
      
      [KxMenuItem menuItem:@"修改密碼"
                     image:[UIImage imageNamed:@"lock"]
                    target:self
                    action:@selector(changepassoword)],
      
      [KxMenuItem menuItem:@"關於"
                     image:[UIImage imageNamed:@"question"]
                    target:self
                    action:@selector(help)],
      
      [KxMenuItem menuItem:@"註銷并退回至桌面"
                     image:[UIImage imageNamed:@"home_icon"]
                    target:self
                    action:@selector(backToDesktop)]
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
        options.marginYSpacing = 16, //MenuItem上下边距
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

- (void)addNewDepartment
{
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier: @"ListNavigationController"];
    ListDetailViewController *controller = (ListDetailViewController *) navigationController.topViewController;
    controller.delegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)alertviewmsg
{
    [self pleaseWait];
    [self noticeTop:@"根據不同的iPhone型號，全部導入需要3~5秒，請耐心等待 ^_^ " autoClear:YES];
}

- (void)addAllContacts
{
    [NSThread detachNewThreadSelector:@selector(alertviewmsg)
                             toTarget:self
                           withObject:nil];
    Contacts *contact = [[Contacts alloc] init];
    int count = 0;
    CNContactStore * store = [[CNContactStore alloc]init];
    NSArray *groups = [store groupsMatchingPredicate:nil error:nil];
    for (Checklist * list in self.dataModel.lists) {
        BOOL addnewgroup = true;
        for (CNMutableGroup * existgroup in groups) {
            if ([list.group isEqualToString:existgroup.name]) {
                addnewgroup = false;
                break;
            }
        }
        if (addnewgroup) {
            CNMutableGroup *newgroup = [[CNMutableGroup alloc]init];
            CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
            newgroup.name = list.group;
            [saveRequest addGroup:newgroup toContainerWithIdentifier:nil];
            [store executeSaveRequest:saveRequest error:nil];
            NSLog(@"添加:%@",newgroup.name);
        }
    }
    groups = [store groupsMatchingPredicate:nil error:nil];
    CNSaveRequest * saveContactRequest = [[CNSaveRequest alloc]init];
    CNSaveRequest * addGroupRequest = [[CNSaveRequest alloc]init];
    CNMutableGroup *group = [[CNMutableGroup alloc]init];
    for (Checklist * list in self.dataModel.lists) {
        for (CNMutableGroup * existgroup in groups) {
            if ([list.group isEqualToString:existgroup.name]) {
                group = existgroup;
                break;
            }
        }
        for (ChecklistItem* item in list.items) {
            //2.为contact赋值
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
    }
    NSLog(@"1");
    [store executeSaveRequest:saveContactRequest error:nil];
    NSLog(@"2");
    [store executeSaveRequest:addGroupRequest error:nil];
    NSLog(@"3");
    [self clearAllNotice];
    if (count == 0) {
        [self noticeOnlyText:@"已全部添加" autoClear:YES];
    }else{
        [self noticeOnlyText:[NSString stringWithFormat:@"新添加%d人",count] autoClear:YES];
    }
    [self.tableView reloadData];
    NSLog(@"4");
    //[self clearAllNotice];
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

- (void)updateToLast
{
    //先删再重新添加
    if ([self connectip]) {
        for (unsigned long i = [self.dataModel.lists count]; i > 0; i--) {
            [self.dataModel.lists removeObjectAtIndex:i-1];
        }
        [self loaddata:[self returnContents]];
    }
    [self.tableView reloadData];
}

- (void)backToDesktop
{
    [self performSegueWithIdentifier:@"meunwind" sender:nil];
    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
}

- (void)help
{
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier: @"AboutNavigationController"];
    aboutViewController *controller = (aboutViewController *)navigationController.topViewController;
    controller.delegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)settingViewControllerDidCancel:(SettingViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)aboutViewControllerDidCancel:(aboutViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)aboutViewControllerReset:(aboutViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    Contacts * contactclass = [[Contacts alloc] init];
    contacts = [[NSMutableArray alloc] init];
    contacts = [contactclass fetchcontact];
    CNContactStore * store = [[CNContactStore alloc]init];
    CNSaveRequest * deleteGroupRequest = [[CNSaveRequest alloc]init];
    CNSaveRequest * deleteContactRequest = [[CNSaveRequest alloc]init];
    NSArray *groups = [store groupsMatchingPredicate:nil error:nil];
    for (int i = 0 ; i < [self.dataModel.lists count]; i++) {
        //[self.dataModel setIndexOfSelectedChecklist:i];
        Checklist *checklist = self.dataModel.lists[i];
        for (ChecklistItem* checklistitem in checklist.items){
            for (CNContact *existconst in contacts) {
                if ([[NSString stringWithFormat:@"%@%@",existconst.familyName,existconst.givenName] isEqualToString:checklistitem.name] && [existconst.nickname isEqualToString:checklistitem.engname] && [existconst.departmentName isEqualToString:checklistitem.groupname]) {
                    //删除联系人
                    CNMutableContact * mutableContact = [existconst mutableCopy];
                    NSLog(@"delete:%@%@",existconst.familyName,existconst.givenName);
                    [deleteContactRequest deleteContact:mutableContact];
                    checklistitem.checked = NO;
                    break;
                }
            }
        }
        
        //删除分组
        for (CNMutableGroup * existgroup in groups) {
            if ([checklist.group isEqualToString:existgroup.name]) {
                [deleteGroupRequest deleteGroup:existgroup];
                NSLog(@"已删除分组:%@",existgroup.name);
                break;
            }
        }
    }
    NSLog(@"1");
    [store executeSaveRequest:deleteContactRequest error:nil];
    NSLog(@"2");
    @try {
        [store executeSaveRequest:deleteGroupRequest error:nil];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    NSLog(@"3");
    [self updateToLast];
    NSLog(@"4");
    [self updateToLast];
}

- (IBAction)searchcontact:(UIBarButtonItem *)sender
{
    [self checkLocalContacts];
}

- (void)changepassoword
{
    //[self noticeOnlyText:@"not ready (⊙﹏⊙)b !" autoClear:YES];
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier: @"SettingNavigationController"];
    SettingViewController *controller = (SettingViewController *)navigationController.topViewController;
    controller.delegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)disableTouchID:(UIBarButtonItem *)sender {
    [PXAlertView showAlertWithTitle:@"是否關閉 Touch ID"
                            message:@"（可在登錄界面重新開啟） "
                        cancelTitle:@"否"
                         otherTitle:@"是"
                         completion:^(BOOL cancelled) {
                             if (cancelled) {
                                 NSLog(@"不关闭");
                             } else {
                                 [self noticeTop:@"已關閉 Touch ID" autoClear:YES];
                                 NSString *loggedInUser = [[NSUserDefaults standardUserDefaults] objectForKey:kRZTouchIdLoggedInUser];
                                 [[AppDelegate sharedTouchIDInstance] deletePasswordWithIdentifier:loggedInUser completion:^(NSString *password, NSError *error) {
                                     self.navigationItem.leftBarButtonItem = nil;
                                     //self.disableTouchIDButton.hidden = YES;
                                     self.touchIDLoginDisabled = YES;
                                 }];
                             }
                         }];
}

- (void)offContacts{
    UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier: @"ContactsListNav"];
    ContactsListViewController *controller2 = (ContactsListViewController *)navigationController.topViewController;
    controller2.delegate = self;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)contactsListViewControllerDidCancel:(ContactsListViewController *)controller{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
