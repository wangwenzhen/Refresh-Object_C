//
//  CLBaseRefershView.m
//  RefreshViewDemo
//
//  Created by 刘昶 on 14/11/26.
//  Copyright (c) 2014年 unknown. All rights reserved.
//

#import "CLAbstractRefreshView.h"
#import "CLAbstractLoadingView.h"
#import "UIView+CLExtension.h"
#import "CLRefreshViewConstant.h"
#import "UIScrollView+CLExtension.h"
#import "CLRefreshViewConstant.h"//定义的const 字符串
@interface CLAbstractRefreshView ()
@end
@implementation CLAbstractRefreshView

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;//在横竖屏幕 中自动适应宽度
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


+(instancetype)refreshView{
    return [[self alloc]init];
}
/** 当刷新视图将要添加入滚动视图中 */
-(void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    if (self.superview) {
        /**
         * 这个方法会在视图将要添加 和 视图将要离开父视图的时候调用
         * 取消监听是在视图将要消失，离开父视图的时候去调用
         */
        [self.superview removeObserver:self forKeyPath:CLScrollViewContentOffsetKeyPath];
    }
    
    if (newSuperview) {//父视图是UIScro滚动视图
        [newSuperview addObserver:self forKeyPath:CLScrollViewContentOffsetKeyPath options:NSKeyValueObservingOptionNew context:nil];
        /** 在抽象方法中，我们对刷新视图赋予了frame */
        self.cl_width = newSuperview.cl_width;
        self.cl_origin = [self willShowPoint];//添加是在创建空间之后，如果重写该方法，就会影响y
        _scrollView  = (UIScrollView *)newSuperview;
        _scrollView.alwaysBounceVertical = YES;//设置滚动视图一直允许上下滑动
        _scrollViewOriginalInserts = _scrollView.contentInset;
    }
}
/** 默认该方法要重写 ，不然默认添加刷新视图处在屏幕外 */
-(CGFloat)showProgress:(UIEdgeInsets)scrollViewInsets scrollViewOffset:(CGPoint)offset{
    //    如果控件直接处与屏幕外，返回-1.父类默认返回-1,真的进度在子类里重写。
    return -1;
}
/** kvo 监听变化 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (self.state == CLRefreshViewStateLoading) {
  //加载视图在加载过程中，滚动视图的偏移量是固定死的，这个操作是为了减少内存的消耗
        return;
    }
    if ([keyPath isEqualToString:CLScrollViewContentOffsetKeyPath]) {
        if (!self.userInteractionEnabled || self.isHidden || self.alpha <=0.01) {return;}
        /** 如果滚动视图现在不存在，加载动画偏移量固定中，以及视图是正常显示状态。我们就执行进度调整 */
        [self adjustState];
    }
}

-(void)adjustState{
    if (!self.window) {
       //如果视图都未出现在 窗口上直接返回
        return;
    }
    /** self.scrollViewOriginalInsets的赋值时机,是在刷新视图将要加入到滚动视图中的时候，也就是我们的WillMoveToSuperView中 */
    CGFloat showProgress = [self showProgress:self.scrollViewOriginalInserts scrollViewOffset:self.scrollView.contentOffset];
    if (showProgress == -1) {//这种情况说明 控件直接处与屏幕外 不执行任何操作
        return;
    }
    if (self.scrollView.isDragging) {//滚动视图正处于 被拖拽中

        /**
         *  self.loadingView 的空间的创建时机有子类去控制，这里都是通用的方法使用
         */
        self.loadingView.showProgress = showProgress;//将滚动视图的 偏移量进度赋值给 加载动画视图
        /** 这里要注意一点的是showProgress在用户拖拽滚动视图的时候可能是过多的超出，也有可能是过少移动，例如：用户将滚动视图的偏移量拖拽到了负值 。
         *
         */
        
        /** 视图在进入显示之前，UIView调用用drawRect，对state进行初始化的赋值 */
        if (showProgress >= CLRefreshLoadingViewMaxProgress && self.state == CLRefreshViewStateNormal) {//说明拖拽超出了限定的偏移量，并且用户未松开
            self.state = CLRefreshViewStateWillLoading;
            //            NSLog(@"showProgress >= CLRefreshLoadingViewMaxProgress \n\n %@", self);
        }else if (showProgress < CLRefreshLoadingViewMaxProgress && self.state == CLRefreshViewStateWillLoading){//说明用户在拖拽到限定时机后，没有松手，又将滚动视图 拖拽回normal的状态
            self.state = CLRefreshViewStateNormal;
            //            NSLog(@"showProgress < CLRefreshLoadingViewMaxProgress \n\n%@", self);
        }
        
        
    }else{
        //松手
        if(self.state == CLRefreshViewStateWillLoading){
            self.state = CLRefreshViewStateLoading;
        }else if (self.state == CLRefreshViewStateNormal){
            self.loadingView.showProgress = showProgress;
        }
    }
}

