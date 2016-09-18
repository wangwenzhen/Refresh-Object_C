//
//  CLAbstractLoadingView.m
//  下拉刷新自己测试Demo3
//
//  Created by 王文震 on 16/8/17.
//  Copyright © 2016年 王文震. All rights reserved.
//

#import "CLAbstractLoadingView.h"
#import "UIView+CLExtension.h"
#import "CLRefreshViewConstant.h"

@implementation CLAbstractLoadingView

const CGFloat CLRefreshLoadingViewMaxProgress = 1.0f;

const CGFloat CLRefreshLoadingViewMinProgress = 0.0f;
+ (instancetype)loadingView{
    return [[self alloc] init];
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setShowProgress:(CGFloat)showProgress{
      /** 设置防止溢出的条件 */
    if (showProgress < CLRefreshLoadingViewMinProgress) {
        showProgress = CLRefreshLoadingViewMinProgress;
    }else if(showProgress > CLRefreshLoadingViewMaxProgress){
        showProgress = CLRefreshLoadingViewMaxProgress;
    }
    _showProgress = showProgress;
    if (!self.isHidden || self.alpha > 0.01 ) {
        //在加载视图隐藏的时候关闭重绘方法减少内存消耗，在alpha <= 0.01 默认时，视图是隐藏的
        [self setNeedsDisplay];//执行子类 的 drawRect方法
    }
}
/** 子类继承super获取方法，将通用的方法定义在父类抽象出来，这样在子类中不需要重写方法 */
- (void)startAnimation{
    if (self.isHidden || self.alpha < 0.01) {
        return;
    }
}
- (void)stopAnimation{
    [self.layer removeAllAnimations];
}
@end

