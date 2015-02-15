//
//  DialScrollView.m
//  CustomDials
//
//  Created by Merch Visoiu on 12-04-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MVDialView.h"
#define DialHeight 44
#define DialWidth 320
#define NameLabelSpacing 10
#define ColorUnhighlighted [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]
#define ColorUnhighlightedShadow [UIColor lightTextColor]
#define ColorHighlighted [UIColor blueColor]
#define ColorHighlightedShadow [UIColor lightTextColor]


@interface InfiniteScrollView : UIScrollView
@property (nonatomic, strong) UIView* labelContainerView;
- (void)moveToCenter;
- (void)loadInitialLabel;
- (void)removeAllLabels;
@end

@implementation InfiniteScrollView

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self addSubview:self.labelContainerView];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = YES;
        self.pagingEnabled = NO; 
#define ArbitrarilyLargeDial 300000
        self.contentSize = CGSizeMake(ArbitrarilyLargeDial, DialHeight);
    }
    return self;
}
- (UIView*)labelContainerView {
    if(!_labelContainerView) {
        _labelContainerView = [[UIView alloc] init];        
        _labelContainerView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height/2);
        [_labelContainerView setUserInteractionEnabled:YES];
    }
    return _labelContainerView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self moveToCenter];
    MVDialView* dialView = (MVDialView*)self.superview;
    if(dialView.visibleLabels && dialView.visibleLabels.count) {
        UILabel* leftmostNameLabel = [dialView.visibleLabels objectAtIndex:0];
        UILabel* rightmostNameLabel = [dialView.visibleLabels lastObject];

        CGFloat rightEdge = CGRectGetMaxX(rightmostNameLabel.frame);
        CGFloat rightScrollViewEdge = self.contentOffset.x + self.bounds.size.width;
        NSInteger rightTag = rightmostNameLabel.tag;
        while(rightEdge < rightScrollViewEdge) {
            UILabel* newRightLabel = [dialView.dataSource labelForColumn:++rightTag dial:dialView];
            if(newRightLabel) {
                CGSize nameStringSize = [newRightLabel.text sizeWithFont:newRightLabel.font];
                newRightLabel.frame = CGRectMake(rightEdge, 0, nameStringSize.width+(2*NameLabelSpacing), DialHeight);
                newRightLabel.textAlignment = NSTextAlignmentCenter;
                [self.labelContainerView addSubview:newRightLabel];
                [dialView.visibleLabels addObject:newRightLabel];
                rightEdge = CGRectGetMaxX(newRightLabel.frame);
            }
        }

        CGFloat leftEdge = CGRectGetMinX(leftmostNameLabel.frame);
        CGFloat leftScrollViewEdge = self.contentOffset.x;
        NSInteger leftTag = leftmostNameLabel.tag;
        while(leftEdge > leftScrollViewEdge) {
            UILabel* newLeftLabel = [dialView.dataSource labelForColumn:--leftTag dial:dialView];
            if(newLeftLabel) {
                CGSize nameStringSize = [newLeftLabel.text sizeWithFont:newLeftLabel.font];
                newLeftLabel.frame = CGRectMake(leftEdge-nameStringSize.width-(2*NameLabelSpacing), 0, nameStringSize.width+(2*NameLabelSpacing), DialHeight);
                newLeftLabel.textAlignment = NSTextAlignmentCenter;
                [self.labelContainerView addSubview:newLeftLabel];
                [dialView.visibleLabels insertObject:newLeftLabel atIndex:0];
                leftEdge = CGRectGetMinX(newLeftLabel.frame);
            }
        }

        // remove labels that have fallen off right edge
        UILabel *lastLabel = [dialView.visibleLabels lastObject];
        while ([lastLabel frame].origin.x > rightScrollViewEdge) {
            [lastLabel removeFromSuperview];
            [dialView.visibleLabels removeLastObject];
            lastLabel = [dialView.visibleLabels lastObject];
        }

        // remove labels that have fallen off left edge
        UILabel *firstLabel = [dialView.visibleLabels objectAtIndex:0];
        while (CGRectGetMaxX([firstLabel frame]) < leftScrollViewEdge) {
            [firstLabel removeFromSuperview];
            [dialView.visibleLabels removeObjectAtIndex:0];
            firstLabel = [dialView.visibleLabels objectAtIndex:0];
        }        
    }
}

- (void)moveToCenter {
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentWidth = [self contentSize].width;
    CGFloat centerOffsetX = ((contentWidth / 2.0) - (self.bounds.size.width/2));
    CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
    if(distanceFromCenter > (contentWidth / 4.0)) {
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        MVDialView* dialView = (MVDialView*)self.superview;
        for(UILabel* label in dialView.visibleLabels) {
            CGPoint center = [self.labelContainerView convertPoint:label.center toView:self];
            center.x += (centerOffsetX - currentOffset.x);
            label.center = [self convertPoint:center toView:self.labelContainerView];
        }
    }
}

