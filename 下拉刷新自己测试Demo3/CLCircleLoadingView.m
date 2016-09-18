//
//  CLCircleLoadingView.m
//  下拉刷新自己测试Demo3
//
//  Created by 王文震 on 16/8/17.
//  Copyright © 2016年 王文震. All rights reserved.
//

#import "CLCircleLoadingView.h"
#import "UIView+CLExtension.h"
#import "CLRefreshViewConstant.h"
@implementation CLCircleLoadingView

- (void)startAnimation{
    [super startAnimation];//父类的判断中，不执行的直接跳出
        /** 对绘制完成的UIView进行旋转 */
    CABasicAnimation *rotationAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    rotationAnim.toValue = [NSNumber numberWithFloat: 2 * M_PI];
    rotationAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotationAnim.repeatCount = INFINITY;
    rotationAnim.duration = 1.0f;
    [self.layer addAnimation:rotationAnim forKey:@"rotation"];

}
- (void)drawRect:(CGRect)rect{
    /**
     *   滚动下滑的时候，设置一个动画开始执行的进度，
     *   不然加载动画的视图没有拉下了，就执行的差不多了
     */
    CGFloat beginProgress = 0.2f;
    if (self.showProgress < beginProgress) {
        return;//在滚动视图下滑到一定距离的时候 动画开始执行
    }
    CGFloat offsetProgress = 1.0f - beginProgress;
     /** 调整后的动画执行进度 */
    CGFloat displayProgress = (self.showProgress - beginProgress) / offsetProgress;
    /** 获取当前的图形上下文
     这个获取只能在drawRect中有效
     */
    CGContextRef context = UIGraphicsGetCurrentContext();
      /** 1.外层大圆 */
    [[UIColor lightGrayColor] set];
    
    CGFloat bigCycleLineWidth = 2.0f;
    CGContextSetLineWidth(context, bigCycleLineWidth);
    CGFloat bigCycleRadius = self.cl_width * 0.5 - 2 * bigCycleLineWidth;
    CGFloat centerX = CGRectGetMidX(rect);
    CGFloat centerY = CGRectGetMidY(rect);
    CGContextAddArc(context, centerX, centerY, bigCycleRadius, -M_PI / 180 * 90, -M_PI / 180 * (360 * displayProgress + 90), 1);//形成一个闭合圆
    
    CGContextStrokePath(context);//空心
    /** 2.内心小圆 */
    CGFloat smallCycleMaxRadius = bigCycleRadius - 6.0f;
    CGFloat cycleRadius = self.showProgress * smallCycleMaxRadius;//这样写的效果，视图进入屏幕，实心圆是填充可见的
    CGContextAddArc(context, centerX, centerY, cycleRadius, 0, 2 * M_PI, 1);
    CGContextFillPath(context);
      /** 3.内层小圆 */
    CGFloat willShowMidCycleProgress = 0.5f;//重新调整进度，使得内外层效果更加明显
    if (self.showProgress >= willShowMidCycleProgress) {
        /** 这样做 midProgress 最大的进度是0.8，使得内层圆不会绘制完整，对比更加明显 */
        CGFloat midProgress = (self.showProgress - willShowMidCycleProgress) / (CLRefreshLoadingViewMaxProgress - willShowMidCycleProgress);
        CGFloat midCycleRadius = smallCycleMaxRadius + 2.5f;
        [[UIColor redColor] set];
        CGContextSetLineCap(context, kCGLineCapRound);//显示的线是圆角处理
        CGContextSetLineJoin(context, kCGLineJoinRound);//线条交接的时候圆角处理
        CGContextSetLineWidth(context, 3.0f);
          /** 最后一个参数表示的是 绘制方向是否是逆时针 */
        CGContextAddArc(context, centerX, centerY, midCycleRadius, -M_PI / 180 * 90, M_PI / 180 * (270 * midProgress - 90), 0);
        CGContextStrokePath(context);
        
    }
    
    
}
@end
