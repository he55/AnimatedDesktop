//
//  HUMApplication.m
//  AnimatedDesktop
//
//  Created by 何伟忠 on 2019/3/9.
//  Copyright © 2019 hummer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVKit/AVKit.h>
#import "HUMApplication.h"

@interface HUMApplication () {
    NSWindow *_window;
    AVPlayerView *_playerView;
    AVPlayer *_player;
}

- (void)setupWindow;
- (void)loopPlay;

@end

@implementation HUMApplication

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static id instance = nil;
    if (!instance) {
        instance = [super allocWithZone:zone];
    }
    return instance;
}

+ (instancetype)application {
    return [self new];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loopPlay)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    [NSApp run];
}

- (void)setupWindow {
    _window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 800, 600)
                                          styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskResizable | NSWindowStyleMaskClosable | NSWindowStyleMaskFullScreen
                                            backing:NSBackingStoreBuffered
                                              defer:NO];
    
    _window.title = @"AnimatedDesktop";
    _window.ignoresMouseEvents = YES;
    _window.level = kCGDesktopIconWindowLevel - 1;
    [_window center];
    [_window setFrame:_window.screen.frame display:YES];
    [_window makeKeyAndOrderFront:nil];
    
    _playerView = [AVPlayerView new];
    _player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.videoPath]];
    
    _playerView.controlsStyle = AVPlayerViewControlsStyleNone;
    _playerView.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _playerView.player = _player;
    
    _player.muted = self.isMuted;
    // _player.volume = 0.0;
    [_player play];
    
    _window.contentView = _playerView;
}

- (void)loopPlay {
    [_player seekToTime:kCMTimeZero];
    [_player play];
}

@end
