//
//  CDZTableView.m
//  
//
//  Created by baight on 14-2-10.
//  Copyright (c) 2014年 baight. All rights reserved.
//

#import "CDZSegmentedView.h"
#import <QuartzCore/QuartzCore.h>

#define Margin_Horizontal 0
#define Margin_Vertical 0
#define Interval_Horizontal 0
#define Interval_Vertical 0

#define SegmentedBar_Height 44
#define AnimationDuration 0.35


@implementation CDZSegmentedView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self myInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self myInit];
    }
    return self;
}
- (void)myInit{
    _contentInset = UIEdgeInsetsMake(Margin_Vertical, Margin_Horizontal, Margin_Vertical, Margin_Horizontal);
    _intervalHorizontal = Interval_Horizontal;
    _intervalVertical = Interval_Vertical;
    
    _segViews = [[NSMutableArray alloc] init];
    _segControllers = [[NSMutableArray alloc]init];
    
    _scrollView = [[UIScrollView alloc]init];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    
    _segmentedBar = [[CDZSegmentedBar alloc]initWithFrame:CGRectMake(Margin_Horizontal, Margin_Vertical, self.bounds.size.width, SegmentedBar_Height)];
    _segmentedBar.delegate = (id<CDZSegmentedBarDelegate>)self;
    [self addSubview:_segmentedBar];
    
    _screen0 = [[UIImageView alloc]init];
    _screen0.backgroundColor = [UIColor clearColor];
    _screen0.userInteractionEnabled = YES;
    [_scrollView addSubview:_screen0];
    
    _screen1 = [[UIImageView alloc]init];
    _screen1.backgroundColor = [UIColor clearColor];
    _screen1.userInteractionEnabled = YES;
    [_scrollView addSubview:_screen1];
    
    _screen2 = [[UIImageView alloc]init];
    _screen2.backgroundColor = [UIColor clearColor];
    _screen2.userInteractionEnabled = YES;
    [_scrollView addSubview:_screen2];
    
}

- (void)setSegButtonBackgroundImage:(UIImage*)image forState:(UIControlState)state atIndex:(NSInteger)index{
    [_segmentedBar setSegButtonBackgroundImage:image forState:state atIndex:index];
}
- (void)setSegButtonBackgroundImage:(UIImage*)image forState:(UIControlState)state count:(NSInteger)count{
    [_segmentedBar setSegButtonBackgroundImage:image forState:state count:count];
}
- (void)setSegButtonTitle:(NSString*)title forState:(UIControlState)state atIndex:(NSInteger)index{
    [_segmentedBar setSegButtonTitle:title forState:state atIndex:index];
}
- (void)setSegButtonTitleColor:(UIColor*)color forState:(UIControlState)state atIndex:(NSInteger)index{
    [_segmentedBar setSegButtonTitleColor:color forState:state atIndex:index];
}
- (void)setSegButtonTitleFont:(UIFont*)font forState:(UIControlState)state atIndex:(NSInteger)index{
    [_segmentedBar setSegButtonTitleFont:font forState:state atIndex:index];
}
- (UIButton*)segButtonAtIndex:(NSInteger)index{
    return [_segmentedBar segButtonAtIndex:index];
}
- (UIView*)topView{
    if(_currentPage >= self.segViewCount){
        return nil;
    }
    return [self segViewAtIndex:_currentPage];
}
- (UIViewController*)topViewController{
    if(_currentPage >= _segControllers.count){
        return nil;
    }
    return [_segControllers objectAtIndex:_currentPage];
}

// 子控件尺寸调整相关代码
- (CGFloat)segmentedBarHeight{
    return _segmentedBar.bounds.size.height;
}
- (void)setSegmentedBarHeight:(CGFloat)segmentedBarHeight{
    CGRect rect = _segmentedBar.frame;
    rect.size.height = segmentedBarHeight;
    _segmentedBar.frame = rect;
    [self updateSize];
}

