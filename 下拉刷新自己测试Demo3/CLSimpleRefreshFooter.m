
//
//  CLSimpleRefreshFooter.m
//  下拉刷新自己测试Demo3
//
//  Created by 王文震 on 16/8/18.
//  Copyright © 2016年 王文震. All rights reserved.
//

#import "CLSimpleRefreshFooter.h"
#import "CLCircleLoadingView.h"
#import "UIView+CLExtension.h"
@implementation CLSimpleRefreshFooter
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        CLCircleLoadingView *loadingView = [CLCircleLoadingView loadingView];
        self.loadingView = loadingView;
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat loadingViewWH = 30;
    CGFloat centerX = (self.cl_width - loadingViewWH) / 2.0;
    CGFloat centerY = (self.cl_height - loadingViewWH) / 2.0;
    CGRect loadingViewFrame = CGRectMake(centerX, centerY, loadingViewWH, loadingViewWH);
    self.loadingView.frame = loadingViewFrame;
}
@end
