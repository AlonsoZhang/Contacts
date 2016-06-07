//
//  DataModel.m
//  Checklists
//
//  Created by Alonso Zhang on 6/8/15.
//  Copyright (c) 2015 Alonso Zhang. All rights reserved.
//

#import "DataModel.h"
#import "Checklist.h"

@implementation DataModel

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    //NSLog(@"%@",documentsDirectory);
    return documentsDirectory;
}

- (NSString *)dataFilePath
{
    return [[self documentsDirectory]stringByAppendingPathComponent:@"Checklists.plist"];
}

- (void)saveChecklists
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.lists forKey:@"Checklists"];
    //NSLog(@"list:%@",self.lists);
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePath] atomically:YES];
    //NSLog(@"path:%@",[self dataFilePath]);
}

- (void)loadChecklists
{
    NSString *path = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.lists = [unarchiver decodeObjectForKey:@"Checklists"];
        [unarchiver finishDecoding];
    }
    else
    {
        self.lists = [[NSMutableArray alloc] initWithCapacity:20];
    }
}

- (void)registerDefaults
{
    NSDictionary *dictionary = @{ @"ChecklistIndex" : @-1, @"FirstTime" : @YES };
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

- (void)handleFirstTime
{
    BOOL firstTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstTime"];
    if (firstTime)
    {
        Checklist *checklist = [[Checklist alloc] init];
        checklist.name = @"List";
        [self.lists addObject:checklist];
        [self setIndexOfSelectedChecklist:0];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstTime"];
    }
}

- (id)init
{
    if ((self = [super init]))
    {
        [self loadChecklists];
        //[self registerDefaults];
        //[self handleFirstTime];
    }
    return self;
}

- (NSInteger)indexOfSelectedChecklist
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"ChecklistIndex"];
}

- (void)setIndexOfSelectedChecklist:(NSInteger)index
{
    [[NSUserDefaults standardUserDefaults]setInteger:index forKey:@"ChecklistIndex"];
}

- (void)sortChecklists//排序
{
    [self.lists sortUsingSelector:@selector(compare:)];//需要使用compare:⽅法来对内容进⾏排序
}

@end
