//
//  SIXTextView.m
//  SIXRichEditor
//
//  Created by  on 2018/7/29.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXEditorView.h"
#import "SIXEditorToolBar.h"
#import "SIXEditorInputManager.h"
#import "PPStickerKeyboard.h"
#import "PPUtil.h"
#import "PPStickerDataManager.h"

@interface SIXEditorView ()<PPStickerKeyboardDelegate>
{
    CGFloat fontSize;
//    NSTextAlignment six_textAlignment;
    UIColor *textColor;
    
    BOOL isBold;
    BOOL isItalic;
    BOOL isUnderline;
    
    SIXEditorAction action;
}

@property (nonatomic, strong) SIXEditorInputManager *inputManager;
@property (nonatomic, strong) PPStickerKeyboard *stickerKeyboard;

@end

@implementation SIXEditorView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        fontSize = 14;
        textColor = [UIColor blackColor];
        isBold = NO;
        isItalic = NO;
        isUnderline = NO;
        action = SIXEditorActionNone;
        
        self.textColor = textColor;
        self.selectable = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.font = [UIFont systemFontOfSize:fontSize];
//        self.placeholder = @"点击屏幕，开始编辑。。。";
        
        [self resetTypingAttributes];
        
        //键盘控制器
        _inputManager = [[SIXEditorInputManager alloc] init];
        _inputManager.editorView = self;
        _inputManager.toolBar.inputView.selectedFontSize = fontSize;
        _inputManager.toolBar.inputView.selectedTextColor = textColor;
    }
    return self;
}

- (void)setEditable:(BOOL)editable {
    [super setEditable:editable];
    
    if (editable == NO) {
        self.inputAccessoryView = nil;
    } else {
        self.inputAccessoryView = self.inputManager.toolBar;
    }
}

- (void)resetTypingAttributes {
    if (self.selectedRange.length) return;
    self.typingAttributes = [self currentAttributes];
}

- (NSMutableDictionary *)currentAttributes {
    NSMutableDictionary *dict = self.typingAttributes.mutableCopy;
    
    switch (action) {
        case SIXEditorActionBold: {
            UIFont *font = dict[NSFontAttributeName];
            CGFloat fontSize = [font.fontDescriptor.fontAttributes[UIFontDescriptorSizeAttribute] floatValue];
            if (isBold) {
                dict[NSFontAttributeName] = [UIFont boldSystemFontOfSize:fontSize];
            } else {
                dict[NSFontAttributeName] = [UIFont systemFontOfSize:fontSize];
            }
        }
            break;
        case SIXEditorActionItatic: {
            if (isItalic) {
                dict[NSObliquenessAttributeName] = @(Editor_Italic_Rate);
            } else {
                [dict removeObjectForKey:NSObliquenessAttributeName];
            }
        }
            break;
        case SIXEditorActionUnderline: {
            if (isUnderline) {
                UIColor *color = dict[NSForegroundColorAttributeName];
                dict[NSUnderlineColorAttributeName] = color;
                dict[NSUnderlineStyleAttributeName] = @1;
            } else {
                [dict removeObjectForKey:NSUnderlineColorAttributeName];
                [dict removeObjectForKey:NSUnderlineStyleAttributeName];
            }
        }
            break;
        case SIXEditorActionFontSize: {
            UIFont *font = dict[NSFontAttributeName];
            if ((font.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold) > 0) {
                dict[NSFontAttributeName] = [UIFont boldSystemFontOfSize:fontSize];
            } else {
                dict[NSFontAttributeName] = [UIFont systemFontOfSize:fontSize];
            }
        }
            break;
        case SIXEditorActionTextColor: {
            dict[NSForegroundColorAttributeName] = textColor;
        }
            break;
        case SIXEditorActionImage:
            break;
        default:
            break;
    }
    
    return dict.copy;
}


#pragma - mark ------- actions -------

