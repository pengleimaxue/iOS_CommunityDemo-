////
//  PLButton.m
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/12.
//Copyright © 2019年 penglei. All rights reserved.
//

#import "PLButton.h"
#import "UIView+PM.h"

@interface PLButton()

@property (nonatomic, assign) PLButtonImageStyle style;
@property (nonatomic, assign) CGFloat space;

@end

@implementation PLButton


- (void)pl_fitButtonImageLocaltion:(PLButtonImageStyle)imageStyle
                  imageTitleSpace:(CGFloat)space {
    self.style = imageStyle;
    self.space = space;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat centerX = self.width * 0.5;
    CGFloat centerY = self.height * 0.5;
    CGFloat padding = self.space * 0.5;
    CGFloat allWidth = self.imageView.width + self.titleLabel.width;
    CGFloat allHeight = self.imageView.height + self.titleLabel.height;
    
    switch (self.style) {
        case PLButtonImageStyleTop:
        {
            self.imageView.x = centerX - self.imageView.width * 0.5;
            self.imageView.y = centerY - allHeight * 0.5 - padding;
            self.titleLabel.x = centerX - self.titleLabel.width * 0.5;
            self.titleLabel.y = CGRectGetMaxY(self.imageView.frame) + padding * 2;
        }
            break;
        case PLButtonImageStyleLeft:
        {
            self.imageView.x = centerX - allWidth * 0.5 - padding;
            self.titleLabel.x = CGRectGetMaxX(self.imageView.frame) + padding * 2;
        }
            break;
        case PLButtonImageStyleBottom:
        {
            self.titleLabel.x = centerX - self.titleLabel.width * 0.5;
            self.titleLabel.y = centerY - allHeight * 0.5 - padding;
            self.imageView.x = centerX - self.imageView.width * 0.5;
            self.imageView.y = CGRectGetMaxY(self.titleLabel.frame) + padding * 2;
        }
            break;
        case PLButtonImageStyleRight:
        {
            self.titleLabel.x = centerX - allWidth * 0.5 - padding;
            self.imageView.x = CGRectGetMaxX(self.titleLabel.frame) + padding * 2;
        }
            break;
        default:
            break;
    }
    
}

@end
