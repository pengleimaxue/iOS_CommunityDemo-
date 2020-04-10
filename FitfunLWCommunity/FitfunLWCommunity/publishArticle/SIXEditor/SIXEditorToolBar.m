//
//  SIXEditorToolBar.m
//  SIXRichEditor
//
//  Created by  on 2018/7/29.
//  Copyright © 2018年 liujiliu. All rights reserved.
//

#import "SIXEditorToolBar.h"
#import "SIXEditorInputView.h"

@interface SIXEditorToolBar () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    CGFloat _itemWidth;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSMutableDictionary *itemCache;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *deleteTitleButton;

@end

@implementation SIXEditorToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    self = [super initWithFrame:CGRectMake(0, 0, screenW, Editor_ToolBar_Height)];
    
    if (self) {
        _itemWidth = screenW / 7.0;
        self.backgroundColor = [UIColor clearColor];
        self.itemCache = [NSMutableDictionary dictionary];
        [self setupUI];
        
        self.items = @[//@(SIXEditorActionBold),
                       //@(SIXEditorActionUnderline),
                       //@(SIXEditorActionItatic),
                       //@(SIXEditorActionFontSize),
                       //@(SIXEditorActionTextColor),
                       @(SIXEditorActionImage),
                       @(SIXEditorActionVideo),
                       @(SIXEditorActionExpression),
                        ];
    }
    return self;
}

- (void)setupUI {
    [self.scrollView addSubview:self.stackView];
    [self.backgroundView addSubview:self.scrollView];
    [self addSubview:self.backgroundView];
    
    if (@available(iOS 11.0, *)) {
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    

    
    UIButton *keyboardButton = [self itemButton:SIXEditorActionKeyboard];
    keyboardButton.frame = CGRectMake(CGRectGetMaxX(_scrollView.frame), CGRectGetMinY(_scrollView.frame), _itemWidth, self.frame.size.height/2);
    [self addSubview:keyboardButton];
    
    CALayer *line = [CALayer layer];
    line.backgroundColor = [UIColor lightGrayColor].CGColor;
    line.frame = CGRectMake(0, self.frame.size.height/2, [UIScreen mainScreen].bounds.size.width, 1);
    [self.layer addSublayer:line];
   
    [self addSubview:self.selectButton];
    [self addSubview:self.deleteTitleButton];
}

- (void)setItems:(NSArray *)items {
    _items = items;
    
    for (UIView *view in self.itemCache.allValues) {
        [_stackView removeArrangedSubview:view];
    }
    [self.itemCache removeAllObjects];
    
    for (int i = 0; i < items.count; i++) {
        UIButton *itemButton = [self itemButton:[items[i] integerValue]];
        [self.itemCache setObject:itemButton forKey:items[i]];
        [_stackView addArrangedSubview:itemButton];
    }

    _scrollView.contentSize = CGSizeMake(_itemWidth * _items.count , self.frame.size.height/2);
    _stackView.frame = CGRectMake(0, 0, _scrollView.contentSize.width, _scrollView.contentSize.height);
}

- (UIButton *)itemButton:(SIXEditorAction)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SIXEditor" ofType:@"bundle"]];
    
    NSString *imageName = [self itemImageName:action];
    UIImage *image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    [button setImage:image forState:(UIControlStateNormal)];
    imageName = [imageName stringByAppendingString:@"_select"];
    image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    [button setImage:image forState:(UIControlStateSelected)];
    [button setImage:image forState:UIControlStateHighlighted];
    button.tag = action;
    return button;
}

- (void)clickItem:(UIButton *)button {
    button.selected = !button.isSelected;
    SIXEditorAction action = button.tag;
    
    switch (action) {
        case SIXEditorActionBold:
        case SIXEditorActionItatic:
        case SIXEditorActionUnderline:
            self.clickItem(action, @(button.isSelected));
            break;
        case SIXEditorActionKeyboard:
            button.selected = NO;
            self.clickItem(action, nil);
            break;
        case SIXEditorActionFontSize: {
            UIButton *colorButton = self.itemCache[@(SIXEditorActionTextColor)];
            colorButton.selected = NO;
            self.inputView.editorAction = action;
            [self showCustomKeyboard:button.isSelected];
        }
            break;
        case SIXEditorActionTextColor: {
            UIButton *fontButton = self.itemCache[@(SIXEditorActionFontSize)];
            fontButton.selected = NO;
            self.inputView.editorAction = action;
            [self showCustomKeyboard:button.isSelected];
        }
            break;
        case SIXEditorActionImage:
            button.selected = NO;
            [self showImagePicker];
            break;
            
         case SIXEditorActionVideo:
            [self showVideo];
            break;
        case SIXEditorActionExpression: {
            //button.selected = !button.selected;
            [self showExpress:@(button.isSelected)];
        }
            break;
            
        default:
            break;
    }

}

- (void)showImagePicker {
//    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
//    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    pickerController.allowsEditing = YES;
//    pickerController.delegate = self;
//
//    UIViewController *rootController = [UIApplication sharedApplication].delegate.window.rootViewController;
//    [rootController presentViewController:pickerController animated:YES completion:nil];
    self.clickItem(SIXEditorActionImage, nil);
}


- (void)showVideo{
    self.clickItem(SIXEditorActionVideo, nil);
}

- (void)showExpress:(NSNumber *)isSelected {
    self.clickItem(SIXEditorActionExpression,isSelected);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = nil;
    if ([picker allowsEditing]){ //获取用户编辑之后的图像
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    } else { // 照片的元数据参数
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        self.clickItem(SIXEditorActionImage, image);
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        self.clickItem(SIXEditorActionImage, nil);
    }];
}

