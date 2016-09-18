//
//  CLRefreshFooter.h
//  下拉刷新自己测试Demo3
//
//  Created by 王文震 on 16/8/18.
//  Copyright © 2016年 王文震. All rights reserved.
//

#import "CLAbstractRefreshView.h"

@interface CLRefreshFooter : CLAbstractRefreshView
/** 当显示内容并没有超出ScrollView高度时显示的加载按钮 */
@property (nonatomic, weak) UIButton *loadButton;

/** 按钮文字 */
@property (nonatomic, copy) NSString *normalLoadButtonTittle;
/** 按钮字体 */
@property (nonatomic, strong) UIFont *loadButtonFont;
/** 在滚动视图中
 *  contentSize.height > frame.size.height
 */
@property (nonatomic, assign, getter=isOverScrollView) BOOL overScrollView;
/** contentSize变化时，调整自身Frame */
- (void)adjustFrame;
@end


