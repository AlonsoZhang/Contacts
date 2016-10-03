//
//  IconPickerViewController.h
//  Checklists
//
//  Created by Alonso Zhang on 6/9/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IconPickerViewController;
@protocol IconPickerViewControllerDelegate <NSObject>
- (void)iconPicker:(IconPickerViewController *)picker didPickIcon:(NSString *)iconName;
@end

@interface IconPickerViewController : UITableViewController

@property (nonatomic, weak) id <IconPickerViewControllerDelegate> delegate;

@end
