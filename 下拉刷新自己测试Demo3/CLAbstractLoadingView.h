//
//  CLAbstractLoadingView.h
//  下拉刷新自己测试Demo3
//
//  Created by 王文震 on 16/8/17.
//  Copyright © 2016年 王文震. All rights reserved.
//

#import <UIKit/UIKit.h>
/** 加载的动画视图抽象类 */
@interface CLAbstractLoadingView : UIView
/** 最大的显示进度 1.0f */
UIKIT_EXTERN const CGFloat CLRefreshLoadingViewMaxProgress;
/** 最小的显示进度 0.0f */
UIKIT_EXTERN const CGFloat CLRefreshLoadingViewMinProgress;
/** 时机加载的进度来设置加载动画的重绘 */
@property (nonatomic, assign) CGFloat showProgress;
/** 创建空间 */
+ (instancetype)loadingView;
/**
 *  加载时执行的动画，子类实现
 */
- (void)startAnimation;
/**
 *  结束动画，子类实现
 */
- (void)stopAnimation;
@end