- (void)handleAction:(SIXEditorAction)newAction andValue:(id)value {
    action = newAction;
    if (self.clickItem) {
        self.clickItem(action, value);
    }
    SEL rangeSelector = nil;
    switch (action) {
        case SIXEditorActionBold:
            isBold = [value boolValue];
            rangeSelector = @selector(setBoldInRange);
            break;
        case SIXEditorActionItatic:
            isItalic = [value boolValue];
            rangeSelector = @selector(setItalicInRange);
            break;
        case SIXEditorActionUnderline:
            isUnderline = [value boolValue];
            rangeSelector = @selector(setUnderlineInRange);
            break;
        case SIXEditorActionFontSize:
            fontSize = [value floatValue];
            rangeSelector = @selector(setFontSizeInRange);
            break;
        case SIXEditorActionTextColor:
            textColor = (UIColor *)value;
            rangeSelector = @selector(setTextColorInRange);
            break;
        case SIXEditorActionImage:
            [self setImage:(UIImage *)value];
            return;
        case SIXEditorActionKeyboard:
            [self resignFirstResponder];
            return;
            
        case SIXEditorActionExpression: {
            NSNumber *number = value;
            [self resignFirstResponder];
            if (number.integerValue == 1) {
                self.inputView = self.stickerKeyboard;
            } else {
                self.inputView = nil;
            }
            [self becomeFirstResponder];
        }
            break;
        default:
            break;
    }
   
    
    if (self.selectedRange.length) {
        NSRange range = self.selectedRange;
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:rangeSelector];
        #pragma clang diagnostic pop
        
        self.selectedRange = range;
        [self scrollRangeToVisible:range];
    } else {
        [self resetTypingAttributes];
    }
}
- (NSString *)plainText {
    return [self.attributedText pp_plainTextForRange:NSMakeRange(0, self.attributedText.length)];
}

- (void)showEmojiView {
    //[_inputManager.toolBar setButtonSelected:SIXEditorActionExpression];
     self.inputView = self.stickerKeyboard;
    [self becomeFirstResponder];
  
    
}
- (void)setImage:(UIImage *)image {
    if (image == nil) {
        [self becomeFirstResponder];
        return;
    }
    
    CGFloat width = self.frame.size.width-self.textContainer.lineFragmentPadding*2;
    
    NSMutableAttributedString *mAttributedString = self.attributedText.mutableCopy;
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.bounds = CGRectMake(0, 0, width, width * image.size.height / image.size.width);
    attachment.image = image;
    NSMutableAttributedString *attachmentString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    [attachmentString addAttributes:[self currentAttributes] range:NSMakeRange(0, attachmentString.length)];
    
    [mAttributedString insertAttributedString:attachmentString atIndex:NSMaxRange(self.selectedRange)];
    
    //更新attributedText
    NSInteger location = NSMaxRange(self.selectedRange) + 1;
    self.attributedText = mAttributedString.copy;
    
    //回复焦点
    self.selectedRange = NSMakeRange(location, 0);
    [self becomeFirstResponder];
    //self.placeholderLabel.hidden = YES;
}

- (void)setBoldInRange {
    NSMutableAttributedString *attributedString = self.attributedText.mutableCopy;
    
    [attributedString enumerateAttribute:NSFontAttributeName inRange:self.selectedRange options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(id  _Nullable value, NSRange range0, BOOL * _Nonnull stop) {
        
        if ([value isKindOfClass:[UIFont class]]) {
            UIFont *font = value;
            //字号
            CGFloat fontSize = [font.fontDescriptor.fontAttributes[UIFontDescriptorSizeAttribute] floatValue];
            UIFont *newFont = self->isBold ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
            [attributedString addAttribute:NSFontAttributeName value:newFont range:range0];
        }
    }];
    
    self.attributedText = attributedString.copy;
}

- (void)setItalicInRange {
    NSMutableAttributedString *attributedString = self.attributedText.mutableCopy;
    
    if (isItalic) {
        [attributedString addAttribute:NSObliquenessAttributeName value:@(Editor_Italic_Rate) range:self.selectedRange];
    } else {
        [attributedString removeAttribute:NSObliquenessAttributeName range:self.selectedRange];
    }
    
    self.attributedText = attributedString.copy;
}

- (void)setUnderlineInRange {
    NSMutableAttributedString *attributedString = self.attributedText.mutableCopy;
    
    if (isUnderline == NO) {
        [attributedString removeAttribute:NSUnderlineStyleAttributeName range:self.selectedRange];
        [attributedString removeAttribute:NSUnderlineColorAttributeName range:self.selectedRange];
        self.attributedText = attributedString.copy;
        return;
    }
    
    [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:self.selectedRange options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(id  _Nullable value, NSRange range0, BOOL * _Nonnull stop) {
        
        if ([value isKindOfClass:[UIColor class]]) {
            UIColor *color = value;
            [attributedString addAttribute:NSUnderlineColorAttributeName value:color range:range0];
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:@1 range:range0];
        }
    }];
    self.attributedText = attributedString.copy;
}

