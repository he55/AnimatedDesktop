//
//  main.m
//  AnimatedDesktop
//
//  Created by 何伟忠 on 2019/3/9.
//  Copyright © 2019 hummer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HUMApplication.h"

static void killapp(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSString *flags = @"--AnimatedDesktop=1100";
        
        if (![flags isEqualToString:@(argv[argc - 1])]) {
            if (argc < 2) {
                NSLog(@"传入的参数太少。");
                return -1;
            }
            
            NSString *filePath = @(argv[1]);
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSLog(@"文件 \"%@\" 不存在。", filePath);
                return -1;
            }
            
            NSLog(@"AnimatedDesktop is background run!");
            
            NSMutableArray<NSString *> *args = [NSMutableArray new];
            for (int i = 1; i < argc; i++) {
                [args addObject:@(argv[i])];
            }
            [args addObject:flags];
            
            NSTask *task = [NSTask new];
            task.executableURL = [NSURL fileURLWithPath:@(argv[0])];
            task.arguments = args;
            [task launch];
            
            return 0;
        }
        
        // 防止程序运行多个
        killapp();
        
        // 创建动态桌面类
        NSString *filePath = @(argv[1]);
        HUMApplication *app = [HUMApplication applicationWithVideoPath:filePath];
        if (argc > 3) {
            NSString *mutedString = @(argv[2]);
            app.muted = mutedString.boolValue;
        }
        
        [app runAnimatedDesktop];
    }
    return 0;
}

static void killapp(void) {
    pid_t cpid = getpid();
    NSPipe *pipe = [NSPipe new];
    NSTask *task = [NSTask new];
    task.executableURL = [NSURL fileURLWithPath:@"/bin/bash"];
    task.arguments = @[@"-c", @"ps axu | grep 'AnimatedDesktop=1100' | grep -v 'grep' | awk '{print $2}'"];
    task.standardOutput = pipe;
    
    [task launch];
    [task waitUntilExit];
    
    NSFileHandle *fileHandle = pipe.fileHandleForReading;
    NSData *data = [fileHandle readDataToEndOfFile];
    NSString *pidString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    for (NSString *pString in [pidString componentsSeparatedByString:@"\n"]) {
        int opid = pString.intValue;
        if (opid != 0 && opid != cpid) {
            // 结束进程
            kill(opid, SIGKILL);
        }
    }
}
