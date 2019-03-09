//
//  HUMApplication.h
//  AnimatedDesktop
//
//  Created by 何伟忠 on 2019/3/9.
//  Copyright © 2019 hummer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HUMApplication : NSObject

@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, getter=isMuted) BOOL muted;

+ (instancetype)application;

- (instancetype)initWithVideoPath:(NSString *)videoPath;
+ (instancetype)applicationWithVideoPath:(NSString *)videoPath;

- (void)runAnimatedDesktop;

@end

NS_ASSUME_NONNULL_END
