//
//  ViewController.m
//  下拉刷新Demo
//
//  Created by 王文震 on 16/8/9.
//  Copyright © 2016年 王文震. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+CLRefreshView.h"

NSString *const CLTableViewCellId = @"CellId";
#define kLoadOptionHeader 1
#define kLoadOptionFooter 2

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tabelview;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) int loadCount;
@end

@implementation ViewController
-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        for (int i=0; i<2; i++) {
            [_dataSource addObject:[NSString stringWithFormat:@"base data %i",i]];
        }
    }
    return _dataSource;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabelview cl_refreshHeaderStartAction];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabelview.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.tabelview];
    /** 执行刷新的添加 */
    [self setupRefresh];
}
- (void)setupRefresh{
    [self setUpSimpleHeader];
    [self setUpSimpleFooter];
}
/** 上拉刷新 */
- (void)setUpSimpleFooter{
    __weak typeof (self) weakSelf = self;
    [self.tabelview cl_addRefreshFooterViewWithAction:^{
        [weakSelf loadHeaderData:kLoadOptionFooter];
    }];
}
/** 下拉刷新 */
- (void)setUpSimpleHeader{
    __weak typeof (self) weakSelf = self;
    [self.tabelview cl_addRefreshHeaderViewWithAction:^{
        [weakSelf loadHeaderData:kLoadOptionHeader];
    }];
    
}
-(void)loadHeaderData:(int)option{
    dispatch_queue_t queue= dispatch_queue_create("com.unknown.refresh.demo", DISPATCH_QUEUE_SERIAL);
    NSString *format;
    if (option == kLoadOptionHeader) {
        format = @"header added %i";
    }else if (option == kLoadOptionFooter){
        format = @"footer added %i";
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), queue, ^{
        NSMutableArray *newDatas = [NSMutableArray array];
        int recoderCount;
        if (self.loadCount > 1) {
            recoderCount = 5;
        }else{
            recoderCount = 10;
        }
        for (int i=0; i<recoderCount; i++) {
            [newDatas addObject:[NSString stringWithFormat:format,arc4random() % 10]];
        }
        if (option == kLoadOptionFooter) {
            [self.dataSource addObjectsFromArray:newDatas];
        }else if(option == kLoadOptionHeader){
            [newDatas addObjectsFromArray:self.dataSource];
            self.dataSource = newDatas;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tabelview reloadData];
        });
        if (option == kLoadOptionHeader) {
            /** 下拉刷新动作结束 */
            [self.tabelview cl_refreshHeaderFinishAction];
        }else{
            [self.tabelview cl_refreshFooterFinishAction];
        }
        self.loadCount++;
    });
}

- (UITableView *)tabelview {
    if(_tabelview == nil) {
        _tabelview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tabelview registerClass:[UITableViewCell class] forCellReuseIdentifier:CLTableViewCellId];
        _tabelview.delegate = self;
        _tabelview.dataSource = self;
    }
    return _tabelview;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CLTableViewCellId forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

@end
