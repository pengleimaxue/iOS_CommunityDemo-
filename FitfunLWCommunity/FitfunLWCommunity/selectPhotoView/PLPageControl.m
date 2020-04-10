////
//  PLPageControl.m
//  FitfunAssistant
//
//  Created by ___Fitfun___ on 2019/3/21.
//Copyright © 2019年 fitfun. All rights reserved.
//

#import "PLPageControl.h"

@interface PLPageControl()

@property (nonatomic, strong) UIImage *activeImage;
@property (nonatomic, strong) UIImage *inactiveImage;

@end

@implementation PLPageControl


- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        
        _activeImage = [UIImage imageNamed:@"inactive_page_image"];
        _inactiveImage = [UIImage imageNamed:@"active_page_image"];
        
        [self setCurrentPage:1];
    }
    return self;
}

- (id)initWithFrame:(CGRect)aFrame {
    
    if (self = [super initWithFrame:aFrame]) {
        
        _activeImage = [UIImage imageNamed:@"inactive_page_image"];
        _inactiveImage = [UIImage imageNamed:@"active_page_image"];
        
        [self setCurrentPage:1];
    }
    return self;
}


- (void)updateDots {
    
    for (int i = 0; i < [self.subviews count]; i++) {
        
        UIImageView* dot = [self.subviews objectAtIndex:i];
        
        if (i == self.currentPage) {
            
            if ( [dot isKindOfClass:UIImageView.class] ) {
                
                ((UIImageView *) dot).image = _activeImage;
            }
            else {
                
                dot.backgroundColor = [UIColor colorWithPatternImage:_activeImage];
            }
        }
        else {
            
            if ( [dot isKindOfClass:UIImageView.class] ) {
                
                ((UIImageView *) dot).image = _inactiveImage;
            }
            else {
                
                dot.backgroundColor = [UIColor colorWithPatternImage:_inactiveImage];
            }
        }
    }
}

- (void) setCurrentPage:(NSInteger)page {
    
    [super setCurrentPage:page];
    
    [self updateDots];
}


@end
