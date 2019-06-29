//
//  HEAnimatedDesktop.h
//  AnimatedDesktop
//
//  Created by He55 on 2019/3/9.
//  Copyright © 2019 He55. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HEAnimatedDesktop : NSObject

@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, getter=isMuted) BOOL muted;

+ (instancetype)sharedAnimatedDesktop;
- (void)runAnimatedDesktop;

@end

NS_ASSUME_NONNULL_END
