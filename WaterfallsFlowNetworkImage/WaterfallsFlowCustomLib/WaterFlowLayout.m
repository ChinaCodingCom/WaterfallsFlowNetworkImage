//
//  WaterFlowLayout.m
//  Gray_main
//
//  Created by CE on 15/10/20.
//  Copyright © 2015年 CE. All rights reserved.
//

#import "WaterFlowLayout.h"

#define preloadHeight 100               //豫加载上下各100
@interface WaterFlowLayout ()

//用于计算frame
@property (nonatomic, assign) NSInteger lineNum;                            ///< 列数
@property (nonatomic, assign) NSInteger eachLineWidth;                      ///< 每列宽度，现平均，以后再扩展
@property (nonatomic, assign) CGFloat horizontalSpace;                      ///< 水平间距
@property (nonatomic, assign) CGFloat verticalSpace;                        ///< 竖直间距
@property (nonatomic, assign) UIEdgeInsets edgeInset;                       ///< 边距

//所有frame
@property (nonatomic, strong) NSMutableArray<NSValue *> *rectArray;                                     ///< 保存每个Frame值
@property (nonatomic, strong) NSMutableArray<NSValue *> *eachLineLastRectArray;                         ///< 每列的最后一个rect
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *visibleAttributes;    ///< 可见Attributes

@end

//有四个必须改写项：collectionViewContentSize、layoutAttributesForElementsInRect、layoutAttributesForItemAtIndexPath:、shouldInvalidateLayoutForBoundsChange
@implementation WaterFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    //水平间距
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        _horizontalSpace = [_delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:0];
    }

    //竖直间距
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        _verticalSpace = [_delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:0];
    }

    //边距
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        _edgeInset = [_delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:0];
    }
    
    //列数
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:numberOfLineForSection:)]) {
        NSInteger lineNum = [_delegate collectionView:self.collectionView numberOfLineForSection:0];
        _lineNum = lineNum;
    }
    
    //每列宽度
    _eachLineWidth = (self.collectionView.frame.size.width - _edgeInset.left - _edgeInset.right - MAX(0, _lineNum - 1) * _verticalSpace)/_lineNum;
    
    //初始化
    self.rectArray = [NSMutableArray array];
    self.eachLineLastRectArray = [NSMutableArray array];
    
    //计算rects，并把所有item的frame存起来
    NSInteger count = 0;
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
        count = [_delegate collectionView:self.collectionView numberOfItemsInSection:0];
    }
    
    for (NSInteger i = 0; i < count; i++) {
        CGSize size = CGSizeZero;
        if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
            size = [_delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        [self caculateLowestRectAppendToRectArrayAndEachLineLastRectArray:size];
    }
}

#pragma mark - ==========================四大需要重写项=========================
- (CGSize)collectionViewContentSize {
    CGRect highest = [self caculateHighestRect];
    return CGSizeMake(self.collectionView.frame.size.width, CGRectGetMaxY(highest) + _edgeInset.bottom);
}

/**
 *  只加载rect内部分Attributes，确保低内存
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *visibleIndexPaths = [self indexPathsOfItemsInRect:rect];
    self.visibleAttributes = [NSMutableArray array];
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        [_visibleAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return _visibleAttributes;
}

/**
 *  从rectArray中取对应path的rect赋值。
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes =
    [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGRect rect = [_rectArray[indexPath.item] CGRectValue];
    attributes.frame = rect;
    return attributes;
}

/**
 *  是否应该刷新layout(理想状态是豫加载上一屏和下一屏，这样就可以避免频繁刷新，加载过多会导致内存过大，具体多远由preloadHeight控制)
 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
#warning 这里直接拿第一个和最后一个计算其实不精确，以后再改进
    CGFloat startY = CGRectGetMaxY([[_visibleAttributes firstObject] frame]);
    CGFloat endY = CGRectGetMinY([[_visibleAttributes lastObject] frame]);
    CGFloat offsetY = self.collectionView.contentOffset.y;
    if (startY + preloadHeight >= offsetY ||
        endY - preloadHeight <= offsetY + self.collectionView.frame.size.height) {
        return YES;
    }
    return NO;
}

#pragma mark - ==================其它====================
//计算最低rect，并把最低rect添加进rectArray和eachLineLastRectArray
- (void)caculateLowestRectAppendToRectArrayAndEachLineLastRectArray:(CGSize)newSize {
    CGRect newRect;
    
    if (_rectArray.count < _lineNum) {
        newRect = CGRectMake(_rectArray.count * (_eachLineWidth + _horizontalSpace) + _edgeInset.left, _edgeInset.top, _eachLineWidth, newSize.height);
        [_eachLineLastRectArray addObject:[NSValue valueWithCGRect:newRect]];
    }
    else {
        CGRect lowestRect = [[_eachLineLastRectArray firstObject] CGRectValue];
        NSInteger lowestIndex = 0;
        for (NSInteger i = 0; i < _eachLineLastRectArray.count; i++) {
            CGRect curruntRect = [_eachLineLastRectArray[i] CGRectValue];
            if (CGRectGetMaxY(curruntRect) < CGRectGetMaxY(lowestRect)) {
                lowestRect = curruntRect;
                lowestIndex = i;
            }
        }
        newRect = CGRectMake(lowestRect.origin.x, CGRectGetMaxY(lowestRect) + _verticalSpace, _eachLineWidth, newSize.height);
        [_eachLineLastRectArray replaceObjectAtIndex:lowestIndex withObject:[NSValue valueWithCGRect:newRect]];
    }
    [_rectArray addObject:[NSValue valueWithCGRect:newRect]];
}

//计算最高rect，用来调整contentSize
- (CGRect)caculateHighestRect {
    if (_rectArray.count < _lineNum) {
        CGRect newRect = CGRectMake(_rectArray.count * (_eachLineWidth + _horizontalSpace) + _edgeInset.left, _edgeInset.top, _eachLineWidth, 0);
        return newRect;
    }
    else {
        CGRect highestRect = [_rectArray[_rectArray.count - _lineNum] CGRectValue];
        for (NSInteger i = _rectArray.count - _lineNum; i < _rectArray.count; i++) {
            CGRect curruntRect = [_rectArray[i] CGRectValue];
            if (CGRectGetMaxY(curruntRect) > CGRectGetMaxY(highestRect)) {
                highestRect = curruntRect;
            }
        }
        return highestRect;
    }
}

//当前应该显示到屏幕上的items
- (NSArray *)indexPathsOfItemsInRect:(CGRect)rect {
    CGFloat startY = self.collectionView.contentOffset.y;
    CGFloat endY = startY + self.collectionView.frame.size.height;
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger i = 0; i < _rectArray.count; i++) {
        CGRect rect = [_rectArray[i] CGRectValue];
        if ((CGRectGetMaxY(rect) >= startY &&
             CGRectGetMaxY(rect) <= endY ) ||
            (CGRectGetMinY(rect) >= startY &&
             CGRectGetMinY(rect) <= endY )) {
                [items addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }
    }
    return items;
}

@end