- (void)showCustomKeyboard:(BOOL)value {
    if (value) {
        if (self.inputView.superview) return;
        
        [self setEditorInputViewFrameWithShowOrHide:NO];
        [[UIApplication sharedApplication].windows.lastObject addSubview:self.inputView];
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setEditorInputViewFrameWithShowOrHide:YES];
        } completion:nil];
    } else {
        if (!self.inputView.superview) return;
        
        self.inputView.editorAction = SIXEditorActionNone;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self setEditorInputViewFrameWithShowOrHide:YES];
        } completion:^(BOOL finished) {
            [self.inputView removeFromSuperview];
        }];
    }
}

- (void)setEditorInputViewFrameWithShowOrHide:(BOOL)isShow {
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    CGRect rect = [self convertRect:self.frame toView:window];
    
    CGFloat height = size.height - CGRectGetMaxY(rect);
    if (isShow) {
        self.inputView.frame = CGRectMake(0, CGRectGetMaxY(rect), size.width, height);
    } else {
        self.inputView.frame = CGRectMake(0, size.height, size.width, height);
    }
}

- (SIXEditorInputView *)inputView {
    if (!_inputView) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _inputView = [[SIXEditorInputView alloc] initWithFrame:CGRectMake(0, size.height, size.width, 0)];
        _inputView.delegate = self;
    }
    return _inputView;
}

- (void)inputView:(SIXEditorInputView *)inputView clickItemForFontSize:(CGFloat)size {
    self.clickItem(SIXEditorActionFontSize, @(size));
    [self refreshUIOfItemButton:SIXEditorActionFontSize andValue:@(NO)];
    [self showCustomKeyboard:NO];
}

- (void)inputView:(SIXEditorInputView *)inputView clickItemForTextColor:(UIColor *)color {
    self.clickItem(SIXEditorActionTextColor, color);
    [self refreshUIOfItemButton:SIXEditorActionTextColor andValue:@(NO)];
    [self showCustomKeyboard:NO];
}

- (void)refreshUIOfItemButton:(SIXEditorAction)action andValue:(id)value {
    UIButton *itemButton = [self.itemCache objectForKey:@(action)];
    if ([value isKindOfClass:[NSNumber class]] && [value integerValue] < 2) {
        itemButton.selected = [value boolValue];
        return;
    }
    
    if (action == SIXEditorActionFontSize) {
        self.inputView.selectedFontSize = [value integerValue];
        [self.inputView reloadData];
    } else if (action == SIXEditorActionTextColor) {
        self.inputView.selectedTextColor = value;
        [self.inputView reloadData];
    }
}

- (void)setDefaultItemColors {
    [self refreshUIOfItemButton:SIXEditorActionFontSize andValue:@(NO)];
    [self refreshUIOfItemButton:SIXEditorActionTextColor andValue:@(NO)];
}

- (NSString *)itemImageName:(SIXEditorAction)action {
    switch (action) {
        case SIXEditorActionBold:
            return @"Editor_bold";
        case SIXEditorActionItatic:
            return @"Editor_itatic";
        case SIXEditorActionUnderline:
            return @"Editor_underline";
        case SIXEditorActionFontSize:
            return @"Editor_fontSize";
        case SIXEditorActionTextColor:
            return @"Editor_textColor";
        case SIXEditorActionImage:
            return @"Editor_image";
        case SIXEditorActionVideo:
            return @"Editor_video";
        case SIXEditorActionKeyboard:
            return @"Editor_keyboard";
        case SIXEditorActionSelectTitle:
            return @"button_add";
            
        case SIXEditorActionExpression:
            return @"Editor_expression";
        default:
            return nil;
    }
}


#pragma mark - setter && getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2, self.frame.size.width-_itemWidth, self.frame.size.height/2)];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        
    }
    return _scrollView;
}

- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc] init];
        _stackView.distribution = UIStackViewDistributionFillEqually;
    }
    return _stackView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.backgroundColor = [UIColor clearColor];
    }
    return _backgroundView;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [self itemButton: SIXEditorActionSelectTitle];
        _selectButton.frame = CGRectMake(10, 0, _itemWidth*1.8, self.frame.size.height/3);
        [_selectButton setTitle:@"选择主题" forState:UIControlStateNormal];
        UIColor *lightbuleColor = [UIColor colorWithRed:176.0/255 green:224.0/255 blue:230.0/255 alpha:0.8];
        UIColor *skyblueColor = [UIColor colorWithRed:30.0/255 green:144.0/255 blue:255.0/255 alpha:1.0];
        [_selectButton setTitleColor:skyblueColor forState:UIControlStateNormal];
        _selectButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _selectButton.backgroundColor = lightbuleColor;
        _selectButton.layer.masksToBounds = YES;
        _selectButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _selectButton.layer.borderWidth = 1;
        _selectButton.layer.cornerRadius = 2;
    }
    return _selectButton;
}

- (UIButton *)deleteTitleButton {
    if (!_deleteTitleButton) {
        _deleteTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteTitleButton.frame = CGRectMake(CGRectGetMaxX(_selectButton.frame)+5, CGRectGetMinY(_selectButton.frame)+self.frame.size.height/12, self.frame.size.height/6, self.frame.size.height/6);
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SIXEditor" ofType:@"bundle"]];
         UIImage *image = [UIImage imageNamed:@"delete" inBundle:bundle compatibleWithTraitCollection:nil];
        [_deleteTitleButton setImage:image forState:UIControlStateNormal];
    }
    return _deleteTitleButton;
}
@end
