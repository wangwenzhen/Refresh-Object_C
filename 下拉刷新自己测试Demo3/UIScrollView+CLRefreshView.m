
//
//  UIScrollView+CLRefreshView.m
//  下拉刷新自己测试Demo3
//
//  Created by 王文震 on 16/8/17.
//  Copyright © 2016年 王文震. All rights reserved.
//

#import "UIScrollView+CLRefreshView.h"
#import "CLSimpleRefreshHeader.h"//不同时机下的提示语
#import "CLSimpleRefreshFooter.h"
#import <objc/runtime.h>
static char CLRefreshHeaderViewKey;
static char CLRefreshFooterViewKey;
@implementation UIScrollView (CLRefreshView)
- (void)setCl_refreshHeader:(CLRefreshHeader *)cl_refreshHeader{
    [self willChangeValueForKey:@"CLRefreshHeaderViewKey"];
    objc_setAssociatedObject(self, &CLRefreshHeaderViewKey, cl_refreshHeader,OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"CLRefreshHeaderViewKey"];
}
- (CLRefreshHeader *)cl_refreshHeader{
    return objc_getAssociatedObject(self, &CLRefreshHeaderViewKey);
}
-(void)setCl_refreshFooter:(CLRefreshFooter *)footer{
    [self willChangeValueForKey:@"CLRefreshFooterViewKey"];
    objc_setAssociatedObject(self,
                             &CLRefreshFooterViewKey,
                             footer,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"CLRefreshFooterViewKey"];
}

-(CLRefreshFooter *)cl_refreshFooter{
    return objc_getAssociatedObject(self, &CLRefreshFooterViewKey);
}


- (void)cl_addRefreshHeaderView:(CLRefreshHeader *)header{
    [self cl_removeRefreshHeader];
    [self insertSubview:header atIndex:0];
    self.cl_refreshHeader = header;
}
- (void)cl_removeRefreshHeader{
    [self.cl_refreshHeader removeFromSuperview];
    self.cl_refreshHeader = nil;//空间直接释放，被arc 回收
}
/** 提供直接刷新 */
- (void)cl_refreshHeaderStartAction{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cl_refreshHeader startRefresh];
    });
}
/** 提供添加下拉刷新的视图 */
- (void)cl_addRefreshHeaderViewWithAction:(void(^)())action{
    CLRefreshHeader *header = [CLSimpleRefreshHeader refreshView];
    header.refreshAction = action;
    [self cl_addRefreshHeaderView:header];
}
/** 提供结束刷新 */
- (void)cl_refreshHeaderFinishAction{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cl_refreshHeader endRefresh];
    });
}


/** -------上拉分割线-------- */
- (void)cl_addRefreshFooterViewWithAction:(void(^)())action{
    CLRefreshFooter *footer = [CLSimpleRefreshFooter refreshView];
    footer.refreshAction = action;
    [self cl_addRefreshFooterView:footer];
}
- (void)cl_refreshFooterStartAction{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cl_refreshFooter startRefresh];
    });
}
- (void)cl_refreshFooterFinishAction{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cl_refreshFooter endRefresh];
    });

}
-(void)cl_addRefreshFooterView:(CLRefreshFooter *)footer{
    [self cl_removeRefreshFooter];
    [self addSubview:footer];
    self.cl_refreshFooter = footer;
}
- (void)cl_removeRefreshFooter{
    [self.cl_refreshFooter removeFromSuperview];
    self.cl_refreshFooter = nil;
}
@end
