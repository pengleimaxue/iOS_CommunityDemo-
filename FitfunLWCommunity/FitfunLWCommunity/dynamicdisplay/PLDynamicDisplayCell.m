////
//  PLDynamicDisplayCell.m
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/15.
//Copyright © 2019年 penglei. All rights reserved.
//

#import "PLDynamicDisplayCell.h"
#import "PLTapImageView.h"
#import "PLCustomCollectionView.h"
#import "FitFunSystemTool.h"
#import "UIImage+Common.h"
#import "UILabel+Common.h"
#import "NSString+Common.h"
#import "UIView+PM.h"

static CGFloat const pDisplayCell_Padding = 15.f;
static CGFloat const pDisplayCell_BtnWidth = 80.f;
static CGFloat const pDisplayCell_BtnHeight = 30.f;
static CGFloat const pDisplayCell_CollectionMargin = 4.f;
static CGFloat const pDisplayCell_ViewSpace = 5.f;
static CGFloat const pDisplayCell_ColletionArticleHeight = 80.f;
static CGFloat const pDissplayCell_UserIcon = 50.f;

#define pDisplayCell_BtnPadding (FFSCREEN_WIDTH - (pDisplayCell_Padding*2+pDisplayCell_BtnWidth*4))/3.f
#define pDisplayCell_CollectionWidth (FFSCREEN_WIDTH-pDisplayCell_Padding*2 - pDisplayCell_CollectionMargin*4)/3
#define pDisplayCell_ColletionArticleWidth (FFSCREEN_WIDTH-pDisplayCell_Padding*2-pDisplayCell_CollectionMargin*2)

@interface PLDynamicDisplayCell () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) PLDynamicModel *model;
//点赞用户数组
@property (nonatomic, strong) NSArray *likeUsersArray;
//是否置顶
@property (nonatomic, assign) BOOL needTopView;
//是否已经关注
@property (nonatomic, assign) BOOL isFollow;
//用户头像
@property (nonatomic, strong) PLTapImageView *ownerImageView;
//用户名字
@property (nonatomic, strong) UIButton *ownerNameBtn;
//发布时间
@property (nonatomic, strong) UILabel *timeLabel;
//关注用户按钮
@property (nonatomic, strong) UIButton *followButton;
//用户发布的文字内容
@property (nonatomic, strong) UILabel *contentLabel;
//用户图片展示数组
@property (nonatomic, strong) PLCustomCollectionView *mediaView;
//点赞 ，消息，删除，分享，阅读
@property (nonatomic, strong) UIButton *likeBtn, *commentBtn, *deleteBtn, *shareBtn, *readBtn;
//点赞用户展示视图
@property (nonatomic, strong) UICollectionView *likeUsersView;
//列表展示
@property (strong, nonatomic) UITableView *commentListView;

@property (strong, nonatomic) UIImageView *timeClockIconView, *commentOrLikeBeginImgView, *commentOrLikeSplitlineView;

@end


@implementation PLDynamicDisplayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupView];
    }
    return self;
}

#pragma mark - public methond


- (void)setDynamicDisplayCell:(PLDynamicModel *)model {
    if (!model) {
        return;
    }
    _model = model;
    self.ownerImageView.image = model.ownerImg;
    [self.ownerNameBtn setTitle:model.ownerName forState:UIControlStateNormal];
    self.timeLabel.text = model.pubulishTime;
    
    [self.contentLabel setLongString:model.content withFitWidth:FFSCREEN_WIDTH-pDisplayCell_Padding*2 maxHeight:200.f];
   CGFloat curBottomY = CGRectGetMaxY(self.contentLabel.frame);
    if (self.model.isArticle) {
        if (self.model.imageArray.count) {
            CGFloat mediaHeight = pDisplayCell_ColletionArticleHeight + pDisplayCell_CollectionMargin*2;
            [self.mediaView setHeight:mediaHeight];
            [self.mediaView setY:curBottomY];
            curBottomY = CGRectGetMaxY(self.mediaView.frame);
        }
    } else {
        if (self.model.imageArray.count) {
            NSInteger count = self.model.imageArray.count/3;
            if (self.model.imageArray.count%3>0) {
                count = count +1;
            }
            [self.mediaView setHeight:(pDisplayCell_CollectionWidth*count+(count+1)*pDisplayCell_CollectionMargin)];
            [self.mediaView setY:curBottomY];
               curBottomY = CGRectGetMaxY(self.mediaView.frame);
             [self.mediaView reloadData];
            self.mediaView.hidden = NO;
        } else {
            self.mediaView.hidden = YES;
        }
    }
    [self.readBtn setY:curBottomY+pDisplayCell_ViewSpace];
    [self.shareBtn setY:curBottomY+pDisplayCell_ViewSpace];
    [self.commentBtn setY:curBottomY+pDisplayCell_ViewSpace];
    [self.likeBtn setY:curBottomY+pDisplayCell_ViewSpace];

}



