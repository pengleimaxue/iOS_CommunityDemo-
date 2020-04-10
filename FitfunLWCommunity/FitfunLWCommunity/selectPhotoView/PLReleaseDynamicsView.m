////
//  PLReleaseDynamics.m
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/14.
//Copyright © 2019年 penglei. All rights reserved.
//

#import "PLReleaseDynamicsView.h"
#import "PLTextView.h"
#import "PLSelectPhotoShowView.h"
#import "UIView+PM.h"
#import "SIXEditorView.h"
@interface PLReleaseDynamicsView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) SIXEditorView *textView;
@property (nonatomic, strong) PLSelectPhotoShowView *selectPhotoView;
@property (nonatomic, strong) UITableView *contentTableView;

@end

@implementation PLReleaseDynamicsView



#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

#pragma mark - private methond

- (void)setupView {
    self.style = PLReleaseDynamicsJurisdictionPublic;
    [self addSubview:self.contentTableView];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGRectGetMaxY(self.selectPhotoView.frame);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLReleaseDynamicsCell"];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:@"PLReleaseDynamicsCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"公开";
        cell.detailTextLabel.text = @"所有玩家可见";
        
    } else {
        cell.textLabel.text = @"仅好友可见";
        cell.detailTextLabel.text = @"游戏好友,社区好友可见";
    }
    
    if (self.style == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewRowAnimationNone;
    }
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.style != indexPath.row) {
        self.style = indexPath.row;
        [self.contentTableView reloadData];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, self.width, CGRectGetMaxY(self.selectPhotoView.frame));
    [view addSubview:self.textView];
    [view addSubview:self.selectPhotoView];
    return view;
}


#pragma mark - getter && setter


- (SIXEditorView *)textView {
    if (!_textView) {
        _textView = [[SIXEditorView alloc] initWithFrame:CGRectMake(10, 10, self.width-20, 200)];
        _textView.limitLength =  200;
        _textView.placeholderText = @"写下这一刻想法";
        _textView.clickItem = ^(SIXEditorAction action, id value) {
            if (action == SIXEditorActionVideo) {
                [_selectPhotoView selectVideo];
            } else if (action == SIXEditorActionImage) {
                [_selectPhotoView selectPhotos];
            }
        };
    }
    return _textView;
}

- (PLSelectPhotoShowView *)selectPhotoView {
    if (!_selectPhotoView) {
        _selectPhotoView = [[PLSelectPhotoShowView alloc] initWithFrame:CGRectMake(10,CGRectGetMaxY(self.textView.frame), self.width -20, 200)];
        _selectPhotoView.maxSelectPhotosNumber = 9;
    }
    return _selectPhotoView;
}

- (UITableView *)contentTableView {
    if (!_contentTableView) {
        _contentTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _contentTableView.delegate = self;
        _contentTableView.dataSource = self;
       // [_contentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PLReleaseDynamicsCell"];
        _contentTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _contentTableView;
}


@end
