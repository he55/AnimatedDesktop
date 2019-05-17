//
//  HEApplication.m
//  AnimatedDesktop
//
//  Created by He55 on 2019/3/9.
//  Copyright © 2019 He55. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVKit/AVKit.h>
#import "HEConfig.h"
#import "HEApplication.h"

@interface HEApplication () {
    
}

@property (nonatomic) NSWindow *window;
@property (nonatomic) AVPlayerView *playerView;
@property (nonatomic) AVPlayer *player;

- (void)setupWindow;
- (void)loopPlay;
- (void)loopNotify:(NSNotification *)notification;

@end

@implementation HEApplication

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

+ (instancetype)application {
    return [self new];
}

- (instancetype)init {
    if (self = [super init]) {
        self.videoPath = @"";
        self.muted = YES;
    }
    return self;
}

- (instancetype)initWithVideoPath:(NSString *)videoPath {
    if (self = [super init]) {
        self.videoPath = videoPath;
        self.muted = YES;
    }
    return self;
}

+ (instancetype)applicationWithVideoPath:(NSString *)videoPath {
    return [[self alloc] initWithVideoPath:videoPath];
}

- (void)runAnimatedDesktop {
    [self setupWindow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loopPlay) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(loopNotify:) name:kHEAppName object:nil];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    [NSApp run];
}

- (void)setupWindow {
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 800, 600) styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskResizable | NSWindowStyleMaskClosable | NSWindowStyleMaskFullScreen backing:NSBackingStoreBuffered defer:NO];
    self.playerView = [AVPlayerView new];
    self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.videoPath]];
    
    self.window.title = kHEAppName;
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
    NSArray<NSString *> *args = [object componentsSeparatedByString:kHEArgumentSeparator];
    NSUInteger argCount = args.count;
    NSString *cmdMode = args[0];
    
    NSLog(@"name = \"%@\"", notification.name);
    NSLog(@"object = \"%@\"", object);
    
    // 命令处理
    if ([cmdMode isEqualToString:@"play"]) {
        if (argCount == 1) {
            [self.player play];
        } else if (argCount == 2) {
            NSString *videoPath = args[1];
            if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
                return;
            }
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:videoPath]];
            [self.player replaceCurrentItemWithPlayerItem:playerItem];
        }
    } else if ([cmdMode isEqualToString:@"pause"]) {
        if (argCount == 1) {
            [self.player pause];
        }
    } else if ([cmdMode isEqualToString:@"volume"]) {
        if (argCount == 1) {
            self.player.volume = 1.0;
        } else if (argCount == 2) {
            self.player.volume = args[1].floatValue;
        }
    } else if ([cmdMode isEqualToString:@"muted"]) {
        if (argCount == 1) {
            self.player.muted = !self.player.isMuted;
        } else if (argCount == 2) {
            self.player.muted = args[1].boolValue;
        }
    } else if ([cmdMode isEqualToString:@"exit"]) {
        if (argCount == 1) {
            exit(EXIT_SUCCESS);
        }
    }
}

@end
