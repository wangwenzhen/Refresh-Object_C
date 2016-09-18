//
//  UIScrollView+CLRefreshView.h
//  下拉刷新自己测试Demo3
//
//  Created by 王文震 on 16/8/17.
//  Copyright © 2016年 王文震. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CLRefreshHeader;
@class CLRefreshFooter;

@interface UIScrollView()
@property (nonatomic, weak) CLRefreshHeader *cl_refreshHeader;
@property (nonatomic, weak) CLRefreshFooter *cl_refreshFooter;
@end

@interface UIScrollView (CLRefreshView)
/** ------下拉------- */
/** 提供直接刷新 */
- (void)cl_refreshHeaderStartAction;
/** 提供添加下拉刷新的视图 */
- (void)cl_addRefreshHeaderViewWithAction:(void(^)())action;
/** 提供结束刷新 */
- (void)cl_refreshHeaderFinishAction;

/** -------上拉------ */
- (void)cl_addRefreshFooterViewWithAction:(void(^)())action;
- (void)cl_refreshFooterStartAction;
- (void)cl_refreshFooterFinishAction;


@end
