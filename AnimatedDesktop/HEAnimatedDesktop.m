//
//  HEAnimatedDesktop.m
//  AnimatedDesktop
//
//  Created by He55 on 2019/3/9.
//  Copyright © 2019 He55. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVKit/AVKit.h>
#import "HEPrint.h"
#import "HEConst.h"
#import "HEAnimatedDesktop.h"

@interface HEAnimatedDesktop ()

@property (nonatomic) NSWindow *window;
@property (nonatomic) AVPlayerView *playerView;
@property (nonatomic) AVPlayer *player;

- (void)setupWindow;
- (void)loopPlay;
- (void)loopNotify:(NSNotification *)notification;

@end

@implementation HEAnimatedDesktop

+ (instancetype)sharedAnimatedDesktop {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedAnimatedDesktop];
}

- (instancetype)init {
    if (self = [super init]) {
        _videoPath = @"";
        _muted = YES;
    }
    return self;
}

- (void)runAnimatedDesktop {
    [self setupWindow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loopPlay) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(loopNotify:) name:HEAppName object:nil];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    [NSApp run];
}

- (void)setupWindow {
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 800, 600) styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskResizable | NSWindowStyleMaskClosable | NSWindowStyleMaskFullScreen backing:NSBackingStoreBuffered defer:NO];
    self.playerView = [AVPlayerView new];
    self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.videoPath]];
    
    self.window.title = HEAppName;
    self.window.ignoresMouseEvents = YES;
    self.window.level = kCGDesktopIconWindowLevel - 1;
    [self.window center];
    [self.window setFrame:self.window.screen.frame display:YES];
    [self.window makeKeyAndOrderFront:nil];
    
    self.playerView.controlsStyle = AVPlayerViewControlsStyleNone;
    self.playerView.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.playerView.player = self.player;
    
    self.player.muted = self.isMuted;
    // self.player.volume = 0.0;
    [self.player play];
    
    self.window.contentView = self.playerView;
}

- (void)loopPlay {
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)loopNotify:(NSNotification *)notification {
    NSString *object = notification.object;
    NSArray<NSString *> *args = [object componentsSeparatedByString:HEArgumentSeparator];
    NSUInteger argsCount = args.count;
    NSString *cmdMode = args[0];
    
    HEPrintln(@"name = \"%@\"", notification.name);
    HEPrintln(@"object = \"%@\"", object);
    
    // 命令处理
    if ([cmdMode isEqualToString:@"--play"]) {
        if (argsCount == 1) {
            [self.player play];
        } else if (argsCount == 2) {
            NSString *videoPath = args[1];
            if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
                return;
            }
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:videoPath]];
            [self.player replaceCurrentItemWithPlayerItem:playerItem];
        }
    } else if ([cmdMode isEqualToString:@"--pause"]) {
        if (argsCount == 1) {
            [self.player pause];
        }
    } else if ([cmdMode isEqualToString:@"--volume"]) {
        if (argsCount == 1) {
            self.player.volume = 1.0;
        } else if (argsCount == 2) {
            self.player.volume = args[1].floatValue;
        }
    } else if ([cmdMode isEqualToString:@"--muted"]) {
        if (argsCount == 1) {
            self.player.muted = !self.player.isMuted;
        } else if (argsCount == 2) {
            self.player.muted = args[1].boolValue;
        }
    } else if ([cmdMode isEqualToString:@"--exit"]) {
        if (argsCount == 1) {
            exit(EXIT_SUCCESS);
        }
    }
}

@end
