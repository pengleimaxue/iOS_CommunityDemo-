////
//  ViewController.m
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/11.
//Copyright © 2019年 penglei. All rights reserved.
//

#import "ViewController.h"
//#import "UIButton+PLImageLayout.h"
#import "PLButton.h"
#import "PLReleaseDynamicsView.h"
#import "UIView+PM.h"
#import "PLShowSelectView.h"
#import "PLPublishArticle.h"
#import "SIXEditorView.h"
#import "PLShowDynamicVC.h"

@interface ViewController ()

@property (nonatomic, strong) PLButton *button;
@property (nonatomic, strong) PLReleaseDynamicsView *releaseDynamicsView;
@property (nonatomic, strong) PLPublishArticle *publishArticle;
@property (nonatomic, assign) NSUInteger selectIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.titleView = self.button;
    //[self.navigationBar setTintColor:color(0xFF9C9C9C)];
    self.navigationController.navigationBar.tintColor = [UIColor yellowColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
    [self.view addSubview:self.releaseDynamicsView];
    self.selectIndex = 0;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"详情展示" style:UIBarButtonItemStylePlain target:self action:@selector(showDynamicVC)];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)showDynamicVC {
    [self.navigationController pushViewController:[[PLShowDynamicVC alloc]init] animated:NO];
}
- (PLButton *)button {
    if (!_button) {
        _button = [PLButton buttonWithType:UIButtonTypeCustom];
         [_button setTitle:@"发布动态" forState:UIControlStateNormal];
        [_button setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
        //_button.backgroundColor = [UIColor greenColor];
        [_button pl_fitButtonImageLocaltion:PLButtonImageStyleRight imageTitleSpace:1.0f];
        [_button addTarget:self action:@selector(buttonTouch) forControlEvents:UIControlEventTouchUpInside];
        _button.frame = CGRectMake(0, 0, 90, 50);
    }
    return _button;
}

- (PLReleaseDynamicsView *)releaseDynamicsView {
    if (!_releaseDynamicsView) {
        _releaseDynamicsView = [[PLReleaseDynamicsView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-2)];
    }
    return _releaseDynamicsView;
}

- (PLPublishArticle *)publishArticle {
    if (!_publishArticle) {
        _publishArticle = [[PLPublishArticle alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-2)];
    }
    return _publishArticle;
}
- (void)buttonTouch {
    self.button.selected = !self.button.selected;
//    [[[PLShowSelectView alloc] init] showSelectView:@[@"发布动态",@"发布长文"] selectedNewCell:^(NSUInteger indexRow) {
//        NSLog(@"选中了%ld",indexRow);
//    } disAppear:^{
//        NSLog(@"隐藏了");
//    }];
    [PLShowSelectView  showSelectView:@[@"发布动态",@"发布长文"] selectedNewCell:^(NSUInteger indexRow) {
        if (indexRow == 0) {
            [self.publishArticle removeFromSuperview];
            self.publishArticle = nil;
            [self.view addSubview:self.releaseDynamicsView];
            [self.button setTitle:@"发布动态" forState:UIControlStateNormal];
        } else {
            [self.releaseDynamicsView removeFromSuperview];
            self.releaseDynamicsView = nil;
            [self.button setTitle:@"发布长文" forState:UIControlStateNormal];
            [self.view addSubview:self.publishArticle];
        }
        NSLog(@"选中了%ld",indexRow);
    } disAppear:^{
        NSLog(@"隐藏了");
    }];
}



@end
