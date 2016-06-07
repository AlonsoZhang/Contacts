//
//  SettingViewController.h
//  Checklists
//
//  Created by Alonso Zhang on 16/3/1.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingViewController;

@protocol SettingViewControllerDelegate <NSObject>
- (void)settingViewControllerDidCancel:(SettingViewController *)controller;
@end

@interface SettingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *ipaddress;
@property (nonatomic, weak) id <SettingViewControllerDelegate> delegate;
@end