+ (CGFloat)getCellContentHeight:(PLDynamicModel *)model {
    CGFloat height = 0;
    height += pDisplayCell_Padding + pDissplayCell_UserIcon + pDisplayCell_ViewSpace + [self getContentHeight:model.content];
    height += [self getMediaViewHeight:model];
    height += pDisplayCell_BtnHeight + pDisplayCell_ViewSpace;
    return height;
}

#pragma mark - private

+ (CGFloat)getContentHeight:(NSString *)content{
    return [content getHeightWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(FFSCREEN_WIDTH-pDisplayCell_Padding*2, 200)];
}

+ (CGFloat)getMediaViewHeight:(PLDynamicModel *)model {
    CGFloat mediaHeight = 0;
    if (model.isArticle) {
        mediaHeight = pDisplayCell_ColletionArticleHeight + pDisplayCell_CollectionMargin*2;
       
    } else {
        if (model.imageArray.count) {
            NSInteger count = model.imageArray.count/3;
            if (model.imageArray.count%3>0) {
                count = count +1;
            }
            mediaHeight = pDisplayCell_CollectionWidth*count+(count+1)*pDisplayCell_CollectionMargin;
        }
    }
    
    return mediaHeight;
}
#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate

- (NSInteger )collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.model.isArticle) {
        return 1;
    } else {
        return self.model.imageArray.count;
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size;
    
    if (self.model.isArticle) {
         size = CGSizeMake(pDisplayCell_ColletionArticleWidth, pDisplayCell_ColletionArticleHeight);
    } else {
         size = CGSizeMake(pDisplayCell_CollectionWidth, pDisplayCell_CollectionWidth);
    }
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    if (self.model.isArticle) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PLCustomCollectionViewCellArticle" forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PLCustomCollectionViewCell" forIndexPath:indexPath];
    }
    
    if (self.model.imageArray.count) {
        PLTapImageView *imageView = [[PLTapImageView alloc] initWithImage:self.model.imageArray[indexPath.row]];
        imageView.frame = cell.contentView.frame;
        [cell.contentView addSubview:imageView];
    }

   
    return cell;
}
#pragma mark - private methond

- (void)setupView {
    
    if (!_ownerImageView) {
        [self.contentView addSubview:self.ownerImageView];
    }
    
    if (!_ownerNameBtn) {
        [self.contentView addSubview:self.ownerNameBtn];
    }

    if (!_timeLabel) {
        [self.contentView addSubview:self.timeLabel];
    }
//
//    if (!_followButton) {
//        [self.contentView addSubview:self.followButton];
//    }
//
    if (!_contentLabel) {
        [self.contentView addSubview:self.contentLabel];
    }
//
    if (!_mediaView) {
        [self.contentView addSubview:self.mediaView];
    }

    if (!_readBtn) {
        [self.contentView addSubview:self.readBtn];
    }
    
    if (!_shareBtn) {
        [self.contentView addSubview:self.shareBtn];
    }

    

    if (!_commentBtn) {
        [self.contentView addSubview:self.commentBtn];
    }

    if (!_likeBtn) {
        [self.contentView addSubview:self.likeBtn];
    }
}

//用户头像被点击
- (void)userBtnClicked {
    NSLog(@"用户头像被点击了");
}

- (void)followBtnClicked {
    NSLog(@"关注用户按钮被点击了");
}

#pragma mark - getter && setter


- (PLTapImageView *)ownerImageView {
    if (!_ownerImageView) {
        _ownerImageView = [[PLTapImageView alloc] initWithFrame:CGRectMake(pDisplayCell_Padding, pDisplayCell_Padding, pDissplayCell_UserIcon, pDissplayCell_UserIcon)];
        
        _ownerImageView.layer.masksToBounds = YES;
//        _ownerImageView.clipsToBounds = YES;
        _ownerImageView.layer.cornerRadius =pDissplayCell_UserIcon/2;
        _ownerImageView.contentMode = UIViewContentModeScaleAspectFit;
        _ownerImageView.layer.borderWidth = 0.5;
        _ownerImageView.layer.borderColor =[UIColor lightGrayColor].CGColor;
    }
    return _ownerImageView;
}

