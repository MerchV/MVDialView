//
//  DialScrollView.h
//  CustomDials
//
//  Created by Merch Visoiu on 12-04-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class MVDialView;
@protocol MVDialViewDataSource
- (UILabel*)labelForColumn:(NSInteger)column dial:(MVDialView*)dialView;
- (UIImage*)imageForColumn:(NSInteger)column;
@end
@protocol MVDialViewDelegate <NSObject>
- (void)didSelectColumn:(NSInteger)column dial:(MVDialView*)dial;
//- (void)playClick;
@end

@interface MVDialView : UIView<UIScrollViewDelegate>
- (void)loadInitialLabel;
- (void)removeAllLabels;
- (void)moveToColumn:(NSUInteger)column;
//- (id)initWithFrame:(CGRect)frame infinite:(BOOL)isInfinite;
@property (nonatomic, strong) NSMutableArray* visibleLabels;
@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, unsafe_unretained) IBOutlet id<MVDialViewDataSource> dataSource;
@property (nonatomic, unsafe_unretained) IBOutlet id<MVDialViewDelegate> delegate;
@end
