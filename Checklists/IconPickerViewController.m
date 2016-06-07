//
//  IconPickerViewController.m
//  Checklists
//
//  Created by Alonso Zhang on 6/9/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import "IconPickerViewController.h"

@interface IconPickerViewController ()

@end

@implementation IconPickerViewController
{
    NSArray *_icons;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //_icons = @[@"No Icon", @"Appointments", @"Birthdays", @"Chores", @"Drinks", @"Folder", @"Groceries", @"Inbox", @"Photos", @"Trips"];
    _icons = @[@"NULL",@"M5",@"BA",@"AM",@"OPM",@"MPM",@"FPM",@"EPM",@"PCC",@"PD",@"EE",@"RF",@"SW",@"WGT"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_icons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IconCell"];
    NSString *icon = _icons[indexPath.row];
    cell.textLabel.text = icon;
    cell.imageView.image = [UIImage imageNamed:icon];//便利模式初始化,image =[[UIImage alloc]initWithContentsOfFile:...];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath//触碰某一行时会调用代理⽅法
{
    NSString *iconName = _icons[indexPath.row];
    [self.delegate iconPicker:self didPickIcon:iconName];
}

@end