/** 当状态发生改变的时候去执行 */
/**
 *  不同的状态的提示语句不一样
 *
 *  @param state <#state description#>
 */
-(void)setState:(CLRefreshViewState)state{
    if (state == self.state) {//当前一致的状态说明之前的操作已经执行，无需再去执行一遍
        return;
    }
    _previousState = self.state;
    if (self.state != CLRefreshViewStateLoading) {
        /** 如果是在加载动画时候，inset是固定的不需要监控 */
        _scrollViewOriginalInserts = self.scrollView.contentInset;
    }
    _state = state;
    
    if (self.state == CLRefreshViewStateNormal) {
        if (self.previousState == CLRefreshViewStateLoading) {
            [self.loadingView stopAnimation];
            self.loadingView.showProgress = CLRefreshLoadingViewMinProgress;
            //动画结束之后 将进度设置最低
            self.loadingView.hidden = YES;
            [UIView animateWithDuration:CLRefreshAnimationDurationNormal animations:^{
                /** 子类在重写这个方法后，对任务进行回调 */
                [self refreshViewChangeUIWhenFinishLoading];
            } completion:^(BOOL finished) {
                self.loadingView.hidden = NO;
                [self refreshViewChangeUIWhenNormal];
            }];
        }else{
            [self refreshViewChangeUIWhenNormal];
        }
    }else if(self.state == CLRefreshViewStateWillLoading){
        [self refreshViewChangeUIWhenWillLoading];
    }else if (self.state == CLRefreshViewStateLoading){
        self.loadingView.hidden = NO;
        self.loadingView.showProgress = CLRefreshLoadingViewMaxProgress;
        [self.loadingView startAnimation];
        
        [self refreshViewChangeUIWhenLoading];
    }
}

-(void)endRefresh{
    self.state = CLRefreshViewStateNormal;
}
-(void)startRefresh{
    if (self.window) {
        self.state = CLRefreshViewStateLoading;
    }else{
        //drwaRect:中处理
        self.state = CLRefreshViewStateWillLoading;
    }
}

-(CGPoint)willShowPoint{//这个方法在具体的子类中还是要重写，改变它的x，y
    return CGPointZero;
}
/** 显示动画视图加载的进度 */
-(CGFloat)showProgress{
    return self.loadingView.showProgress;
}
/** 没次去重新设置的时候，将之前的视图移除，重新添加 */
-(void)setLoadingView:(CLAbstractLoadingView *)loadingView{
    if (self.loadingView) {//如果是nil 说明是第一次添加
        loadingView.showProgress = self.loadingView.showProgress;
        [self.loadingView removeFromSuperview];
    }
    [self addSubview:loadingView];
    _loadingView = loadingView;
}

/**
 *  下面的方法执行由子类具体执行，抽象类中的方法主要还是公用方法
 */
-(void)refreshViewChangeUIWhenNormal{}
-(void)refreshViewChangeUIWhenWillLoading{}
-(void)refreshViewChangeUIWhenLoading{}
-(void)refreshViewChangeUIWhenFinishLoading{}

/**
 *  1.这个View在进入的时候没有去调用 setNeedsDisplay,所以drawRect只会执行一次
 *  2.而进入有两种情况 ：
 1）。直接加载数据执行动画。
 2）。没有任何变化。只是对state进行默认赋值。
 */
-(void)drawRect:(CGRect)rect{

    if (self.state == CLRefreshViewStateWillLoading) {
        [self startRefresh];
    }else{
        self.state = CLRefreshViewStateNormal;//默认第一次进来时候的赋值
    }
}
/** 界面调整的时候去重新估算，滚动视图的偏移量 */
-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.state != CLRefreshViewStateLoading) {
        _scrollViewOriginalInserts = self.scrollView.contentInset;
    }
}

@end
