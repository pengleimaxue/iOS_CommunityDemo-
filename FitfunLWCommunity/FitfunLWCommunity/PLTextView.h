////
//  PLTextView.h
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/12.
//Copyright © 2019年 penglei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLTextView : UITextView

@property (nonatomic, copy)  NSString * placeholderText;
@property (nonatomic, assign) NSUInteger limitLength;

//当前已输入文字长度
@property (nonatomic, assign) NSUInteger currentLength;
@end

NS_ASSUME_NONNULL_END
