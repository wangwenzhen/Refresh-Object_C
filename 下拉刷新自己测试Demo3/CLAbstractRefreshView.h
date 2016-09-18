//
//  CLAbstractRefreshView.h
//  下拉刷新自己测试Demo3
//
//  Created by 王文震 on 16/8/17.
//  Copyright © 2016年 王文震. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  提供基本的刷新抽象类
 */

/** 不同时机下的刷新状态 */
typedef enum {
    CLRefreshViewStateNormal = 1,//滚动视图滑动但是，未触发加载时机
    CLRefreshViewStateWillLoading,//滚动视图滑动，且触发到最大下拉距离的时机
    CLRefreshViewStateLoading//正在加载中
}CLRefreshViewState;
/** 抽象类中的基本协议 */
@protocol CLRefreshControl <NSObject>

@optional
- (void)refreshViewChangeUIWhenNormal;//执行 1
- (void)refreshViewChangeUIWhenWillLoading;//执行 2
- (void)refreshViewChangeUIWhenLoading;//执行 3
- (void)refreshViewChangeUIWhenFinishLoading;// 滚动视图复位
@end
/** 这是一个刷新的抽象类 */
@class CLAbstractLoadingView;
@interface CLAbstractRefreshView : UIView<CLRefreshControl>
@property (nonatomic, weak, readonly) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) UIEdgeInsets scrollViewOriginalInserts;//记录滚动视图的原始Insets
@property (nonatomic, copy) void (^refreshAction)();
@property (nonatomic, assign) CLRefreshViewState state;//记录当前刷新的状态
@property (nonatomic, assign, readonly) CLRefreshViewState previousState;//记录之前的刷新状态
/** 加载动画视图 */
@property (nonatomic, weak) CLAbstractLoadingView *loadingView;
/** 获取当前滚动视图里下拉时机的进度 */
@property (nonatomic, assign, readonly) CGFloat showProgress;
/** 创建下拉视图 */
+ (instancetype)refreshView;
- (void)endRefresh;//结束和开始刷新是，提供的抽象方法，是通用的
- (void)startRefresh;
#pragma mark -子类实现
/**
 *  根据滚动视图的属性计算出，空间将要显示的位置
 *
 *  @param scrollViewInsets <#scrollViewInsets description#>
 *  @param offset           <#offset description#>
 *
 *  @return 控价显示的百分比进度，如果控件直接处与屏幕外，返回-1.父类默认返回-1
 */
- (CGFloat)showProgress:(UIEdgeInsets)scrollViewInsets scrollViewOffset:(CGPoint)offset;
/**
 *  控件将要显示的位置，由Header子类实现，Footer子类此方法无意义
 *
 *  @return 控件刚加入滚动视图时，将要显示的位置，默认返回（0，0）
 */
- (CGPoint)willShowPoint;
@end
