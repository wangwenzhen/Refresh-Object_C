//
//  CLRefreshFooter.m
//  下拉刷新自己测试Demo3
//
//  Created by 王文震 on 16/8/18.
//  Copyright © 2016年 王文震. All rights reserved.
//

#import "CLRefreshFooter.h"
#import "UIView+CLExtension.h"
#import "UIScrollView+CLExtension.h"
#import "CLCircleLoadingView.h"
#import "CLRefreshViewConstant.h"

@interface CLRefreshFooter (){
    @protected
    BOOL _overScrollView;
}
@end

@implementation CLRefreshFooter
@synthesize overScrollView = _overScrollView;
- (instancetype)initWithFrame:(CGRect)frame{
    frame.size.height = CLRefreshFooterVeiwHeight;
    if (self = [super initWithFrame:frame]) {
        self.overScrollView = NO;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(startRefresh) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.loadButton = btn;
        self.loadButtonFont = kCLRefreshFooterLoadButtonFont;
        self.normalLoadButtonTittle = CLRefreshFooterLoadButtonTitle;
    }
    return self;
}
- (void)setLoadButtonFont:(UIFont *)loadButtonFont{
    _loadButtonFont = loadButtonFont;
    self.loadButton.titleLabel.font = loadButtonFont;
}
- (void)setLoadButton:(UIButton *)loadButton{
    if (self.loadButton) {
        [self.loadButton removeFromSuperview];
    }
    [self addSubview:loadButton];
    _loadButton = loadButton;
}
- (void)setNormalLoadButtonTittle:(NSString *)normalLoadButtonTittle{
    _normalLoadButtonTittle = normalLoadButtonTittle.copy;
    [self.loadButton setTitle:normalLoadButtonTittle forState:UIControlStateNormal];
}
- (void)setOverScrollView:(BOOL)overScrollView{
    _overScrollView = overScrollView;
    if (self.state != CLRefreshViewStateLoading) {
        self.loadButton.hidden = overScrollView;
        self.loadingView.hidden = !overScrollView;
    }
}
- (void)adjustFrame{
    CGFloat scrollContentHeight = self.scrollView.cl_contentSizeHeight;
    CGFloat scrollViewHeight = self.scrollView.cl_height - self.scrollViewOriginalInserts.top - self.scrollViewOriginalInserts.bottom;
    /** 在这里调整了上拉刷新的起始点 */
    self.cl_y = scrollContentHeight;
    self.overScrollView = scrollContentHeight > scrollViewHeight;
}
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    if (self.superview) {
        [self.superview removeObserver:self forKeyPath:CLScrollViewContentSizeKeyPath];
    }
    if (newSuperview) {
        if ([newSuperview isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)newSuperview;
            if (tableView.tableFooterView.cl_height < 0.01) {
                UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
                tableView.tableFooterView = emptyView;
            }
        }
        [newSuperview addObserver:self forKeyPath:CLScrollViewContentSizeKeyPath options:NSKeyValueObservingOptionNew context:nil];
        [self adjustFrame];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (!self.userInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return;
    }
    if ([CLScrollViewContentSizeKeyPath isEqualToString: keyPath]) {
        [self adjustFrame];
    }else if ([CLScrollViewContentOffsetKeyPath isEqualToString:keyPath]){
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (CGFloat)showProgress:(UIEdgeInsets)scrollViewInsets scrollViewOffset:(CGPoint)offse{

    /** self.cl_y 指的是可是contentSize中的最底部 */
    CGFloat willShowOffsetY = self.cl_y - self.scrollView.cl_height + scrollViewInsets.bottom;
    if (offse.y >= willShowOffsetY && self.cl_height != 0 && self.isOverScrollView) {
        CGFloat progress = (offse.y - willShowOffsetY) / self.cl_height;
        return progress;
    }else{
        return -1;
    }
}
- (void)refreshViewChangeUIWhenNormal{
    [super refreshViewChangeUIWhenNormal];
    [self adjustFrame];
}
- (void)refreshViewChangeUIWhenFinishLoading{
    [super refreshViewChangeUIWhenFinishLoading];
    self.scrollView.cl_contentInsetBottom = self.scrollViewOriginalInserts.bottom;
}
- (void)refreshViewChangeUIWhenWillLoading{
    [super refreshViewChangeUIWhenWillLoading];
}
- (void)refreshViewChangeUIWhenLoading{
    [super refreshViewChangeUIWhenLoading];
    self.loadButton.hidden = YES;
    [UIView animateWithDuration:CLRefreshAnimationDurationFast animations:^{
        CGFloat bottom = self.cl_height + self.scrollViewOriginalInserts.bottom;
        self.scrollView.cl_contentInsetBottom = bottom;
    } completion:^(BOOL finished) {
        if (self.refreshAction) {
            self.refreshAction();
        }
    }];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.loadButton.frame = self.bounds;
}
- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
}
@end
