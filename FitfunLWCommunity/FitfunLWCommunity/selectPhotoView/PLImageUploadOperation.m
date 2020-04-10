////
//  PLImageUploadOperation.m
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/14.
//Copyright © 2019年 penglei. All rights reserved.
//

#import "PLImageUploadOperation.h"
#import "TZImageManager.h"

@implementation PLImageUploadOperation

- (void)start {
    
    NSLog(@"TZImageUploadOperation start");
    self.executing = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[TZImageManager manager] getOriginalPhotoWithAsset:self.asset progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.progressBlock) {
                    self.progressBlock(progress, error, stop, info);
                }
            });
        } newCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!isDegraded) {
                    if (self.completedBlock) {
                        self.completedBlock(photo, info, isDegraded);
                    }
                    //  上传照片功能统一在这里处理，
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self done];
                    });
                }
            });
        }];
    });
}

- (void)done {
    [super done];
    // NSLog(@"TZImageUploadOperation done");
}

@end
