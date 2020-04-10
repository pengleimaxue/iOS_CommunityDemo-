////
//  PLShowSelectView.m
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/12.
//Copyright © 2019年 penglei. All rights reserved.
//

#import "PLShowSelectView.h"
#import "FitFunSystemTool.h"


@interface PLshowViewSelectCell : UITableViewCell


- (void)setTitleLabelText:(NSString *)text;
- (void)setShowViewSelectCellSelected:(BOOL)isSelected;

@end

@interface PLshowViewSelectCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *selectImage;

@end

@implementation PLshowViewSelectCell

#pragma mark - init
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)setTitleLabelText:(NSString *)text {
    self.titleLabel.text = text;
}

- (void)setShowViewSelectCellSelected:(BOOL)isSelected {
    if (isSelected) {
        [self.contentView addSubview:self.selectImage];
        _titleLabel.textColor = [UIColor blueColor];
    } else {
        if (_selectImage) {
            [_selectImage removeFromSuperview];
            _selectImage = nil;
        }
        _titleLabel.textColor = [UIColor blackColor];
    }
    
}

#pragma mark - getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, self.contentView.frame.size.height)];
        _titleLabel.textColor = [UIColor blackColor];
        CGPoint center = _titleLabel.center;
        center.x = FFSCREEN_WIDTH/2;
        _titleLabel.center = center;
    }
    return _titleLabel;
}

- (UIImageView *)selectImage {
    if (!_selectImage) {
        _selectImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick.png"]];
        _selectImage.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame)+1, 0, 16, 16);
        CGPoint center = _selectImage.center;
        center.y = self.contentView.center.y;
        _selectImage.center = center;
        _selectImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _selectImage;
}


@end

static NSString  *  const plShowSelectCellReuseIdentifier = @"PLShowSelectCellReuseIdentifier";

@interface PLShowSelectView () <UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

//遮罩视图
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) NSUInteger selectCellIndexRow;

@property (nonatomic, copy) void(^selectCellBlock)(NSUInteger selectIndexRow);
@property (nonatomic, copy) dispatch_block_t disAppearBlock;
@property (nonatomic, assign) BOOL isShow;

@end



@implementation PLShowSelectView

+ (instancetype) shareInstance {
    static id  shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc]init];
    });
    return shareInstance;
}

+ (void)showSelectView:(NSArray *)dataSouce
       selectedNewCell:(void (^)(NSUInteger))selectCellBlock
             disAppear:(dispatch_block_t)disAppearBlock {
    [[self shareInstance] showSelectView:dataSouce
                         selectedNewCell:selectCellBlock
                               disAppear:disAppearBlock];
}

- (void) showSelectView:(NSArray *)dataSouce
        selectedNewCell:(void (^)(NSUInteger))selectCellBlock
              disAppear:(dispatch_block_t)disAppearBlock {
    if (self.isShow) {
        return;
    }
    self.dataSource = dataSouce;
    self.selectCellBlock = selectCellBlock;
    self.disAppearBlock = disAppearBlock;
    self.isShow = YES;
    [self showSelectView];
}

#pragma mark - private methond

- (void)showSelectView {
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    if (keyWindow == nil) {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    [keyWindow addSubview: self.maskView];

    [self showTableView];
}

- (void)showTableView {
    [self.maskView addSubview:self.tableView];
    [UIView animateWithDuration:0.3f  animations:^{
        CGRect frame = self.tableView.frame;
        frame.size.height = 100;
        self.tableView.frame = frame;
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
    }];
}


- (void)disApperView {
    [UIView animateWithDuration:0.3f  animations:^{
        CGRect frame = self.tableView.frame;
        frame.size.height =0;
        self.tableView.frame = frame;
    } completion:^(BOOL finished) {
        [self.tableView removeFromSuperview];
        [self.maskView removeFromSuperview];
        self.tableView = nil;
        self.maskView = nil;
        self.isShow = NO;
    }];
}

- (void)maskViewTaped:(UIGestureRecognizer *)recognizer{
    [self disApperView];
    if (self.disAppearBlock) {
        self.disAppearBlock();
    }
}

//一个页面既有点击手势又有tableview,那么这个时候tableview的点击就会被点击手势取代
//解决手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
    return NO;
    }
    return YES;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLshowViewSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:plShowSelectCellReuseIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setTitleLabelText:self.dataSource[indexPath.row]];
    [cell setShowViewSelectCellSelected:indexPath.row == self.selectCellIndexRow ];
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectCellIndexRow !=indexPath.row) {
        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        NSIndexPath *selectCellPath = [NSIndexPath indexPathForRow:self.selectCellIndexRow inSection:0];
        //局部刷新
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:currentIndexPath,selectCellPath ,nil]
                              withRowAnimation:UITableViewRowAnimationNone];
        self.selectCellIndexRow = indexPath.row;
        if (self.selectCellBlock) {
            self.selectCellBlock(indexPath.row);
            [self disApperView];
        }
    }
}

#pragma mark - getter && setter

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, FFSafeAreaTopHeight,FFSCREEN_WIDTH , FFSCREEN_HEIGHT-FFSafeAreaTopHeight)];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTaped:)];
        gesture.delegate = self;
        [_maskView addGestureRecognizer:gesture];
    }
    return _maskView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, FFSCREEN_WIDTH, 0) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //分割线隐藏
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[PLshowViewSelectCell class] forCellReuseIdentifier:plShowSelectCellReuseIdentifier];
    }
    return _tableView;
}

@end