- (void)updateSize{
    // scroll view width and height
    CGFloat width = self.bounds.size.width-_contentInset.left-_contentInset.right;
    if(width < 0){
        width = 0;
    }
    
    CGFloat scrollViewY;
    CGRect rect = _segmentedBar.frame;
    rect.origin.x = _contentInset.left;
    if(_isSegmentedBarAtBottom == true){
        rect.origin.y = self.bounds.size.height - _contentInset.bottom - rect.size.height;
        scrollViewY = _contentInset.top;
    }
    else{
        rect.origin.y = _contentInset.top;
        scrollViewY = _contentInset.top+_segmentedBar.bounds.size.height+_intervalVertical;
    }
    rect.origin.y += self.segmentedBarYOffset;
    rect.size.width = width;
    _segmentedBar.frame = rect;
    
    CGFloat height = self.bounds.size.height-_contentInset.top-_segmentedBar.bounds.size.height-_intervalVertical-_contentInset.bottom;
    if(self.isSegViewFullView){
        height += self.segmentedBar.height;
        scrollViewY = 0;
    }
    if(height < 0){
        height = 0;
    }
    _scrollView.frame = CGRectMake(_contentInset.left,scrollViewY, width, height);
    
    _scrollView.contentSize = CGSizeMake(width*3, height);  // 总共三屏数据
    _screen0.frame = CGRectMake(0, 0, width, height);
    _screen1.frame = CGRectMake(width, 0, width,height);
    _screen2.frame = CGRectMake(width*2, 0, width, height);
}
- (void)setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    [self updateSize];
    [self updateContentOffset];
}
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self updateSize];
    [self updateContentOffset];
}
- (void)updateContentOffset{
    if(_canCycleScroll){
        // 无动画滚回第二屏
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
    }
    else{
        if(_currentPage == 0){
            // 无动画滚回第一屏
            [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        }
        else if(_currentPage == self.segViewCount-1){
            // 无动画滚回第三屏
            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width*2, 0) animated:NO];
        }
        else{
            // 无动画滚回第二屏
            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
        }
    }
}

- (UIImage*)snapshootOfView:(UIView*)view{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.bounds.size.width,view.bounds.size.height), NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if([view isKindOfClass:[UIScrollView class]]){
        UIScrollView* s = (UIScrollView*)view;
        CGContextTranslateCTM(context, -s.contentOffset.x, -s.contentOffset.y);
    }
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// 根据 _currentPage 来更新三屏的数据
- (void)update3Screens{
    if(self.segViewCount == 0){
        return;
    }
    [self updateScreen0];
    [self updateScreen1];
    [self updateScreen2];
}
- (void)updateScreen0{
    // 移除所有view
    for(UIView* view in _screen0.subviews){
        [view removeFromSuperview];
    }
    _screen0.image = nil;
    if(_canCycleScroll){
        // 更新 _screen0
        UIView* view;
        if(_currentPage == 0){   // 当前页为第一页，所以第一屏数据应该为最后一页数据
            view = [self segViewAtIndex:self.segViewCount-1];
        }
        else{
            view = [self segViewAtIndex:_currentPage-1];
        }
        _screen0.image = [self snapshootOfView:view];
    }
    else{
        // 第一张
        if(_currentPage == 0){
            [_screen0 addSubview:[self segViewAtIndex:0]];
        }
        // 最后一张
        else if(_currentPage == self.segViewCount -1){
            if(self.segViewCount >= 3){
                _screen0.image = [self snapshootOfView:[self segViewAtIndex:self.segViewCount -3]];
            }
            else{
                _screen0.image = [self snapshootOfView:[self segViewAtIndex:0]];
            }
        }
        // 其它
        else{
            _screen0.image = [self snapshootOfView:[self segViewAtIndex:_currentPage-1]];
        }
    }
}
- (void)updateScreen1{
    for(UIView* view in _screen1.subviews){
        [view removeFromSuperview];
    }
    _screen1.image = nil;
    if(_canCycleScroll){
        UIView* view;
        // 更新 _screen1
        view = [self segViewAtIndex:_currentPage];
        [_screen1 addSubview:view];
    }
    else{
        // 第一张
        if(_currentPage == 0){
            if(self.segViewCount >= 2){
                _screen1.image = [self snapshootOfView:[self segViewAtIndex:1]];
            }
            else{
                _screen1.image = [self snapshootOfView:[self segViewAtIndex:0]];
            }
        }
        // 最后一张
        else if(_currentPage == self.segViewCount -1){
            if(self.segViewCount >= 2){
                _screen1.image = [self snapshootOfView:[self segViewAtIndex:self.segViewCount -2]];
            }
            else{
                _screen1.image = [self snapshootOfView:[self segViewAtIndex:0]];
            }
        }
        // 其它
        else{
            [_screen1 addSubview:[self segViewAtIndex:_currentPage]];
        }
    }
}
- (void)updateScreen2{
    for(UIView* view in _screen2.subviews){
        [view removeFromSuperview];
    }
    _screen2.image = nil;
    if(_canCycleScroll){
        UIView* view;
        // 更新 _screen2
        if(_currentPage == self.segViewCount-1){    // 当前页为最后一页，所以第三屏数据应该为第一页数据
            view = [self segViewAtIndex:0];
        }
        else{
            view = [self segViewAtIndex:_currentPage+1];
        }
        _screen2.image = [self snapshootOfView:view];
    }
    else{
        // 第一张
        if(_currentPage == 0){
            if(self.segViewCount >= 3){
                _screen2.image = [self snapshootOfView:[self segViewAtIndex:2]];
            }
            else{
                _screen2.image = [self snapshootOfView:[self segViewAtIndex:0]];
            }
        }
        // 最后一张
        else if(_currentPage == self.segViewCount -1){
            [_screen2 addSubview:[self segViewAtIndex:self.segViewCount -1]];
        }
        // 其它
        else{
            _screen2.image = [self snapshootOfView:[self segViewAtIndex:_currentPage+1]];
        }
    }
}

