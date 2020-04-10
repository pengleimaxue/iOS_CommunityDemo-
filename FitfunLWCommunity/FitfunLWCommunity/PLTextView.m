////
//  PLTextView.m
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/12.
//Copyright © 2019年 penglei. All rights reserved.
//

#import "PLTextView.h"


@interface PLTextView() <UITextViewDelegate>

@property (nonatomic, strong) UILabel *wordCountLabel;
@property (nonatomic, strong) UILabel *placeholderLabel;
@end


@implementation PLTextView

@synthesize wordCountLabel = _wordCountLabel;

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        self.delegate = self;
    }
    return self;
}


#pragma mark -UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    //换行符不加入字符统计
   NSString * text = [self.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSUInteger wordCurrentWord = text.length;
    self.placeholderLabel.hidden = (wordCurrentWord > 0);
    
    NSString *keyboardType = self.textInputMode.primaryLanguage;
    //中文处理 高亮状态下允许输入框里输入超过限制字数的拼音
    if ([keyboardType containsString:@"zh"]) {
        //高亮状态
        UITextRange *range = self.markedTextRange;
        //不是高亮状态
        if (range == nil) {
            if (wordCurrentWord > self.limitLength) {
               NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];

               [attributedText deleteCharactersInRange:NSMakeRange(self.limitLength+1, wordCurrentWord-self.limitLength-1)];
              self.attributedText = attributedText;
            }
        }
    } else {
        if (wordCurrentWord > self.limitLength) {
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
            
            [attributedText deleteCharactersInRange:NSMakeRange(self.limitLength+1, wordCurrentWord-self.limitLength-1)];
            self.attributedText = attributedText;
        }
    }
    if (wordCurrentWord > self.limitLength ) {
        wordCurrentWord = self.limitLength ;
    }
    self.currentLength = wordCurrentWord;
    self.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%ld",wordCurrentWord,self.limitLength];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
}
#pragma mark - private methond


- (void)setupView {
    [self addSubview:self.placeholderLabel];
    [self addSubview:self.wordCountLabel];
//    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.layer.cornerRadius = 4;
//    self.layer.borderWidth = 0.5;
}


//计算文本高度
- (CGSize)getStringPlaceSize:(NSString *)string textFont:(UIFont *)font bundingSize:(CGSize)boundSize {
    NSDictionary *attribute = @{NSFontAttributeName:font};
    NSStringDrawingOptions option = (NSStringDrawingOptions)(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading);
    CGSize size = [string boundingRectWithSize:boundSize options:option attributes:attribute context:nil].size;
    return size;
}

#pragma mark -getter && setter

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _placeholderLabel.font = [UIFont systemFontOfSize:15.f];
        _placeholderLabel.textColor = [UIColor lightGrayColor];
        _placeholderLabel.numberOfLines = 0;
    }
    return _placeholderLabel;
}

- (UILabel *)wordCountLabel {
    if (!_wordCountLabel) {
        _wordCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _wordCountLabel.font = [UIFont systemFontOfSize:15.f];
        _wordCountLabel.textAlignment = NSTextAlignmentRight;
        _wordCountLabel.textColor = [UIColor lightGrayColor];
    }
    return _wordCountLabel;
}

- (void)setLimitLength:(NSUInteger)limitLength {
    _limitLength = limitLength;
    self.wordCountLabel.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 20, CGRectGetWidth(self.frame) - 7, 20);
    self.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    if (self.text.length > limitLength) {
        self.text = [self.text substringToIndex:limitLength];
    }
    self.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.text.length,limitLength];
}

- (void)setPlaceholderText:(NSString *)placeholderText {
    _placeholderText = [placeholderText copy];
    CGSize rect = [self getStringPlaceSize:placeholderText textFont:self.placeholderLabel.font bundingSize:CGSizeMake(CGRectGetWidth(self.frame)-7, CGFLOAT_MAX)];
    self.placeholderLabel.frame = CGRectMake(10, 10, rect.width, rect.height);
    self.placeholderLabel.text = placeholderText;
    self.placeholderLabel.hidden = (self.text.length >0);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_wordCountLabel) {
       self.wordCountLabel.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 20+ self.contentOffset.y, CGRectGetWidth(self.frame) - 7, 20);
    }
    if (_placeholderLabel) {
        CGSize rect = [self getStringPlaceSize:self.placeholderText textFont:self.placeholderLabel.font bundingSize:CGSizeMake(CGRectGetWidth(self.frame)-7, CGFLOAT_MAX)];
        self.placeholderLabel.frame = CGRectMake(10, 10, rect.width, rect.height);
    }
    
}

- (void)setCurrentLength:(NSUInteger)currentLength {
    _currentLength = currentLength;
    if (currentLength>0) {
        self.placeholderLabel.hidden = YES;
    } else {
        self.placeholderLabel.hidden = NO;
    }
    self.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%ld",currentLength,self.limitLength];
}

@end