- (void)setFontSizeInRange {
    NSMutableAttributedString *attributedString = self.attributedText.mutableCopy;
    
    [attributedString enumerateAttribute:NSFontAttributeName inRange:self.selectedRange options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(id  _Nullable value, NSRange range0, BOOL * _Nonnull stop) {
        
        if ([value isKindOfClass:[UIFont class]]) {
            UIFont *font = value;
            UIFont *newFont = nil;
            //粗体
            if ((font.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold) > 0) {
                newFont = [UIFont boldSystemFontOfSize:self->fontSize];
            } else {
                newFont = [UIFont systemFontOfSize:self->fontSize];
            }
            [attributedString addAttribute:NSFontAttributeName value:newFont range:range0];
        }
    }];
    
    self.attributedText = attributedString.copy;
}

- (void)setTextColorInRange {
    NSMutableAttributedString *attributedString = self.attributedText.mutableCopy;
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:self.selectedRange];
    self.attributedText = attributedString.copy;
}
#pragma mark - PPStickerKeyboardDelegate

- (void)stickerKeyboard:(PPStickerKeyboard *)stickerKeyboard didClickEmoji:(PPEmoji *)emoji {
    if (!emoji) {
        return;
    }
    
    UIImage *emojiImage = [UIImage imageNamed:[@"Sticker.bundle" stringByAppendingPathComponent:emoji.imageName]];
    if (!emojiImage) {
        return;
    }
  
    self.currentLength = self.plainText.length;
    NSRange selectedRange = self.selectedRange;
    NSString *emojiString = [NSString stringWithFormat:@"[%@]", emoji.emojiDescription];
    NSMutableAttributedString *emojiAttributedString = [[NSMutableAttributedString alloc] initWithString:emojiString];
    
    if (self.plainText.length+emojiString.length>self.limitLength) {
    
        return;
    }
    [emojiAttributedString pp_setTextBackedString:[PPTextBackedString stringWithString:emojiString] range:emojiAttributedString.pp_rangeOfAll];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedText replaceCharactersInRange:selectedRange withAttributedString:emojiAttributedString];
    self.attributedText = attributedText;
    self.font = [UIFont systemFontOfSize:fontSize];
    self.selectedRange = NSMakeRange(selectedRange.location + emojiAttributedString.length, 0);
    [self refreshTextUI];
    
}

- (void)stickerKeyboardDidClickDeleteButton:(PPStickerKeyboard *)stickerKeyboard
{
    NSRange selectedRange = self.selectedRange;
    if (selectedRange.location == 0 && selectedRange.length == 0) {
        return;
    }
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    if (selectedRange.length > 0) {
        [attributedText deleteCharactersInRange:selectedRange];
        self.attributedText = attributedText;
        self.selectedRange = NSMakeRange(selectedRange.location, 0);
    } else {
        NSUInteger deleteCharactersCount = 1;
        
        // 下面这段正则匹配是用来匹配文本中的所有系统自带的 emoji 表情，以确认删除按钮将要删除的是否是 emoji。这个正则匹配可以匹配绝大部分的 emoji，得到该 emoji 的正确的 length 值；不过会将某些 combined emoji（如 👨‍👩‍👧‍👦 👨‍👩‍👧‍👦 👨‍👨‍👧‍👧），这种几个 emoji 拼在一起的 combined emoji 则会被匹配成几个个体，删除时会把 combine emoji 拆成个体。瑕不掩瑜，大部分情况下表现正确，至少也不会出现删除 emoji 时崩溃的问题了。
        NSString *emojiPattern1 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900-\\U0001F9FF]";
        NSString *emojiPattern2 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900–\\U0001F9FF]\\uFE0F";
        NSString *emojiPattern3 = @"[\\u2600-\\u27BF\\U0001F300-\\U0001F77F\\U0001F900–\\U0001F9FF][\\U0001F3FB-\\U0001F3FF]";
        NSString *emojiPattern4 = @"[\\rU0001F1E6-\\U0001F1FF][\\U0001F1E6-\\U0001F1FF]";
        NSString *pattern = [[NSString alloc] initWithFormat:@"%@|%@|%@|%@", emojiPattern4, emojiPattern3, emojiPattern2, emojiPattern1];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:kNilOptions error:NULL];
        NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:attributedText.string options:kNilOptions range:NSMakeRange(0, attributedText.string.length)];
        for (NSTextCheckingResult *match in matches) {
            if (match.range.location + match.range.length == selectedRange.location) {
                deleteCharactersCount = match.range.length;
                break;
            }
        }
        
        [attributedText deleteCharactersInRange:NSMakeRange(selectedRange.location - deleteCharactersCount, deleteCharactersCount)];
        self.attributedText = attributedText;
        self.selectedRange = NSMakeRange(selectedRange.location - deleteCharactersCount, 0);
    }
     self.currentLength = self.plainText.length;
}
- (void)stickerKeyboardDidClickSendButton:(PPStickerKeyboard *)stickerKeyboard
{
    
}

