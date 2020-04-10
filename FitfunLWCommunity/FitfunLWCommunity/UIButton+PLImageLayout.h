////
//  NSString+PLImageLayout.h
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/11.
//Copyright © 2019年 penglei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,PLButtonImageStyle) {
    //图片在上文字在下
    PLButtonImageStyleTop,
    //图片在左，文字在右
    PLButtonImageStyleLeft,
    //图片在下，文件在上
    PLButtonImageStyleBottom,
    //图片在右，文字在左
    PLButtonImageStyleRight
};

@interface UIButton (PLImageLayout)


- (void)fitPLButtonImageLocaltion:(PLButtonImageStyle )imageStyle
     imageTitleSpace:(CGFloat)space;
@end

NS_ASSUME_NONNULL_END
