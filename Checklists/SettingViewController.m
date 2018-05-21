//
//  SettingViewController.m
//  Checklists
//
//  Created by Alonso Zhang on 16/3/1.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import "SettingViewController.h"
#import "Checklists-Swift.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [ doc objectAtIndex:0 ];
    NSDictionary *dic = [ NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:@"setting.plist"]];
    NSString *psw = [dic objectForKey:@"admin"];
    self.password.text = psw;
    NSString *ip = [dic objectForKey:@"ip"];
    self.ipaddress.text = ip;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(UIButton *)sender {
    [self noticeTop:@"保存成功" autoClear:YES];
    NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [doc objectAtIndex:0];
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
    if ([self.ipaddress.text isEqualToString:@""]) {
        [newDic setObject:@"10.42.53.99" forKey:@"ip"];
         }else{
        [newDic setObject:self.ipaddress.text forKey:@"ip"];
    }
    if ([self.password.text isEqualToString:@""]) {
        [newDic setObject:@"123" forKey:@"admin"];
    }else{
        [newDic setObject:self.password.text forKey:@"admin"];
    }
    [newDic writeToFile:[docPath stringByAppendingPathComponent:@"setting.plist"] atomically:YES];
    
    [self.delegate settingViewControllerDidCancel:self];
    //NSLog(@"222:%@,%@,%@",[dic objectForKey:@"ip"],[dic objectForKey:@"admin"],self.password.text);
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self.delegate settingViewControllerDidCancel:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
