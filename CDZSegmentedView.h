//
//  CDZTableView.h
//
//
//  Created by baight on 14-2-10.
//  Copyright (c) 2014年 baight. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CDZSegmentedBar;
@protocol CDZSegmentedBarDelegate;

/*
 CDZSegmentedView 是一个类似于 windows选项卡 的控件，点击顶部的切换按钮，可在几个页面之间来回切换。
 支持左划右划手势，支持循环滚动
 */

@class CDZSegmentedView;
@protocol CDZSegmentedViewDelegate <NSObject>

@optional
// 将要跳转到某个页面
- (void)segmentedView:(CDZSegmentedView*)segmentedView willSwitchToPage:(NSInteger)page;
// 已经跳转到某个页面
- (void)segmentedView:(CDZSegmentedView*)segmentedView didSwitchToPage:(NSInteger)page;

//废弃的协议
- (void)willSwithToPage:(NSInteger)page;
- (void)beginDraggingInPage:(NSInteger)page;
- (void)endDraggingInPage:(NSInteger)page;
- (void)didClickSegButtonAgain:(NSInteger)index;
@end

@interface CDZSegmentedView : UIView <UIScrollViewDelegate>{
    UIImageView* _screen0;     // 第一屏数据，是 _screen1 前一页面的一个快照
    UIImageView* _screen1;          // 第二屏数据，要显示的 view 添加在 _screen1 上，
    UIImageView* _screen2;     // 第三屏数据，是 _screen1 后一页面的一个快照
    UIScrollView* _scrollView; // 滚动view，里边放着 _screen0、_screen1、_screen2
    NSInteger _prevousPage;
    NSInteger _nextPage;       // 在拖动时，记录接下来将要跳到哪个页面
}

@property (assign, nonatomic) NSInteger currentPage;           // 当前显示的第几页
@property (assign, nonatomic) BOOL canCycleScroll;             // 是否可循环滚动
@property (strong, nonatomic) CDZSegmentedBar* segmentedBar;   // 类似 UISegmentedControl 的一个控件
@property (assign, nonatomic) CGFloat segmentedBarYOffset;
@property (assign, nonatomic) bool isSegmentedBarAtBottom;
@property (assign, nonatomic) CGFloat segmentedBarHeight;      // SegmentedBar 控件的高度

@property (strong, nonatomic) NSMutableArray* segViews;        // 需要切换的那些页面
@property (assign, nonatomic) BOOL isSegViewFullView;
- (UIView*)topView;

@property (strong, nonatomic) NSMutableArray* segControllers;
- (UIViewController*)topViewController;

@property (assign, nonatomic) bool canSelectWhenSelected;    // 某个按钮为选中状态时，是否仍可以响应点击事件
@property (assign, nonatomic) bool canScroll;

@property (assign, nonatomic) UIEdgeInsets contentInset;   // 边距
@property (assign, nonatomic) CGFloat intervalHorizontal;  // 控件之间水平间距
@property (assign, nonatomic) CGFloat intervalVertical;    // 控件之间垂直间距

@property (assign,nonatomic)IBOutlet id<CDZSegmentedViewDelegate> delegate;

// 更新数据，在设置好所有属性后，需要调用此方法，参数为初始时，显示第几页
- (void)updateDataWithIndex:(NSInteger)index;

// 清空数据
- (void)reset;

// 对 SegmentedBar 上按钮样式的一些订制方法
- (void)setSegButtonBackgroundImage:(UIImage*)image forState:(UIControlState)state atIndex:(NSInteger)index;
- (void)setSegButtonBackgroundImage:(UIImage*)image forState:(UIControlState)state count:(NSInteger)count; // 对前count个按钮，进行背景图片的设置
- (void)setSegButtonTitle:(NSString*)title forState:(UIControlState)state atIndex:(NSInteger)index;
- (void)setSegButtonTitleColor:(UIColor*)color forState:(UIControlState)state atIndex:(NSInteger)index;
- (void)setSegButtonTitleFont:(UIFont*)font forState:(UIControlState)state atIndex:(NSInteger)index;

// 获得第 index 个 segmented按钮，以便进行更详细的订制
- (UIButton*)segButtonAtIndex:(NSInteger)index;

- (void)update3Screens;

@end

