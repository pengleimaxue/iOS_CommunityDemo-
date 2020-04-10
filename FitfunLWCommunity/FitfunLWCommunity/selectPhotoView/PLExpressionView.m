////
//  PLExpressionView.m
//  FitfunAssistant
//
//  Created by ___Fitfun___ on 2019/3/21.
//Copyright © 2019年 fitfun. All rights reserved.
//

#import "PLExpressionView.h"
#import "PLPageControl.h"
#import "FitFunSystemTool.h"
#import "EmotionTextAttachment.h"
#import "NSAttributedString+Emotion.h"

#define FACE_COUNT_ALL  85

#define FACE_COUNT_ROW  4

#define FACE_COUNT_CLU  7

#define FACE_COUNT_PAGE ( FACE_COUNT_ROW * FACE_COUNT_CLU )

#define FACE_ICON_SIZE  44

#define FACE_NAME_HEAD  @"/s"

// 表情转义字符的长度（ /s占2个长度，xxx占3个长度，共5个长度 ）
#define FACE_NAME_LEN   5

@interface PLExpressionView() <UIScrollViewDelegate>
//转义表情之后实际内容
@property (nonatomic, readwrite, copy) NSString *textString;
@property (nonatomic, strong) PLPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *expressionView;
@property (nonatomic, strong) NSMutableDictionary *expressionMap;
@property (nonatomic, strong) UIButton *deletButton;

@end

@implementation PLExpressionView


#pragma mark - init

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, FFSCREEN_WIDTH, 216)];
    if (self) {
        [self setupView];
    }
    return self;
        
}

#pragma mark - private methond

- (void)setupView {
     self.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1];
    for (int i = 1; i <= FACE_COUNT_ALL; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        
        [button addTarget:self
                       action:@selector(expressButton:)
             forControlEvents:UIControlEventTouchUpInside];
        
        //计算每一个表情按钮的坐标和在哪一屏
        CGFloat x = (((i - 1) % FACE_COUNT_PAGE) % FACE_COUNT_CLU) * FFDeviceWidth/7 +  + ((i - 1) / FACE_COUNT_PAGE * FFDeviceWidth);
        CGFloat y = (((i - 1) % FACE_COUNT_PAGE) / FACE_COUNT_CLU) * FACE_ICON_SIZE + 8;
        button.frame = CGRectMake( x, y, FFSCREEN_WIDTH/7, FACE_ICON_SIZE);
        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"em_%03d", i]];
        [button setImage:image forState:UIControlStateNormal];
        
        [self.expressionView addSubview:button];
    }
    [self addSubview:self.expressionView];
    [self addSubview:self.pageControl];
    [self addSubview:self.deletButton];
}


- (void)expressButton:(UIButton *)sender {
    
    NSInteger i = sender.tag;
    
    if (self.inputTextField) {
        EmotionTextAttachment *emotionTextAttachment = [EmotionTextAttachment new];
        emotionTextAttachment.emotionStr = [self.expressionMap objectForKey:[NSString stringWithFormat:@"%03ld", (long)i]];
        emotionTextAttachment.image = [UIImage imageNamed:[NSString stringWithFormat:@"%03ld", (long)i]];
        //存储光标位置
       int location = (int)self.inputTextView.selectedRange.location;
        //插入表情
        [self.inputTextView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:emotionTextAttachment] atIndex:self.inputTextView.selectedRange.location];
        //
        self.inputTextView.selectedRange = NSMakeRange(location+1, 0);
         [self.inputTextView setFont:[UIFont systemFontOfSize:14.f]];
        
    }
    
    if (self.inputTextView) {
        
        UIFont *font = self.inputTextView.font;
        EmotionTextAttachment *emotionTextAttachment = [EmotionTextAttachment new];
        emotionTextAttachment.emotionStr = [self.expressionMap objectForKey:[NSString stringWithFormat:@"em_%03d", i]];
        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"em_%03d", i]];
        emotionTextAttachment.image = image;
        //存储光标位置
        int location = (int)self.inputTextView.selectedRange.location;
        //插入表情
        [self.inputTextView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:emotionTextAttachment] atIndex:self.inputTextView.selectedRange.location];
        //光标位置移动1个单位
        self.inputTextView.selectedRange = NSMakeRange(location+1, 0);
        [self.inputTextView setFont:font];
        
    }
    if (self.insertExpressSuccess) {
        self.insertExpressSuccess();
    }
}

- (void)deleteText{
    [self.inputTextView deleteBackward];
}

//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self.pageControl setCurrentPage:self.expressionView.contentOffset.x /FFDeviceWidth];
    [self.pageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {
    
    [self.expressionView setContentOffset:CGPointMake(self.pageControl.currentPage * FFDeviceWidth, 0) animated:YES];
    [self.pageControl setCurrentPage:self.pageControl.currentPage];
}


#pragma mark - getter && setter

- (UIScrollView *)expressionView {
    if(!_expressionView) {
        _expressionView = [[UIScrollView alloc] initWithFrame:CGRectMake(8, 0, FFSCREEN_WIDTH, 190)];
        _expressionView.pagingEnabled = YES;
        _expressionView.contentSize = CGSizeMake((FACE_COUNT_ALL / FACE_COUNT_PAGE + 1) * FFSCREEN_WIDTH, 190);
        _expressionView.showsHorizontalScrollIndicator = NO;
        _expressionView.showsVerticalScrollIndicator = NO;
        _expressionView.delegate = self;
    }
    return _expressionView;
}

- (PLPageControl *)pageControl {
    if(!_pageControl) {
       _pageControl = [[PLPageControl alloc]initWithFrame:CGRectMake(FFSCREEN_WIDTH/2-50, 190, 100, 20)];
        
        [_pageControl addTarget:self
                            action:@selector(pageChange:)
                  forControlEvents:UIControlEventValueChanged];
        
        _pageControl.numberOfPages = FACE_COUNT_ALL / FACE_COUNT_PAGE + 1;
        _pageControl.currentPage = 0;
    }
    return _pageControl;
}

- (NSMutableDictionary *)expressionMap {
    if (!_expressionView) {
        _expressionMap= [[NSMutableDictionary alloc] initWithCapacity:0];
        for (NSInteger i = 1; i<=FACE_COUNT_ALL; i++) {
            [_expressionMap setObject:[NSString stringWithFormat:@"/s%03ld", (long)i] forKey:[NSString stringWithFormat:@"em_%03ld", (long)i]];
        }
    }
    return _expressionMap;
}

- (UIButton *)deletButton {
    if (!_deletButton) {
        _deletButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deletButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deletButton setImage:[UIImage imageNamed:@"del_emoji_normal"] forState:UIControlStateNormal];
        [_deletButton setImage:[UIImage imageNamed:@"del_emoji_select"] forState:UIControlStateSelected];
        [_deletButton addTarget:self action:@selector(deleteText) forControlEvents:UIControlEventTouchUpInside];
        _deletButton.frame = CGRectMake(FFSCREEN_WIDTH-50, 190, 28, 28);
    }
    return _deletButton;
}

- (NSString *)textString {
    if (!_textString) {
        if (self.inputTextField) {
            _textString = [[[NSAttributedString alloc] initWithString:self.inputTextField.text] mgo_getPlainString];
        }
        
        if ( self.inputTextView ) {
            
           _textString = [self.inputTextView.attributedText mgo_getPlainString];
        }
    }
    return _textString;
}



- (UIImage *)imageCore:(UIImage *)image scale:(float)scale {
    CGSize size = image.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,scaledWidth,scaledHeight)];
    UIImage* newImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
