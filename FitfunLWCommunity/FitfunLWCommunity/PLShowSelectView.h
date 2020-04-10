////
//  PLShowSelectView.h
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/12.
//Copyright © 2019年 penglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLShowSelectView : NSObject

- (void)showSelectView:(NSArray *)dataSouce
       selectedNewCell:(void(^)(NSUInteger indexRow))selectCellBlock
          disAppear:(dispatch_block_t)disAppearBlock;

+ (void)showSelectView:(NSArray *)dataSouce
       selectedNewCell:(void (^)(NSUInteger))selectCellBlock
             disAppear:(dispatch_block_t)disAppearBlock;
@end

NS_ASSUME_NONNULL_END
