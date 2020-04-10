////
//  PLCustomCollectionView.m
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/15.
//Copyright © 2019年 penglei. All rights reserved.
//

#import "PLCustomCollectionView.h"

@implementation PLCustomCollectionView

//当事件是传递给此View内部的子View时，让子View自己捕获事件，如果是传递给此View自己时，放弃事件捕获
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView* __tmpView = [super hitTest:point withEvent:event];
    if (__tmpView == self) {
        return nil;
    }
    return __tmpView;
}

@end