- (void)loadInitialLabel {
    MVDialView* dialView = (MVDialView*)self.superview;
    UILabel* label = [dialView.dataSource labelForColumn:0 dial:dialView];
    CGSize labelSize = [label.text sizeWithFont:label.font];
    label.frame = CGRectMake(self.contentOffset.x+(self.bounds.size.width/2)-(labelSize.width/2)-NameLabelSpacing, 0, labelSize.width+(2*NameLabelSpacing), DialHeight);
    label.textAlignment = NSTextAlignmentCenter;
    [self.labelContainerView addSubview:label];
    [dialView.visibleLabels addObject:label];
    if([label.text isEqualToString:@"Any"]) {
        label.textColor = ColorUnhighlighted;
        label.shadowColor = ColorUnhighlightedShadow;
    } else {
        label.textColor = ColorHighlighted;
        label.shadowColor = ColorHighlightedShadow;
        [self setNeedsLayout];
    }

}

- (void)removeAllLabels {
    NSArray* subviews = [self.labelContainerView subviews];
    for(UILabel* label in subviews) {
        [label removeFromSuperview];
    }
}

@end

///////////////////////////////////////////////////////////////////////////////////

@interface MVDialView ()
@property (nonatomic, strong) InfiniteScrollView* infiniteScrollView;
//@property (nonatomic, assign) BOOL isInfinite;
- (void)getInitialScrollViewLabels;
- (CGFloat)getWidthOfVisibleLabels;
@end
@implementation MVDialView

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
//        self.isInfinite = isInfinite;
        self.visibleLabels = [NSMutableArray array];
        [self addSubview:self.infiniteScrollView];
        [self.infiniteScrollView moveToCenter];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
//        self.isInfinite = YES;
        self.visibleLabels = [NSMutableArray array];
        [self addSubview:self.infiniteScrollView];
        [self.infiniteScrollView moveToCenter];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (InfiniteScrollView*)infiniteScrollView {
    if(!_infiniteScrollView) {
#define GraphicalPadding 2
        _infiniteScrollView = [[InfiniteScrollView alloc] initWithFrame:CGRectMake(GraphicalPadding, 0, DialWidth-(2*GraphicalPadding), DialHeight)];
        _infiniteScrollView.delegate = self;
    }
    return _infiniteScrollView;
}

- (void)loadInitialLabel {
    [self.infiniteScrollView loadInitialLabel]; 
}

- (void)moveToColumn:(NSUInteger)column {
    UILabel* visibleLabel = self.visibleLabels[1];

//    for(UILabel* visibleLabel in self.visibleLabels) {
        NSInteger newX = visibleLabel.frame.origin.x - self.infiniteScrollView.contentOffset.x;
        CGRect newRect = CGRectMake(newX, 0, visibleLabel.bounds.size.width, visibleLabel.bounds.size.height);
        if(CGRectContainsPoint(newRect, self.infiniteScrollView.center)) {
            CGPoint newPoint = CGPointMake(visibleLabel.center.x - (self.infiniteScrollView.bounds.size.width/2), 0);
            [self.infiniteScrollView setContentOffset:newPoint animated:YES];
            //            NSInteger visibleLabelIndex = visibleLabel.tag;
            //            [self.delegate didSelectColumn:visibleLabelIndex dial:self];
        }
//    }

}

- (void)removeAllLabels {
    [self.visibleLabels removeAllObjects];
    [self.infiniteScrollView removeAllLabels];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for(UILabel* visibleLabel in self.visibleLabels) {
        NSInteger newX = visibleLabel.frame.origin.x - scrollView.contentOffset.x;
        CGRect newRect = CGRectMake(newX, 0, visibleLabel.bounds.size.width, visibleLabel.bounds.size.height);
        if(CGRectContainsPoint(newRect, scrollView.center)) {
            visibleLabel.textColor = ColorHighlighted;
            visibleLabel.shadowColor = ColorHighlightedShadow;
        } else {
            visibleLabel.textColor = ColorUnhighlighted;
            visibleLabel.shadowColor = ColorUnhighlightedShadow;
        }
    }    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    for(UILabel* visibleLabel in self.visibleLabels) {
        NSInteger newX = visibleLabel.frame.origin.x - scrollView.contentOffset.x;
        CGRect newRect = CGRectMake(newX, 0, visibleLabel.bounds.size.width, visibleLabel.bounds.size.height);
        if(CGRectContainsPoint(newRect, scrollView.center)) {
            CGPoint newPoint = CGPointMake(visibleLabel.center.x - (scrollView.bounds.size.width/2), 0);
            [scrollView setContentOffset:newPoint animated:YES];
            NSInteger visibleLabelIndex = visibleLabel.tag;
            [self.delegate didSelectColumn:visibleLabelIndex dial:self];
        }
    }    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    for(UILabel* visibleLabel in self.visibleLabels) {
        NSInteger newX = visibleLabel.frame.origin.x - scrollView.contentOffset.x;
        CGRect newRect = CGRectMake(newX, 0, visibleLabel.bounds.size.width, visibleLabel.bounds.size.height);
        if(CGRectContainsPoint(newRect, scrollView.center)) {
            CGPoint newPoint = CGPointMake(visibleLabel.center.x - (scrollView.bounds.size.width/2), 0);
            [scrollView setContentOffset:newPoint animated:YES];
            NSInteger visibleLabelIndex = visibleLabel.tag;
            [self.delegate didSelectColumn:visibleLabelIndex dial:self];
        }
    }
}

@end
