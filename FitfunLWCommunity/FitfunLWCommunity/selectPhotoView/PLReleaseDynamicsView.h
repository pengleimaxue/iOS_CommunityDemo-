////
//  PLReleaseDynamics.h
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/14.
//Copyright © 2019年 penglei. All rights reserved.
//发布动态的视图

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,PLReleaseDynamicsJurisdiction) {
    //公开
    PLReleaseDynamicsJurisdictionPublic,
    //仅好友可见
    PLReleaseDynamicsJurisdictionFriends,
};

NS_ASSUME_NONNULL_BEGIN

@interface PLReleaseDynamicsView : UIView

@property (nonatomic, assign) PLReleaseDynamicsJurisdiction style;

@end

NS_ASSUME_NONNULL_END
