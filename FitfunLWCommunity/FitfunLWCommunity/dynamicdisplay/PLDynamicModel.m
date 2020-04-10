////
//  PLDynamicModel.m
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/15.
//Copyright © 2019年 penglei. All rights reserved.
//

#import "PLDynamicModel.h"

@implementation PLDynamicModel

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"isArticle"]) {
        self.isArticle = [value boolValue];
    }else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
@end
