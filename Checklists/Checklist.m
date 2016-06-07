//
//  Checklist.m
//  Checklists
//
//  Created by Alonso Zhang on 6/5/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import "Checklist.h"
#import "ChecklistItem.h"

@implementation Checklist

- (id)init
{
    if ((self = [super init]))
    {
        self.items = [[NSMutableArray alloc] initWithCapacity:20];
        //self.iconName = @"Appointments";//验证
        self.iconName = @"No Icon";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        self.name = [aDecoder decodeObjectForKey:@"Name"];
        self.items = [aDecoder decodeObjectForKey:@"Items"];
        self.iconName = [aDecoder decodeObjectForKey:@"IconName"];
        self.group = [aDecoder decodeObjectForKey:@"Group"];//每当增加一个新的属性,都需要做类似的⼯作,保存到plist⽂件中
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"Name"];
    [aCoder encodeObject:self.items forKey:@"Items"];
    [aCoder encodeObject:self.iconName forKey:@"IconName"];//在Checklists.plist文件中保存icon名称
    [aCoder encodeObject:self.group forKey:@"Group"];
}

- (int)countUncheckedItems
{
    int count = 0;
    for (ChecklistItem *item in self.items)//遍历items数组中的所有ChecklistItem对象
    {
        if (!item.checked)
        {
            count += 1;
        }
    }
    return count;
}

- (NSComparisonResult)compare:(Checklist *)otherChecklist
{
    return [self.name localizedStandardCompare: otherChecklist.name];//⽐较两个name对象,并忽略⼤写和⼩写的区别,同时还会考虑所在地区的规则
}

@end
