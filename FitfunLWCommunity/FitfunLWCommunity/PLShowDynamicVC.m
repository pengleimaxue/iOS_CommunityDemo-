////
//  PLShowDynamicVC.m
//  FitfunLWCommunity
//
//  Created by ___Fitfun___ on 2019/3/18.
//Copyright © 2019年 penglei. All rights reserved.
//

#import "PLShowDynamicVC.h"
#import "PLDynamicDisplayCell.h"
#import "PLDynamicModel.h"

@interface PLShowDynamicVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation PLShowDynamicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    for (NSInteger i = 0; i<10; i++) {
        PLDynamicModel *model = [[PLDynamicModel alloc] init];
        model.isArticle = NO;
        UIImage *image = [UIImage imageNamed:@"xue.png"];
        NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:0];
        for (NSInteger j =1; j<=i; j++) {
            [imageArray addObject:image];
        }
        model.imageArray = imageArray;
        if (i==0) {
            model.content = @"fdafajdflajdfljalkfjladjflkajfkljdfkajdfkljadfkljkdfjfjadjfkladjfklajdfkljadlskjflkjadlfjaldfjladjfladjfladjfljflajflafjlajfldajfklajlfkjadlfjladjljdfljadlfjaldfjladfjladfjljfl";
        } else {
            model.content = @"312hkhfkajdfkjadlfjaldjfaldjflajdfladjfkaj";
        }
        
        model.ownerImg = [UIImage imageNamed:@"Icon-40.png"];
        model.pubulishTime = @"20190318";
        model.ownerName = @(i).stringValue;
        [self.dataSource addObject:model];
    }
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    return [PLDynamicDisplayCell getCellContentHeight:self.dataSource[indexPath.row]];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLDynamicDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLDynamicDisplayCell"];
    [cell setDynamicDisplayCell:self.dataSource[indexPath.row]];
    return cell;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[PLDynamicDisplayCell class] forCellReuseIdentifier:@"PLDynamicDisplayCell"];
    }
    return _tableView;
}

@end