- (void)updateDataWithIndex:(NSInteger)index{
    if(self.segViewCount == 0){
        return;
    }

    [self updateSize];
    
    _segmentedBar.canSelectWhenSelected = _canSelectWhenSelected;
    [_segmentedBar setSegButtonCount:self.segViewCount];
    [_segmentedBar updateViewWithIndex:index];
    
    
    if(index < 0){
        index = 0;
    }
    else if(index >= self.segViewCount){
        index = self.segViewCount - 1;
    }
    
    
    
    _currentPage = index;
    _prevousPage = index;
    _nextPage = index;
    
    if([_delegate respondsToSelector:@selector(willSwithToPage:)]){
        [_delegate willSwithToPage:index];
    }
    
    if(_canCycleScroll){
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:NO];
        [_screen1 addSubview:[self segViewAtIndex:_currentPage]];
    }
    else{
        if(_currentPage == 0){
            [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        }
        else if(_currentPage == self.segViewCount-1){
            [_scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width*2, 0) animated:NO];
        }
        else{
            [_scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width, 0) animated:NO];
        }
    }
    
    // 必须延迟刷新，我们必须等xib初始化完后，才能初始化view和取得快照，不然会显示异常
    if(_canCycleScroll){
        [self updateScreen1];
        [self performSelector:@selector(updateScreen0) withObject:nil afterDelay:0.3];
        [self performSelector:@selector(updateScreen2) withObject:nil afterDelay:0.3];
    }
    else{
        // 第一页
        if(_currentPage == 0){
            [self updateScreen0];
            [self performSelector:@selector(updateScreen1) withObject:nil afterDelay:0.3];
            [self performSelector:@selector(updateScreen2) withObject:nil afterDelay:0.3];
        }
        // 最后一页
        else if(_currentPage == [self segViewCount] - 1){
            [self updateScreen2];
            [self performSelector:@selector(updateScreen0) withObject:nil afterDelay:0.3];
            [self performSelector:@selector(updateScreen1) withObject:nil afterDelay:0.3];
        }
        else{
            [self updateScreen1];
            [self performSelector:@selector(updateScreen0) withObject:nil afterDelay:0.3];
            [self performSelector:@selector(updateScreen2) withObject:nil afterDelay:0.3];
        }
    }
}
// 清空数据
- (void)reset{
    [self.segmentedBar reset];
    
    for(UIView* v in self.segViews){
        [v removeFromSuperview];
    }
    [self.segViews removeAllObjects];
    
    _screen0.image = nil;
    _screen1.image = nil;
    _screen2.image = nil;
}

