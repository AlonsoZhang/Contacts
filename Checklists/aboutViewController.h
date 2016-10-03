//
//  aboutViewController.h
//  Checklists
//
//  Created by Alonso Zhang on 16/2/25.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class aboutViewController;

@protocol AboutViewControllerDelegate <NSObject>
- (void)aboutViewControllerDidCancel:(aboutViewController *)controller;
- (void)aboutViewControllerReset:(aboutViewController *)controller;

@end

@interface aboutViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, weak) id <AboutViewControllerDelegate> delegate;
@end