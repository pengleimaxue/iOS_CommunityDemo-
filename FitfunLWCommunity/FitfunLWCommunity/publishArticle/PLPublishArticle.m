////
//  PLPublishArticle.m
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/15.
//Copyright © 2019年 penglei. All rights reserved.
//

#import "PLPublishArticle.h"
#import "SIXEditorView.h"
#import "UIView+PM.h"
@interface PLPublishArticle ()

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) SIXEditorView *editorView;


@end


@implementation PLPublishArticle


#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}


#pragma mark - private methond

- (void)setupView {
    [self addSubview:self.titleTextField];
    [self addSubview:self.editorView];
}

#pragma mark - getter && setter

- (UITextField *)titleTextField {
    if (!_titleTextField) {
        _titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, self.width-10, 30)];
        _titleTextField.placeholder = @"标题";
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, _titleTextField.height-1, _titleTextField.width,1);
        layer.backgroundColor = [UIColor lightGrayColor].CGColor;
//        _titleTextField.layer.borderColor = [UIColor blueColor].CGColor;
//        _titleTextField.layer.cornerRadius = 4;
        //_titleTextField.layer.borderWidth = 0.5;
        [_titleTextField.layer addSublayer:layer];
    }
    return _titleTextField;
}

- (SIXEditorView *)editorView {
    if (!_editorView) {
        _editorView = [[SIXEditorView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(self.titleTextField.frame), self.width-10, self.height -CGRectGetMaxY(self.titleTextField.frame))];
        _editorView.placeholderText = @"输入你的内容(2-10000字)";
        _editorView.limitLength = 10000;
    }
    return _editorView;
}

@end
