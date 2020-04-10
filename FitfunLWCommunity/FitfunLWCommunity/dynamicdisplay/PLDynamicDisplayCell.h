////
//  PLDynamicDisplayCell.h
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/15.
//Copyright © 2019年 penglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLDynamicModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLDynamicDisplayCell : UITableViewCell

- (void)setDynamicDisplayCell:(PLDynamicModel *)model;

+ (CGFloat)getCellContentHeight:(PLDynamicModel *)model;

@end

NS_ASSUME_NONNULL_END
