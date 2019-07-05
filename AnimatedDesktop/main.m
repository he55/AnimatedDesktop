//
//  main.m
//  AnimatedDesktop
//
//  Created by He55 on 2019/3/9.
//  Copyright © 2019 He55. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEPrint.h"
#import "HEConst.h"
#import "HEAnimatedDesktop.h"

static BOOL appRun(void);
static void printHelp(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // 参数验证
        if (argc < 2) {
            printHelp();
            return -1;
        }
        
        NSString *cmdMode = @(argv[1]);
        if ([cmdMode isEqualToString:@"-h"] ||
            [cmdMode isEqualToString:@"--help"]) {
            printHelp();
            return 0;
        }
        
        if (![cmdMode isEqualToString:@"--play"] &&
            ![cmdMode isEqualToString:@"--pause"] &&
            ![cmdMode isEqualToString:@"--volume"] &&
            ![cmdMode isEqualToString:@"--muted"] &&
            ![cmdMode isEqualToString:@"--exit"]) {
            printHelp();
            return -1;
        }
        
        // 运行状态检查
        if (appRun()) {
            NSMutableArray<NSString *> *args = [NSMutableArray new];
            for (int i = 1; i < argc; i++) {
                [args addObject:@(argv[i])];
            }
            
            NSString *argString = [args componentsJoinedByString:HEArgumentSeparator];
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:HEAppName object:argString userInfo:nil deliverImmediately:YES];
            return 0;
        }
        
        if (argc < 3 ||
            ![cmdMode isEqualToString:@"--play"]) {
            printHelp();
            return -1;
        }
        
        NSString *videoPath = @(argv[2]);
        if (![fileManager fileExistsAtPath:videoPath]) {
            HEPrintln(@"File \"%@\" does not exist.", videoPath);
            return -1;
        }
        
        // 运行模式检查
        NSString *runMode = @(argv[argc - 1]);
        if (![runMode isEqualToString:HERunMode]) {
            NSMutableArray<NSString *> *args = [NSMutableArray new];
            for (int i = 1; i < argc; i++) {
                [args addObject:@(argv[i])];
            }
            [args addObject:HERunMode];
            
            NSTask *task = [NSTask new];
            task.executableURL = mainBundle.executableURL;
            task.arguments = args;
            
            NSError *error = nil;
            if (![task launchAndReturnError:&error]) {
                return -1;
            }
            
            return 0;
        }
        
        // 创建动态桌面
        HEAnimatedDesktop *animatedDesktop = [HEAnimatedDesktop sharedAnimatedDesktop];
        animatedDesktop.videoPath = videoPath;
        [animatedDesktop runAnimatedDesktop];
    }
    return 0;
}

static BOOL appRun(void) {
    NSTask *task = [NSTask new];
    NSPipe *pipe = [NSPipe new];
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSFileHandle *fileHandle = pipe.fileHandleForReading;
    int pid = processInfo.processIdentifier;
    
    // 查找进程 pid 的 shell 命令
    NSString *cmd = @"ps ax -o pid,command | grep '$flag' | grep -v 'grep' | awk '{print $1}'";
    NSString *fcmd = [cmd stringByReplacingOccurrencesOfString:@"$flag" withString:HERunMode];
    
    task.executableURL = [NSURL fileURLWithPath:@"/bin/bash"];
    task.arguments = @[@"-c", fcmd];
    task.standardOutput = pipe;
    
    NSError *error = nil;
    if (![task launchAndReturnError:&error]) {
        exit(EXIT_FAILURE);
    }
    
    [task waitUntilExit];
    
    NSData *data = [fileHandle readDataToEndOfFile];
    NSArray<NSString *> *pidStringArray = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"\n"];
    
    for (NSString *pidString in pidStringArray) {
        int opid = pidString.intValue;
        if (opid != 0 && opid != pid) {
            return YES;
        }
    }
    return NO;
}

static void printHelp(void) {
    char *help =
        "Usage: AnimatedDesktop [options] \n"
        "Animated desktop application. \n"
        "   --play FILE \n"
        "   --pause \n"
        "   --volume VALUE \n"
        "   --muted \n"
        "   --exit         exit application \n"
        "   -h, --help     prints usage information \n";
    
    printf("%s", help);
}
