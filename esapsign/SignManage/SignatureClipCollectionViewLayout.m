//
//  SignatureClipCollectionViewLayout.m
//  esapsign
//
//  Created by Suzic on 14-8-28.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SignatureClipCollectionViewLayout.h"

#define ITEMWIDTH 140
#define ITEMHEIGHT 52

#define ITEMSPACE 10
#define ITEMPadding 6

@implementation SignatureClipCollectionViewLayout
{
    int cellCount;
}

/**
 *  @abstract 初始化过程
 */
- (void)prepareLayout
{
    //得到数量
    cellCount = [self.collectionView numberOfItemsInSection:0];
}

/**
 *  @abstract 得到collectionView的内容的ContentSize(UICollectionView继承自UIScrollView)
 */
- (CGSize)collectionViewContentSize
{
    CGFloat width = cellCount > 0 ? cellCount * ITEMWIDTH + ITEMSPACE * (cellCount -1) + 2 * ITEMPadding : 0;
    return width > self.collectionView.frame.size.width ? CGSizeMake(width, 52): self.collectionView.frame.size;
}

/**
 *  @abstract 返回Attribute
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attrs = [[NSMutableArray alloc] init];
    CGFloat width = cellCount * ITEMWIDTH + ITEMSPACE * (cellCount -1) + 2 * ITEMPadding;
    CGSize size = CGSizeMake(ITEMWIDTH, ITEMHEIGHT);
    
    CGFloat xpos = width > self.collectionView.frame.size.width ? width - ITEMPadding : self.collectionView.frame.size.width - ITEMPadding;
    
    for (int i = 0; i < cellCount;  i ++)
    {
        CGRect frame = CGRectZero;
        frame.size = size;
        frame.origin.y = 0;
        frame.origin.x = xpos - ITEMWIDTH;
        xpos -= ITEMSPACE + ITEMWIDTH;
        
        // if (CGRectIntersectsRect(rect, frame)) {
        // //生成attribute并添加到arr中
        // NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        // UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        // attr.frame = frame;
        // [attrs addObject:attr];
        // }
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:cellCount - i -1 inSection:0];
        UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attr.frame = frame;
        [attrs addObject:attr];
    }
    return attrs;
}

/**
 *  @abstract 在collectionView边界改变的时候，是否会触发重新layout
 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
