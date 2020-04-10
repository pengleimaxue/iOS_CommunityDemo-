////
//  PLExpressionView.h
//  FitfunAssistant
//
//  Created by ___Fitfun___ on 2019/3/21.
//Copyright © 2019年 fitfun. All rights reserved.
//自定义表情键盘

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLExpressionView : UIView

@property (nonatomic, strong) UITextField *inputTextField;

@property (nonatomic, weak) UITextView *inputTextView;

//转义表情之后实际内容
@property (nonatomic, readonly, copy) NSString *textString;

@property (nonatomic, copy)  dispatch_block_t insertExpressSuccess;

@end

NS_ASSUME_NONNULL_END