#pragma mark -UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self updateTextViewContent];
}

//消除系统自带表情和第三方键盘表情。防止服务端解析失败
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([textView isFirstResponder]) {
        
        if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textView textInputMode] primaryLanguage]) {
            return NO;
        }
        
        //判断键盘是不是九宫格键盘
        if ([self isNineKeyBoard:text] ){
            return YES;
        }else{
            if ([self hasEmoji:text] || [self stringContainsEmoji:text]){
                return NO;
            }
        }
    }
    return YES;
}


/**
 *  判断字符串中是否存在emoji
 * @param string 字符串
 * @return YES(含有表情) 剔除系统自带表情
 */
- (BOOL)stringContainsEmoji:(NSString *)string {
    
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}


/**
 *  判断字符串中是否存在emoji 剔除第三方表情
 * @param string 字符串
 * @return YES(含有表情)
 */
- (BOOL)hasEmoji:(NSString*)string;
{
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

/**
 判断是不是九宫格
 @param string  输入的字符
 @return YES(是九宫格拼音键盘)
 */
-(BOOL)isNineKeyBoard:(NSString *)string {
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)string.length;
    for(int i=0;i<len;i++)
    {
        if(!([other rangeOfString:string].location != NSNotFound))
            return NO;
    }
    return YES;
}
#pragma mark - private method

- (void)updateTextViewContent {
    //换行符不加入字符统计
    
    NSUInteger wordCurrentWord = self.plainText.length;
   // self.placeholderLabel.hidden = (wordCurrentWord > 0);
    
    NSString *keyboardType = self.textInputMode.primaryLanguage;
    //中文处理 高亮状态下允许输入框里输入超过限制字数的拼音
    if ([keyboardType containsString:@"zh"]) {
        //高亮状态
        UITextRange *range = self.markedTextRange;
        //不是高亮状态
        if (range == nil) {
            if (wordCurrentWord > self.limitLength) {
                NSMutableString * textStr = [[NSMutableString alloc] initWithString:self.plainText];
                [textStr deleteCharactersInRange:NSMakeRange(self.limitLength, wordCurrentWord-self.limitLength)];
                [self refrestTextUI:textStr];
            }
        }
    } else {
        if (wordCurrentWord > self.limitLength) {
            NSMutableString * textStr = [[NSMutableString alloc] initWithString:self.plainText];
            [textStr deleteCharactersInRange:NSMakeRange(self.limitLength, wordCurrentWord-self.limitLength)];
            [self refrestTextUI:textStr];
        }
    }
    if (wordCurrentWord > self.limitLength ) {
        wordCurrentWord = self.limitLength ;
    }
    self.currentLength = wordCurrentWord;
    //self.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%ld",wordCurrentWord,self.limitLength];
}


- (void)refreshTextUI
{
    if (!self.plainText.length) {
        return;
    }
    
    UITextRange *markedTextRange = [self markedTextRange];
    UITextPosition *position = [self positionFromPosition:markedTextRange.start offset:0];
    if (position) {
        return;     // 正处于输入拼音还未点确定的中间状态
    }
    
    NSRange selectedRange = self.selectedRange;
    NSMutableAttributedString *attributedComment = [[NSMutableAttributedString alloc] initWithString:self.plainText attributes:@{ NSFontAttributeName: self.font, NSForegroundColorAttributeName: [UIColor pp_colorWithRGBString:@"#3B3B3B"] }];
    
    // 匹配表情
    [PPStickerDataManager.sharedInstance replaceEmojiForAttributedString:attributedComment font:self.font];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 1.f;
    [attributedComment addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:attributedComment.pp_rangeOfAll];
    
    NSUInteger offset = self.attributedText.length - attributedComment.length;
    self.attributedText = attributedComment;
    self.selectedRange = NSMakeRange(selectedRange.location - offset, 0);
    self.currentLength = self.plainText.length;
    
}


