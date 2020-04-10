////
//  NSButton+PLImageLayout.m
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/11.
//Copyright © 2019年 penglei. All rights reserved.
//

#import "UIButton+PLImageLayout.h"

@implementation UIButton (PLImageLayout)

- (void)fitPLButtonImageLocaltion:(PLButtonImageStyle)imageStyle
                  imageTitleSpace:(CGFloat)space {
    //1、获取imageView和titleLabel的高和宽
    CGFloat imageWidth = self.imageView.frame.size.width;
    CGFloat imageHeight = self.imageView.frame.size.height;
    CGFloat titleWidth = self.titleLabel.frame.size.width;
    CGFloat titleHeight = self.titleLabel.frame.size.height;
    
    //2、初始化一个内偏移
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets titleEdgeInsets = UIEdgeInsetsZero;
    if (imageWidth == 0) {
        imageWidth = self.imageView.intrinsicContentSize.width;
        imageHeight = self.imageView.intrinsicContentSize.height;
    }
    //3、不同的样式处理不同的内偏移
    switch (imageStyle) {
        case PLButtonImageStyleTop:
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, titleHeight + space / 2, -titleWidth);
            titleEdgeInsets = UIEdgeInsetsMake(imageHeight + space / 2, -imageWidth, 0, 0);
            break;
        case PLButtonImageStyleLeft:
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, space / 2);
            titleEdgeInsets = UIEdgeInsetsMake(0, space / 2, 0, 0);
            break;
        case PLButtonImageStyleBottom:
            imageEdgeInsets = UIEdgeInsetsMake(titleHeight + space / 2, 0, 0, -titleWidth);
            titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, imageHeight + space / 2, 0);
            break;
        case PLButtonImageStyleRight:
            imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth + space / 2, 0, -titleWidth);
            titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth - space / 2, 0, imageWidth);
            break;
        default:
            break;
    }
    //4、赋值
    self.imageEdgeInsets = imageEdgeInsets;
    self.titleEdgeInsets = titleEdgeInsets;
}


@end
