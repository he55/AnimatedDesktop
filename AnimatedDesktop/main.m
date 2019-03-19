//
//  main.m
//  AnimatedDesktop
//
//  Created by 何伟忠 on 2019/3/9.
//  Copyright © 2019 hummer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HUMApplication.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSString *flags = @"--make";
        
        if (argc < 2) {
             NSLog(@"传入的参数太少。");
            return -1;
        }
        
        if (![flags isEqualToString:@(argv[argc - 1])]) {
            NSMutableArray<NSString *> *args = [NSMutableArray new];
            for (int i = 1; i < argc; i++) {
                [args addObject:@(argv[i])];
            }
            [args addObject:flags];
            
            NSTask *task = [NSTask new];
            task.launchPath = @(argv[0]);
            task.arguments = args;
            [task launch];
            
            return 0;
        }
        
        NSString *filePath = @(argv[1]);
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSLog(@"文件 \"%@\" 不存在。", filePath);
            return -1;
        }
        
        NSLog(@"AnimatedDesktop is run!");
        
        // 创建动态桌面类
        HUMApplication *app = [HUMApplication applicationWithVideoPath:filePath];
        
        if (argc >= 3) {
            NSString *mutedString = @(argv[2]);
            app.muted = [mutedString boolValue];
        }
        
        [app runAnimatedDesktop];
    }
    return 0;
}
