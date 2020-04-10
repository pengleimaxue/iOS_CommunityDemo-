////
//  PLSelectPhotoShowView.h
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/13.
//Copyright © 2019年 penglei. All rights reserved.
//选择照片，选择照片完成，类似微信的九宫格展示选择的照片

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PHAsset;

@interface PLSelectPhotoShowView : UIView

//选择的图片资源信息。可以自己处理，也可以使用TZImageManager处理这些选择资源信息
@property (nonatomic, strong) NSMutableArray<PHAsset*> *selectedAssets;
//最大照片或者视频可选数 默认1
@property (nonatomic, assign) NSUInteger maxSelectPhotosNumber;
//是否允许拍照 默认YES
@property (nonatomic, assign) BOOL showTakePhoto;
//是否允许拍摄视频，默认NO
@property (nonatomic, assign) BOOL showTakeVideo;
//是否允许选择照片 默认YES
@property (nonatomic, assign) BOOL allowPickingImage;
//是否允许选择GIF 默认NO
@property (nonatomic, assign) BOOL allowPickingGif;
//是否允许选择原图 默认YES
@property (nonatomic, assign) BOOL allowPickingOriginalPhoto;
//是否允许选择视频,默认NO
@property (nonatomic, assign) BOOL allowPickingVideo;
//是否允许多选视频，默认NO
@property (nonatomic, assign) BOOL allowPickingMuitlpleVideo;
//点击选择照片按钮之后是否展示弹框选择照片或者拍摄，默认NO
@property (nonatomic, assign) BOOL showSheetSwitch;
//右上角显示图片选择序列号，默认YES
@property (nonatomic, assign) BOOL showSelectedIndex;
//照片是否按照修改时间排序，默认YES
@property (nonatomic, assign) BOOL sortAscending;


//选择照片
- (void)selectPhotos;
//选择视频
- (void)selectVideo;

@end

NS_ASSUME_NONNULL_END
