////
//  PLDynamicModel.h
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/15.
//Copyright © 2019年 penglei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLDynamicModel : NSObject

@property (nonatomic, strong) UIImage *ownerImg;
@property (nonatomic, copy) NSString *ownerName;
@property (nonatomic, copy) NSString *pubulishTime;
//是否已经关注
@property (nonatomic, copy) NSString *follow;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSArray <UIImage *> *imageArray;
@property (nonatomic, copy) NSString *readNumber;
@property (nonatomic, copy) NSString *messageNumber;
@property (nonatomic, copy) NSString *likeNumber;
//是否已经点赞
@property (nonatomic, assign) BOOL isLike;
//文章类型 是否是长文
@property (nonatomic, assign) BOOL isArticle;

@end

NS_ASSUME_NONNULL_END
