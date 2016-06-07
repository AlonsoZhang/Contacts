//
//  Checklist.h
//  Checklists
//
//  Created by Alonso Zhang on 6/5/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Checklist : NSObject<NSCoding>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, copy) NSString *group;
@property (nonatomic, copy) NSString *iconName;//添加属性声明

- (int)countUncheckedItems;//添加⼀个方法声明

@end