- (void)refrestTextUI:(NSString *)plainText {
    UITextRange *markedTextRange = [self markedTextRange];
    UITextPosition *position = [self positionFromPosition:markedTextRange.start offset:0];
    if (position) {
        return;     // 正处于输入拼音还未点确定的中间状态
    }
    
    NSRange selectedRange = self.selectedRange;
    NSMutableAttributedString *attributedComment = [[NSMutableAttributedString alloc] initWithString:plainText attributes:@{ NSFontAttributeName: self.font, NSForegroundColorAttributeName: [UIColor pp_colorWithRGBString:@"#3B3B3B"] }];
    
    // 匹配表情
    [PPStickerDataManager.sharedInstance replaceEmojiForAttributedString:attributedComment font:self.font];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 1.f;
    [attributedComment addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:attributedComment.pp_rangeOfAll];
    
    NSUInteger offset = self.attributedText.length - attributedComment.length;
    self.attributedText = attributedComment;
    self.selectedRange = NSMakeRange(selectedRange.location - offset, 0);
    self.currentLength = self.plainText.length;
}

#pragma - mark ------ update toolbar item color -------

- (void)changeColorOfToolBarItem  {
    if ([self isFirstResponder] == NO) return;
    
    NSDictionary *attrs = self.typingAttributes;
    
    //斜体
    isItalic = [attrs.allKeys containsObject:NSObliquenessAttributeName];
    [self.inputManager.toolBar refreshUIOfItemButton:SIXEditorActionItatic andValue:@(italic)];
    //下划线
    isUnderline = [attrs.allKeys containsObject:NSUnderlineColorAttributeName];
    [self.inputManager.toolBar refreshUIOfItemButton:SIXEditorActionUnderline andValue:@(isUnderline)];
    //粗体
    UIFont *font = attrs[NSFontAttributeName];
    isBold = (font.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold) > 0;
    [self.inputManager.toolBar refreshUIOfItemButton:SIXEditorActionBold andValue:@(isBold)];
    //字色
    UIColor *color = attrs[NSForegroundColorAttributeName];
    [self.inputManager.toolBar refreshUIOfItemButton:SIXEditorActionTextColor andValue:color];
    //字体大小
    CGFloat fontSize = [font.fontDescriptor.fontAttributes[UIFontDescriptorSizeAttribute] floatValue];
    [self.inputManager.toolBar refreshUIOfItemButton:SIXEditorActionFontSize andValue:@(fontSize)];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    static UIEvent *e = nil;
    
    if (e != nil && e == event) {
        e = nil;
        return [super hitTest:point withEvent:event];
    }
    
    e = event;
    
    if (event.type == UIEventTypeTouches) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self changeColorOfToolBarItem];
        });
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - override

- (void)cut:(id)sender
{
    NSString *string = [self.attributedText pp_plainTextForRange:self.selectedRange];
    if (string.length) {
        [UIPasteboard generalPasteboard].string = string;
        
        NSRange selectedRange = self.selectedRange;
        NSMutableAttributedString *attributeContent = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        [attributeContent replaceCharactersInRange:self.selectedRange withString:@""];
        self.attributedText = attributeContent;
        self.selectedRange = NSMakeRange(selectedRange.location, 0);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
            [self.delegate textViewDidChange:self];
        }
    }
}

- (void)copy:(id)sender
{
    NSString *string = [self.attributedText pp_plainTextForRange:self.selectedRange];
    if (string.length) {
        [UIPasteboard generalPasteboard].string = string;
    }
}

- (void)paste:(id)sender
{
    NSString *string = UIPasteboard.generalPasteboard.string;
    if (string.length) {
        NSMutableAttributedString *attributedPasteString = [[NSMutableAttributedString alloc] initWithString:string];
        [PPStickerDataManager.sharedInstance replaceEmojiForAttributedString:attributedPasteString font:self.font];
        NSRange selectedRange = self.selectedRange;
        
        NSMutableAttributedString *attributeContent = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        [attributeContent replaceCharactersInRange:self.selectedRange withAttributedString:attributedPasteString];
        self.attributedText = attributeContent;
        self.selectedRange = NSMakeRange(selectedRange.location + attributedPasteString.length, 0);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
            [self.delegate textViewDidChange:self];
        }
    }
}

#pragma mark -getter

- (PPStickerKeyboard *)stickerKeyboard
{
    if (!_stickerKeyboard) {
        _stickerKeyboard = [[PPStickerKeyboard alloc] init];
        _stickerKeyboard.delegate = self;
        _stickerKeyboard.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), [self.stickerKeyboard heightThatFits]);
    }
    return _stickerKeyboard;
}

@end
