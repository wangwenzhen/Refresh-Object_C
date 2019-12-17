# Refresh-Object_C


![刷新工具类.png](http://upload-images.jianshu.io/upload_images/1517349-b23123708e29ab96.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/640)
##效果图--------
![开始刷新.png](http://upload-images.jianshu.io/upload_images/1517349-4e5af5c29db26d8a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/240)

![点击加载更多.png](http://upload-images.jianshu.io/upload_images/1517349-b401cff5c0fb815d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/240)
![下拉刷新视图.png](http://upload-images.jianshu.io/upload_images/1517349-11f4870e57f91327.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/240)
![上拉刷新.png](http://upload-images.jianshu.io/upload_images/1517349-1f0ff5442b827893.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/240)
##实现思路 
#结构解析
##一、下拉刷新实现
导入`#import "UIScrollView+CLRefreshView.h"`，添加滚动视图的刷新效果，在基类中创建刷新工具类，以便子类`UITableView`、`UIScrollView`通用。
```
/** 下拉刷新 */
- (void)setUpSimpleHeader{
    __weak typeof (self) weakSelf = self;
    [self.tabelview cl_addRefreshHeaderViewWithAction:^{
        [weakSelf loadHeaderData:kLoadOptionHeader];
    }];  
}
``` 
在分类中，因为不能添加属性，`#import <objc/runtime.h>`使用runtime机制，将vc上传入的滚动视图，进行刷新视图绑定
```
- (void)setCl_refreshHeader:(CLRefreshHeader *)cl_refreshHeader{
    [self willChangeValueForKey:@"CLRefreshHeaderViewKey"];
    objc_setAssociatedObject(self, &CLRefreshHeaderViewKey, cl_refreshHeader,OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"CLRefreshHeaderViewKey"];
}
- (CLRefreshHeader *)cl_refreshHeader{
    return objc_getAssociatedObject(self, &CLRefreshHeaderViewKey);
}
```
通过set方法将传入的滚动视图，绑定& CLRefreshHeaderViewKey唯一标识。这里针对的是唯一字符串的地址空间，这样的好处是不会重复绑定。实现了唯一性。字符串`static char CLRefreshHeaderViewKey;`

一、具体实现思路：CLAbstractRefreshView抽象类，执行刷新状态的监听
```
/** 不同时机下的刷新状态 */
typedef enum {
    CLRefreshViewStateNormal = 1,//滚动视图滑动但是，未触发加载时机
    CLRefreshViewStateWillLoading,//滚动视图滑动，且触发到最大下拉距离的时机
    CLRefreshViewStateLoading//正在加载中
}CLRefreshViewState;
```
#####编写下拉刷新的关键是考虑contentOffset以及contentInsert，前者用来判断当前手势下滑进行的进度和程度，从而去判断刷新视图进行的状态变化，并借由它将进度传入动画视图去执行动画流程。
![动画视图.png](http://upload-images.jianshu.io/upload_images/1517349-dd3ec98893acc0de.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/240)

```
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
```

###使用多态，提高程序的可读性。
子类`CLSimpleRefreshHeader`（ 这个类主要去实现细节，比如不同时机下的提示语句，还有创建动画视图），父类`CLRefreshHeader` （实现对视图不同状态下，位置的设置），抽象类`CLAbstractRefreshView`（监听手势滑动去实现刷新视图状态的改变以及动画视图的绘制进度调整）
子类`CLCircleLoadingView`（绘制动画），抽象类`CLAbstractLoadingView`(设置绘画的进度)

```
/** 提供添加下拉刷新的视图 */
- (void)cl_addRefreshHeaderViewWithAction:(void(^)())action{
    CLRefreshHeader *header = [CLSimpleRefreshHeader refreshView];
    header.refreshAction = action;
    [self cl_addRefreshHeaderView:header];
}
```
##二、上拉刷新

子类`CLSimpleRefreshFooter`(创建动画视图CLCircleLoadingView)，父类`CLRefreshFooter`（通过上拉状态设置滚动视图的固定位置）,抽象类`CLAbstractRefreshView`（设置不同的刷新状态监听）。
注意的一点：`上拉刷新`在界面内容过少的时候，应该显示“加载更多的提示按钮”。与下拉通过contentOffset不同现在监听的是滚动视图的contentSize。

具体的代码解析 ，我已经写在了工具类中，十分清晰，每句话几乎都有注释，每个类的创建时机、执行对象都有明确的标注。
###github源代码（解析）
https://github.com/wangwenzhen/Refresh-Object_C