// 使用示例
/*
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
 self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
 self.window.backgroundColor = [UIColor colorWithRed:0x80/255.0 green:0x80/255.0 blue:0x80/255.0 alpha:1];
 [self.window makeKeyAndVisible];
 
 CDZSegmentedView * segmentedView = [[CDZSegmentedView alloc]initWithFrame:CGRectMake(10, 30, 300, 300)];
 
 [segmentedView setSegButtonTitle:@"red" forState:UIControlStateNormal atIndex:0];
 [segmentedView setSegButtonTitle:@"green" forState:UIControlStateNormal atIndex:1];
 [segmentedView setSegButtonTitle:@"blue" forState:UIControlStateNormal atIndex:2];
 
 [segmentedView.SegmentedBar setBackgroundImage:[UIImage imageNamed:@"image.png"]];
 [segmentedView setSegButtonBackgroundImage:[UIImage imageNamed:@"Default.png"] forState:UIControlStateSelected count:3];
 
 UIView* view1 = [[UIView alloc]init];
 view1.backgroundColor = [UIColor redColor];
 [segmentedView.segViews addObject:view1];
 [view1 release];
 UIView* view2 = [[UIView alloc]init];
 view2.backgroundColor = [UIColor greenColor];
 [segmentedView.segViews addObject:view2];
 [view2 release];
 UIView* view3 = [[UIView alloc]init];
 view3.backgroundColor = [UIColor blueColor];
 [segmentedView.segViews addObject:view3];
 [view3 release];
 
 [segmentedView updateDataWithIndex:0];
 
 [_window addSubview:segmentedView];
 [segmentedView release];
 
 return YES;
 }
 */




/*
 CDZSegmentedBar 是一个类似于 UISegmentedControl 的控件，相比于 UISegmentedControl，此控件的自定义程度更高一些
 */

@protocol CDZSegmentedBarDelegate <NSObject>
@optional

// 当某个按钮被按下时，会调用委托此方法。若返回true，则进行正常切换，否则不切换。若委托没有此方法，则当作是返回true。参数为按钮索引
- (BOOL)shouldSwithToIndex:(NSInteger)index;

// 当某个按钮被按下、并且上边的方法返回了true时，会调用委托此方法。参数为按钮索引
- (void)segButtonClick:(NSInteger)index;

// 创建 segmentedButton，若不响应，则创建系统的UIButton
- (UIButton*)createSegmentedButton;

@end

@interface CDZSegmentedBar : UIView{
    NSMutableArray* _segButtons;  // 储存那些 button
    UIImageView* _bgImageView;    // 背景图片
    
    UIScrollView* _scrollView;
}
@property (assign,nonatomic) IBOutlet id<CDZSegmentedBarDelegate> delegate;
@property (assign,nonatomic) NSInteger currentPage;           // 当前显示的第几页
@property (assign,nonatomic) NSInteger segButtonCount;            // 按钮个数
@property (strong,nonatomic) UIColor* segButtonBackgroundColor;   // 按钮背景颜色
@property (strong,nonatomic) UIFont* segButtonFont;               // 按钮字体
@property (assign,nonatomic) bool canSelectWhenSelected;    // 某个按钮为选中状态时，是否仍可以响应点击事件

@property (nonatomic, assign) CGFloat segButtonMinWidth;

@property (assign, nonatomic) UIEdgeInsets contentInset;   // 边距
@property (assign, nonatomic) CGFloat intervalHorizontal;  // 控件之间水平间距
@property (assign, nonatomic) CGFloat intervalVertical;    // 控件之间垂直间距

// 更新数据，在设置好所有属性后，需要调用此方法，参数为初始时，第几个按钮为选中状态
- (void)updateViewWithIndex:(NSInteger)index;  // 显示时，展现第几个UIViewController，从0开始计算

// 清空数据
- (void)reset;

// 设置哪个按钮为选中状态，（会自动取消之前选中按钮的选中状态）
- (void)setSegButtonSelected:(NSInteger)index;
- (void)setSegButtonSelected:(NSInteger)index autoScroll:(BOOL)autoScroll;
- (void)currentButtonScrollToVisible;

// 设置背景图片
- (void)setBackgroundImage:(UIImage*)image;

// 对 SegmentedBar 上按钮样式的一些订制方法
- (void)setSegButtonBackgroundImage:(UIImage*)image forState:(UIControlState)state atIndex:(NSInteger)index;
- (void)setSegButtonBackgroundImage:(UIImage*)image forState:(UIControlState)state count:(NSInteger)count; // 对前count个按钮，进行背景图片的设置
- (void)setSegButtonTitle:(NSString*)title forState:(UIControlState)state atIndex:(NSInteger)index;
- (void)setSegButtonTitleColor:(UIColor*)color forState:(UIControlState)state atIndex:(NSInteger)index;
- (void)setSegButtonTitleFont:(UIFont*)font forState:(UIControlState)state atIndex:(NSInteger)index;

// 获得第 index 个 segmented按钮，以便进行更详细的订制
- (UIButton*)segButtonAtIndex:(NSInteger)index;


// 模拟一次按钮按下
- (void)clickButtonAtIndex:(int)index;


@end

