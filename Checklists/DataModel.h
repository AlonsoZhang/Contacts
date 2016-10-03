//
//  DataModel.h
//  Checklists
//
//  Created by Alonso Zhang on 6/8/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

@property (nonatomic, strong) NSMutableArray *lists;
- (void)saveChecklists;
- (NSInteger)indexOfSelectedChecklist;
- (void)setIndexOfSelectedChecklist:(NSInteger)index;

- (void)sortChecklists;//排序

@end
