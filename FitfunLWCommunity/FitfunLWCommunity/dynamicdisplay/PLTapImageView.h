////
//  PLTapImageView.h
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/15.
//Copyright © 2019年 penglei. All rights reserved.
//可点击的UIImageView

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLTapImageView : UIImageView

- (void)addTapBlock:(void(^)(id obj))tapAction;

-(void)setImageWithUrl:(NSURL *)imgUrl placeholderImage:(UIImage *)placeholderImage tapBlock:(void(^)(id obj))tapAction;

@end

NS_ASSUME_NONNULL_END