- (void)setCanScroll:(bool)canScroll{
    _canScroll = canScroll;
    _scrollView.scrollEnabled = _canScroll;
}

#pragma mark - CDZSegmentedBar Delegate
- (void)segButtonClick:(NSInteger)index{
    if(index == _currentPage){
        if([_delegate respondsToSelector:@selector(didClickSegButtonAgain:)]){
            [_delegate didClickSegButtonAgain:index];
        }
        return;
    }
    
    if([_delegate respondsToSelector:@selector(segmentedView:willSwitchToPage:)]){
        [_delegate segmentedView:self willSwitchToPage:index];
    }
    
    if(index > _currentPage){  // 在右边
        if(_canCycleScroll == YES){
            _screen2.image = [self snapshootOfView:[self segViewAtIndex:index]];
            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width*2, 0) animated:YES];
        }
        else{
            if(_currentPage == 0){
                _screen1.image = [self snapshootOfView:[self segViewAtIndex:index]];
                [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
            }
            else{
                _screen2.image = [self snapshootOfView:[self segViewAtIndex:index]];
                [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width*2, 0) animated:YES];
            }
            
        }
    }
    else { // 在左边
        if(_canCycleScroll){
            _screen0.image = [self snapshootOfView:[self segViewAtIndex:index]];
            [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        else{
            if(_currentPage == self.segViewCount-1){
                _screen1.image = [self snapshootOfView:[self segViewAtIndex:index]];
                [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
            }
            else{
                _screen0.image = [self snapshootOfView:[self segViewAtIndex:index]];
                [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
        }
    }
    _currentPage = index;
}

- (UIView*)segViewAtIndex:(NSInteger)index{
    if(index >= _segViews.count){
        if(index >= _segControllers.count){
            return nil;
        }
        else{
            UIView* v = [[_segControllers objectAtIndex:index] view];
            v.frame = CGRectMake(0, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
            return v;
        }
    }
    else{
        UIView* v = [_segViews objectAtIndex:index];
        v.frame = CGRectMake(0, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
        return v;
    }
}

- (NSInteger)segViewCount{
    if(_segViews.count == 0){
        return _segControllers.count;
    }
    else{
        return _segViews.count;
    }
}

#pragma mark - UIScrollViewDelegate
// 动画停止
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    scrollView.userInteractionEnabled = YES;
    [self update3Screens];
    _prevousPage = _currentPage;
    [self updateContentOffset];
    
    if([_delegate respondsToSelector:@selector(segmentedView:didSwitchToPage:)]){
        [_delegate segmentedView:self didSwitchToPage:_currentPage];
    }
}

// 手动拖动跳转并跳转动画结束后，会调用此方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    scrollView.userInteractionEnabled = YES;
    if(self.segViewCount == 0){
        return;
    }
    
    if(scrollView.contentOffset.x < scrollView.bounds.size.width/2){  // 在第一屏
        _currentPage--;
        if(_currentPage < 0){
            if(_canCycleScroll){
                _currentPage = self.segViewCount-1;
            }
            else{
                _currentPage = 0;
            }
        }
    }
    else if(scrollView.contentOffset.x > scrollView.bounds.size.width*1.5){   // 在第三屏
        _currentPage++;
        if(_currentPage >= self.segViewCount){
            if(_canCycleScroll){
                _currentPage = 0;
            }
            else{
                _currentPage = self.segViewCount-1;
            }
        }
    }
    // 在第二屏
    else{
        if(!_canCycleScroll){
            if(_currentPage == 0){
                _currentPage++;
            }
            else if(_currentPage == self.segViewCount -1){
                _currentPage--;
            }
        }
    }
    if(_prevousPage == _currentPage){  // 当前页没有改变
        return;
    }
    
    [self update3Screens];
    [self updateContentOffset];
    
    
    _prevousPage = _currentPage;

    
    [_segmentedBar setSegButtonSelected:_currentPage autoScroll:YES];

    if([_delegate respondsToSelector:@selector(segmentedView:didSwitchToPage:)]){
        [_delegate segmentedView:self didSwitchToPage:_currentPage];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 只有在拖动时，才会实时调整 _pageControl.currentPage
    if(_scrollView.isDragging == false){
        return;
    }
    NSInteger page = _currentPage;
    // 实时调整 _pageControl.currentPage
    if(_canCycleScroll){
        if(scrollView.contentOffset.x < scrollView.bounds.size.width/2){  // 在第一屏
            page = _currentPage-1;
        }
        else if(scrollView.contentOffset.x > scrollView.bounds.size.width*1.5){   // 在第三屏
            page = _currentPage+1;
        }
        if(page < 0){
            page = self.segViewCount-1;
        }
        else if(page >= self.segViewCount){
            page = 0;
        }
    }
    else{
        if(scrollView.contentOffset.x < scrollView.bounds.size.width/2){  // 在第一屏
            if(_currentPage == 0){
                page = _currentPage;
            }
            else{
                page = _currentPage-1;
            }
            
        }
        else if(scrollView.contentOffset.x > scrollView.bounds.size.width*1.5){   // 在第三屏
            if(_currentPage == self.segViewCount-1){
                page = _currentPage;
            }
            else{
                page = _currentPage+1;
            }
        }
        else{  // 第二屏
            if(_currentPage == 0){
                page = _currentPage+1;
            }
            else if(_currentPage == self.segViewCount-1){
                page = _currentPage-1;
            }
        }
    }
    
    if(page != _nextPage){
        _nextPage = page;
        if([_delegate respondsToSelector:@selector(willSwithToPage:)]){
            [_delegate willSwithToPage:page];
        }
    }
    
    [_segmentedBar setSegButtonSelected:page autoScroll:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    scrollView.userInteractionEnabled = NO;
    if([_delegate respondsToSelector:@selector(beginDraggingInPage:)]){
        [_delegate beginDraggingInPage:_currentPage];
    }
    
    NSInteger willSwitchtoPage = _currentPage;
    CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView.panGestureRecognizer.view];
    if(velocity.x < 0){  // 向右划
        willSwitchtoPage++;
    }
    else{
        willSwitchtoPage--;
    }
    
    if(_canCycleScroll){
        if(willSwitchtoPage < 0){
            willSwitchtoPage = self.segViewCount-1;
        }
        else if(willSwitchtoPage == self.segViewCount){
            willSwitchtoPage = 0;
        }
    }
    
    if(willSwitchtoPage >=0 && willSwitchtoPage < self.segViewCount){
        if(_currentPage != willSwitchtoPage){
            if([_delegate respondsToSelector:@selector(segmentedView:willSwitchToPage:)]){
                [_delegate segmentedView:self willSwitchToPage:willSwitchtoPage];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        [self scrollViewDidEndDecelerating:scrollView];
    }

}

@end
















#define NavigationBar_Color [UIColor clearColor]
#define NavigationBar_Font [UIFont systemFontOfSize:15];

#define SegmentedButton_Color [UIColor clearColor]
#define SegmentedButton_TitleNormalColor [UIColor lightGrayColor]
#define SegmentedButton_TitleHighLightedColor [UIColor blackColor]

#define SegmentedBar_Margin_Horizontal 0
#define SegmentedBar_Margin_Vertical 0
#define SegmentedBar_Interval_Horizontal 0
#define SegmentedBar_Interval_Vertical 0

@implementation CDZSegmentedBar
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self myInit];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self myInit];
    }
    return self;
}
- (void)myInit{
    _bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    _bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:_bgImageView];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:_scrollView];
    
    _contentInset = UIEdgeInsetsMake(SegmentedBar_Margin_Vertical, SegmentedBar_Margin_Horizontal, SegmentedBar_Margin_Vertical, SegmentedBar_Margin_Horizontal);
    _intervalHorizontal = SegmentedBar_Interval_Horizontal;
    _intervalVertical = SegmentedBar_Interval_Vertical;
	
	_segButtons = [[NSMutableArray alloc]init];
    
	_segButtonBackgroundColor = SegmentedButton_Color;
	_segButtonFont = NavigationBar_Font;
    _currentPage = -1;
}
- (void)setCurrentPage:(NSInteger)currentPage{
    if(_currentPage == currentPage){
        return;
    }
    if(currentPage >= _segButtons.count){
        return;
    }
    int i = 0;
    for(UIButton* btn in _segButtons){
        if(i == currentPage){
            btn.selected = YES;
            if(_canSelectWhenSelected){
                btn.userInteractionEnabled = YES;
            }
            else{
                btn.userInteractionEnabled = NO;
            }
        }
        else{
            btn.selected = NO;
            btn.userInteractionEnabled = YES;
        }
        i++;
    }
    _currentPage = currentPage;
}

// 模拟一次按钮按下
- (void)clickButtonAtIndex:(int)index{
    UIButton* button = [self segButtonAtIndex:index];
    [self segButtonTouchUp:button];
}

// 创建 count 个按钮放在 _segButtons 数组中
- (void)createSegButtons:(NSInteger)count{
	while(_segButtons.count < count){
        UIButton* button = nil;
        if([_delegate respondsToSelector:@selector(createSegmentedButton)]){
            button = [_delegate createSegmentedButton];
        }
        if(button == nil){
            button = [[UIButton alloc]init];
        }
		[_segButtons addObject:button];
		button.adjustsImageWhenHighlighted = YES;
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
		[button setTitleColor:SegmentedButton_TitleNormalColor forState:UIControlStateNormal];
		[button setTitleColor:SegmentedButton_TitleHighLightedColor forState:UIControlStateHighlighted];
		[button setTitleColor:SegmentedButton_TitleHighLightedColor forState:UIControlStateSelected];
		[button addTarget:self action:@selector(segButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
		[_scrollView addSubview:button];
	}
}
- (void)segButtonTouchUp:(UIButton*)button{
    if([_delegate respondsToSelector:@selector(shouldSwithToIndex:)]){
        if([_delegate shouldSwithToIndex:[_segButtons indexOfObject:button]] == FALSE){
            return;
        };
    }
    
    if([_delegate respondsToSelector:@selector(segButtonClick:)]){
        [_delegate segButtonClick:[_segButtons indexOfObject:button]];
    }
    
    [self setSegButtonSelected:[_segButtons indexOfObject:button]];
}
- (void)setSegButtonSelected:(NSInteger)index{
    [self setSegButtonSelected:index autoScroll:YES];
}

- (void)setSegButtonSelected:(NSInteger)index autoScroll:(BOOL)autoScroll{
    if (index>=_segButtons.count || index < 0) {
        return;
    }
    for(UIButton* btn in _segButtons){
        btn.selected = NO;
        btn.userInteractionEnabled = YES;
    }
    UIButton* button = [_segButtons objectAtIndex:index];
    button.selected = YES;
    if(!_canSelectWhenSelected){
        button.userInteractionEnabled = NO;
    }
    
    _currentPage = [_segButtons indexOfObject:button];
    
    if(autoScroll){
        [self currentButtonScrollToVisible];
    }
}
- (void)currentButtonScrollToVisible{
    if(_scrollView.contentSize.width <= _scrollView.bounds.size.width){
        return;
    }
    UIButton* button = [_segButtons objectAtIndex:_currentPage];
    
    // 进行位置检查
#define SafeRate 0.6
    CGFloat safeX = _scrollView.contentOffset.x + self.bounds.size.width*(1 - SafeRate)/2;
    CGRect safeRect = CGRectMake(safeX, 0,
                                 self.bounds.size.width*SafeRate, self.bounds.size.height);
    // 在目标区域左边
    if(button.frame.origin.x < safeRect.origin.x){
        [_scrollView setContentOffset:
         CGPointMake(MAX(_scrollView.contentOffset.x - (safeRect.origin.x - button.frame.origin.x), 0), _scrollView.contentOffset.y) animated:YES] ;
    }
    // 在目标区域右边
    else if(button.frame.origin.x + button.bounds.size.width >
            safeRect.origin.x + safeRect.size.width){
        [_scrollView setContentOffset:
         CGPointMake(MIN(_scrollView.contentOffset.x + (button.frame.origin.x + button.bounds.size.width) - (safeRect.origin.x + safeRect.size.width) , _scrollView.contentSize.width - _scrollView.bounds.size.width), _scrollView.contentOffset.y) animated:YES] ;
    }
}

- (void)setBackgroundImage:(UIImage*)image{
    _bgImageView.image = image;
}

- (void)setSegButtonBackgroundImage:(UIImage*)image forState:(UIControlState)state atIndex:(NSInteger)index{
	[self createSegButtons:index+1];
	UIButton* button = [_segButtons objectAtIndex:index];
	[button setBackgroundImage:image forState:state];
}
- (void)setSegButtonBackgroundImage:(UIImage*)image forState:(UIControlState)state count:(NSInteger)count{
    [self createSegButtons:count];
    for(UIButton* button in _segButtons){
        [button setBackgroundImage:image forState:state];
    }
}
- (void)setSegButtonTitle:(NSString*)title forState:(UIControlState)state atIndex:(NSInteger)index{
	[self createSegButtons:index+1];
	UIButton* button = [_segButtons objectAtIndex:index];
	[button setTitle:title forState:state];
}
- (void)setSegButtonTitleColor:(UIColor*)color forState:(UIControlState)state atIndex:(NSInteger)index{
	[self createSegButtons:index+1];
	UIButton* button = [_segButtons objectAtIndex:index];
	[button setTitleColor:color forState:state];
}
- (void)setSegButtonTitleFont:(UIFont*)font forState:(UIControlState)state atIndex:(NSInteger)index{
    [self createSegButtons:index+1];
    UIButton* button = [_segButtons objectAtIndex:index];
    button.titleLabel.font = font;
}
// 获得第 index 个 segmented按钮
- (UIButton*)segButtonAtIndex:(NSInteger)index{
    if(index<0){
        return nil;
    }
	[self createSegButtons:index+1];
	return [_segButtons objectAtIndex:index];
}
- (void)setSegButtonCount:(NSInteger)segButtonCount{
    if(segButtonCount == 0){
        return;
    }
    while(_segButtons.count > segButtonCount){
        [[_segButtons lastObject] removeFromSuperview];
        [_segButtons removeLastObject];
    }
    [self createSegButtons:segButtonCount];
	CGFloat buttonWith = (self.bounds.size.width-_contentInset.left-_contentInset.right-_intervalHorizontal*(_segButtons.count-1))/_segButtons.count;
    if(self.segButtonMinWidth != 0 && buttonWith < self.segButtonMinWidth){
        buttonWith = self.segButtonMinWidth;
    }
    UIButton* button = nil;
	for(int i=0;i<_segButtons.count;i++){
		button = [_segButtons objectAtIndex:i];
		button.tag = i;
		button.frame = CGRectMake(_contentInset.left+i*(buttonWith+_intervalHorizontal),_contentInset.top,buttonWith,self.bounds.size.height-_contentInset.top-_contentInset.bottom);
	}
    _scrollView.contentSize = CGSizeMake(button.frame.origin.x + button.frame.size.width + _contentInset.right, _scrollView.bounds.size.height);
}
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self setSegButtonCount:_segButtons.count];
}
- (void)setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    [self setSegButtonCount:_segButtons.count];
}
- (NSInteger)segButtonCount{
    return _segButtons.count;
}

- (void)updateViewWithIndex:(NSInteger)index{
    if(_segButtons.count == 0){
        return;
    }
	if(index < 0){
        index = 0;
    }
    else if(index >= _segButtons.count){
        index = _segButtons.count-1;
    }
    
    UIButton* button = [_segButtons objectAtIndex:index];
    button.selected = YES;
    _currentPage = index;
    if(!_canSelectWhenSelected){
        button.userInteractionEnabled = NO;
    }
}

// 清空数据
- (void)reset{
    for(UIButton* b in _segButtons){
        [b removeFromSuperview];
    }
    [_segButtons removeAllObjects];
}

@end
