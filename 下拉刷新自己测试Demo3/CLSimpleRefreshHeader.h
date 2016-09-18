//
//  CLSimpleRefreshHeader.h
//  下拉刷新自己测试Demo3
//
//  Created by 王文震 on 16/8/17.
//  Copyright © 2016年 王文震. All rights reserved.
//

#import "CLRefreshHeader.h"
/**
 *  这个类主要去实现细节，比如不同时机下的提示语句，还有加载时候的不同时机的动画
 */
@interface CLSimpleRefreshHeader : CLRefreshHeader
@property (nonatomic, weak) UILabel *textLabel;
@end