- (UIButton *)ownerNameBtn {
    if (!_ownerNameBtn) {
        _ownerNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _ownerNameBtn.layer.masksToBounds = YES;
        _ownerNameBtn.layer.cornerRadius = 2.0;
        _ownerNameBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_ownerNameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_ownerNameBtn setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [_ownerNameBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
        _ownerNameBtn.frame = CGRectMake(CGRectGetMaxX(self.ownerImageView.frame) + pDisplayCell_Padding, CGRectGetMinY(self.ownerImageView.frame), pDisplayCell_BtnWidth, pDissplayCell_UserIcon/2);
        [_ownerNameBtn addTarget:self action:@selector(userBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        _ownerNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _ownerNameBtn;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel =  [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.ownerNameBtn.frame), CGRectGetMaxY(self.ownerNameBtn.frame)+pDisplayCell_ViewSpace, FFSCREEN_WIDTH/2, pDissplayCell_UserIcon/2-pDisplayCell_ViewSpace)];
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _timeLabel;
}

- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.layer.masksToBounds = YES;
        _followButton.layer.cornerRadius = 2.0;
        _followButton.layer.borderWidth = 0.5;
        _followButton.layer.borderColor = [UIColor blueColor].CGColor;
        _followButton.frame =  CGRectMake(FFSCREEN_WIDTH-60, CGRectGetMaxY(self.timeLabel.frame)-30, pDisplayCell_BtnWidth, 30);
        [_followButton addTarget:self action:@selector(followBtnClicked) forControlEvents:UIControlEventTouchUpInside];
}
    return _followButton;
}

- (UILabel *)contentLabel {
    if(!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.ownerImageView.frame), CGRectGetMaxY(self.timeLabel.frame)+pDisplayCell_ViewSpace, FFSCREEN_WIDTH-pDisplayCell_Padding*2, 20)];
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.textColor = [UIColor blackColor];
    }
    return _contentLabel;
}

- (PLCustomCollectionView *)mediaView {
    if (!_mediaView) {
          UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = pDisplayCell_CollectionMargin;
        layout.minimumLineSpacing = pDisplayCell_CollectionMargin;
        _mediaView = [[PLCustomCollectionView alloc] initWithFrame:CGRectMake(pDisplayCell_Padding, 0, FFSCREEN_WIDTH-pDisplayCell_Padding*2, 80) collectionViewLayout:layout];
        _mediaView.scrollEnabled = NO;
        _mediaView.backgroundColor = [UIColor clearColor];
        _mediaView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
        _mediaView.dataSource = self;
        _mediaView.delegate = self;
        [_mediaView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PLCustomCollectionViewCell"];
        [_mediaView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PLCustomCollectionViewCellArticle"];
    }
    return _mediaView;
}

- (UIButton *)readBtn {
    if (!_readBtn) {
        _readBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _readBtn.frame = CGRectMake(pDisplayCell_Padding, 0, pDisplayCell_BtnWidth, pDisplayCell_BtnHeight);
        [_readBtn setImage:[UIImage imageNamed:@"read"] forState:UIControlStateNormal];
        [_readBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_readBtn setTitle:@"100" forState:UIControlStateNormal];
    }
    return _readBtn;
}

- (UIButton *)shareBtn {
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareBtn.frame = CGRectMake(CGRectGetMaxX(self.readBtn.frame)+pDisplayCell_BtnPadding, 0, pDisplayCell_BtnWidth, pDisplayCell_BtnHeight);
         [_shareBtn setTitle:@"分享" forState:UIControlStateNormal];
        [_shareBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [_shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_shareBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        _shareBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _shareBtn;
}

- (UIButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _commentBtn.frame = CGRectMake(CGRectGetMaxX(self.shareBtn.frame)+pDisplayCell_BtnPadding, 0, pDisplayCell_BtnWidth, pDisplayCell_BtnHeight);
         [_commentBtn setImage:[UIImage imageNamed:@"news"] forState:UIControlStateNormal];
         [_commentBtn setTitle:@"100" forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        _commentBtn .imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _commentBtn;
}

- (UIButton *)likeBtn {
    if (!_likeBtn) {
        _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeBtn.frame = CGRectMake(CGRectGetMaxX(self.commentBtn.frame)+pDisplayCell_BtnPadding, 0, pDisplayCell_BtnWidth, pDisplayCell_BtnHeight);
        [_likeBtn setImage:[UIImage imageNamed:@"thumbs_up"] forState:UIControlStateNormal];
         [_likeBtn setTitle:@"100" forState:UIControlStateNormal];
         [_likeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _likeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
         [_likeBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    }
    return _likeBtn;
}

@end
