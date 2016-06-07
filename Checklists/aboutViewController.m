//
//  aboutViewController.m
//  Checklists
//
//  Created by Alonso Zhang on 16/2/25.
//  Copyright © 2016年 Alonso Zhang. All rights reserved.
//

#import "aboutViewController.h"
#import "PXAlertView.h"

@implementation aboutViewController

- (IBAction)back:(UIBarButtonItem *)sender {
    [self.delegate aboutViewControllerDidCancel:self];
}

- (IBAction)reset:(UIBarButtonItem *)sender {
    [PXAlertView showAlertWithTitle:@" 是否重置所有內容"
                            message:@"Reset all"
                        cancelTitle:@"否"
                         otherTitle:@"是"
                         completion:^(BOOL cancelled) {
                             if (cancelled) {
                                 NSLog(@"不重置");
                             } else {
                                 [self.delegate aboutViewControllerReset:self];
                             }
                         }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *htmlFile =[[NSBundle mainBundle]pathForResource:@"M5" ofType:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfFile:htmlFile];
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]bundlePath]];
    [self.webView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:baseURL];

}
//

@end
