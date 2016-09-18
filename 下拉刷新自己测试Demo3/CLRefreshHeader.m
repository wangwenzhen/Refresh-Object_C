//
//  CLRefreshHeader.m
//  下拉刷新自己测试Demo3
//
//  Created by 王文震 on 16/8/17.
//  Copyright © 2016年 王文震. All rights reserved.
//

#import "CLRefreshHeader.h"
#import "CLCircleLoadingView.h"
#import "UIView+CLExtension.h"
#import "UIScrollView+CLExtension.h"
#import "CLRefreshViewConstant.h"
/**
 *  这个类中执行的就是稍微具体的事件，加载动画绘制
 */
@implementation CLRefreshHeader
- (instancetype)initWithFrame:(CGRect)frame{
    frame.size.height = CLRefreshHeaderVeiwHeight;
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}
/** 子类重写，父类中默认返回的是-1，表示加载动画视图处在屏幕外 */
- (CGFloat)showProgress:(UIEdgeInsets)scrollViewInsets scrollViewOffset:(CGPoint)offset{
    CGFloat willShowOffsetY = -self.scrollViewOriginalInserts.top;
    CGFloat currentOffsetY = offset.y;
    
    if (currentOffsetY >= willShowOffsetY) {
        return -1;
    }else{
        CGFloat progerss = (currentOffsetY - willShowOffsetY) / -self.cl_height;
        return progerss;
    }
}
/** 子类重写 */
- (CGPoint)willShowPoint{
    return CGPointMake(0, -self.scrollViewOriginalInserts.top-self.cl_height);
}
/** 子类重写,没有执行效果 */
- (void)refreshViewChangeUIWhenNormal{
    [super refreshViewChangeUIWhenNormal];
}
- (void)refreshViewChangeUIWhenFinishLoading{
    [super refreshViewChangeUIWhenFinishLoading];
    if (self.scrollViewOriginalInserts.top == 0) {
        self.scrollView.cl_contentInsetTop = 0;
    }else if(self.scrollViewOriginalInserts.top == self.scrollView.cl_contentInsetTop){
        self.scrollView.cl_contentInsetTop -= self.cl_height;
    }else{//动画执行后将重新调整滚动视图的inset
        self.scrollView.cl_contentInsetTop = self.scrollViewOriginalInserts.top;
    }
}
/** 子类重写，未实现提供接口 */
- (void)refreshViewChangeUIWhenWillLoading{
    [super refreshViewChangeUIWhenWillLoading];
}
- (void)refreshViewChangeUIWhenLoading{
    [super refreshViewChangeUIWhenLoading];
    CGFloat top = self.scrollViewOriginalInserts.top + self.cl_height;
    /**
     *  注意一点 对UIScrollerview的ContentInset进行重新设置后，需要对contentOffset重新进行设置，不然界面会有闪跳的现象
     */
    [UIView animateWithDuration:CLRefreshAnimationDurationNormal animations:^{
        self.scrollView.cl_contentInsetTop = top;
    } completion:^(BOOL finished) {
       [UIView animateWithDuration:CLRefreshAnimationDurationNormal animations:^{
            /** 加载动画执行的时候，重新设置滚动视图的Inset后，还要对contentOffset进行设置，不然可能导致动画闪跳*/
            self.scrollView.contentOffset = CGPointMake(0, -top);
       } completion:^(BOOL finished) {
               /** 执行回调 */
           if (self.refreshAction) {
               self.refreshAction();
           }
       }];
    }];
}
@end
