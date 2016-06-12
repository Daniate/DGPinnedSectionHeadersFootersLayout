//
//  DGPinnedSectionHeadersFootersLayout.m
//  DGPinnedSectionHeadersFootersLayout
//
//  Created by Daniate on 16/4/23.
//  Copyright © 2016年 Daniate. All rights reserved.
//

#import "DGPinnedSectionHeadersFootersLayout.h"

// On iOS 9, Apple's default implementations use 10 for pinned section headers' and footers' layout attributes zIndex, I copy it.
#define kDGPinnedSectionHeadersFootersLayoutZIndex (10)

@implementation DGPinnedSectionHeadersFootersLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        [self pin];
    }
    return self;
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self pin];
    }
    return self;
}

- (void)pin {
    self.pinnedSectionHeaders = self.pinnedSectionFooters = YES;
}

- (void)setPinnedSectionHeaders:(BOOL)pinnedSectionHeaders {
#ifdef __IPHONE_9_0
    if ([[UIDevice currentDevice].systemVersion compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending) {
        [super setSectionHeadersPinToVisibleBounds:pinnedSectionHeaders];
    } else {
#endif
        [self invalidateLayout];
#ifdef __IPHONE_9_0
    }
#endif
    _pinnedSectionHeaders = pinnedSectionHeaders;
}
- (void)setPinnedSectionFooters:(BOOL)pinnedSectionFooters {
#ifdef __IPHONE_9_0
    if ([[UIDevice currentDevice].systemVersion compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending) {
        [super setSectionFootersPinToVisibleBounds:pinnedSectionFooters];
    } else {
#endif
        [self invalidateLayout];
#ifdef __IPHONE_9_0
    }
#endif
    _pinnedSectionFooters = pinnedSectionFooters;
}

#pragma mark - Override
#ifdef __IPHONE_9_0
- (void)setSectionHeadersPinToVisibleBounds:(BOOL)sectionHeadersPinToVisibleBounds {
    [super setSectionHeadersPinToVisibleBounds:sectionHeadersPinToVisibleBounds];
    _pinnedSectionHeaders = sectionHeadersPinToVisibleBounds;
}

- (void)setSectionFootersPinToVisibleBounds:(BOOL)sectionFootersPinToVisibleBounds {
    [super setSectionFootersPinToVisibleBounds:sectionFootersPinToVisibleBounds];
    _pinnedSectionFooters = sectionFootersPinToVisibleBounds;
}
#endif

#if __ENVIRONMENT_IPHONE_OS_VERSION_MIN_REQUIRED__ < 90000
- (void)prepareLayout {
    [super prepareLayout];
    
    // fix iOS 6 bug: can scroll vertical and horizontal simultaneously
    if ([[UIDevice currentDevice].systemVersion compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending) {
        self.collectionView.directionalLockEnabled = YES;
        BOOL show = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal);
        self.collectionView.showsHorizontalScrollIndicator = show;
        self.collectionView.showsVerticalScrollIndicator = !show;
    }
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    // pin headers & footers
    NSArray<__kindof UICollectionViewLayoutAttributes *> *superAttrsList = [super layoutAttributesForElementsInRect:rect];
    // If system version is less than 9.0, use custom implementations; otherwise, use Apple's implementations
    if ([[UIDevice currentDevice].systemVersion compare:@"9.0" options:NSNumericSearch] == NSOrderedAscending) {
        if (self.pinnedSectionHeaders || self.pinnedSectionFooters) {
            NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *attrsList = [superAttrsList mutableCopy];
            if (self.pinnedSectionHeaders) {
                [self pinSectionHeaders:attrsList];
            }
            if (self.pinnedSectionFooters) {
                [self pinSectionFooters:attrsList];
            }
            return attrsList;
        }
    }
    return superAttrsList;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}
#pragma mark - Private
/**
 *  查找已消失的setion header/footer所对应的section
 *
 *  @param attributesList 现有的layout attributes list
 *  @param elementKind    UICollectionElementKindSectionHeader/UICollectionElementKindSectionFooter
 *
 *  @return 存放已消失的section
 */
- (NSIndexSet *)findDisappearedSections:(NSArray<__kindof UICollectionViewLayoutAttributes *> *)attributesList supplementaryViewOfKind:(NSString *)elementKind {
    NSMutableIndexSet *disappearedSections = [NSMutableIndexSet indexSet];
    // 根据当前显示的cell，将section添加到index set中
    for (UICollectionViewLayoutAttributes *attributes in attributesList) {
        if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
            [disappearedSections addIndex:attributes.indexPath.section];
        }
    }
    // 移除未消失的section header/footer所对应的section
    for (UICollectionViewLayoutAttributes *attributes in attributesList) {
        if ([attributes.representedElementKind isEqualToString:elementKind]) {
            [disappearedSections removeIndex:attributes.indexPath.section];
        }
    }
    return disappearedSections;
}

/**
 *  将已消失的section header/footer所对应的layout attributes添加到现有的layout attributes list中
 *
 *  @param attributesList 现有的layout attributes list
 *  @param indexSet       已消失的setion header/footer所对应的section
 *  @param elementKind    UICollectionElementKindSectionHeader/UICollectionElementKindSectionFooter
 */
- (void)addDisappearedAttributesToList:(inout NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *)attributesList indexSet:(NSIndexSet *)indexSet supplementaryViewOfKind:(NSString *)elementKind {
    __typeof(&*self) __weak zelf = self;
    [indexSet enumerateIndexesWithOptions:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *idxPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        UICollectionViewLayoutAttributes *attributes = [zelf layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:idxPath];
        if (attributes) {
            if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                if (attributes.frame.size.height > DBL_EPSILON) {
                    [attributesList addObject:attributes];
                }
            } else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                if (attributes.frame.size.width > DBL_EPSILON) {
                    [attributesList addObject:attributes];
                }
            }
        }
    }];
}
/**
 *  修正section headers
 *
 *  @param attributesList layout attributes list
 */
- (void)pinSectionHeaders:(inout NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *)attributesList {
    NSIndexSet *indexSet = [self findDisappearedSections:attributesList supplementaryViewOfKind:UICollectionElementKindSectionHeader];
    [self addDisappearedAttributesToList:attributesList indexSet:indexSet supplementaryViewOfKind:UICollectionElementKindSectionHeader];
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        [self pinVerticalSectionHeaders:attributesList];
    } else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        [self pinHorizontalSectionHeaders:attributesList];
    }
}
/**
 *  修正section footers
 *
 *  @param attributesList layout attributes list
 */
- (void)pinSectionFooters:(inout NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *)attributesList {
    NSIndexSet *indexSet = [self findDisappearedSections:attributesList supplementaryViewOfKind:UICollectionElementKindSectionFooter];
    [self addDisappearedAttributesToList:attributesList indexSet:indexSet supplementaryViewOfKind:UICollectionElementKindSectionFooter];
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        [self pinVerticalSectionFooters:attributesList];
    } else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        [self pinHorizontalSectionFooters:attributesList];
    }
}
/**
 *  修正竖直滚动方向上的section headers
 *
 *  @param attributesList layout attributes list
 */
- (void)pinVerticalSectionHeaders:(inout NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *)attributesList {
    for (UICollectionViewLayoutAttributes *attributes in attributesList) {
        if ([UICollectionElementKindSectionHeader isEqualToString:attributes.representedElementKind]) {
            CGRect headerFrame = attributes.frame;
            CGFloat headerMaxY = CGRectGetMaxY(headerFrame);
            NSInteger section = attributes.indexPath.section;
            NSUInteger itemCount = [self.collectionView numberOfItemsInSection:section];
            UICollectionViewLayoutAttributes *attrs1 = nil;
            UICollectionViewLayoutAttributes *attrs2 = nil;
            if (itemCount) {
                NSIndexPath *idxPath1 = [NSIndexPath indexPathForItem:0 inSection:section];;
                NSIndexPath *idxPath2 = [NSIndexPath indexPathForItem:itemCount - 1 inSection:section];
                attrs1 = [self layoutAttributesForItemAtIndexPath:idxPath1];
                attrs2 = [self layoutAttributesForItemAtIndexPath:idxPath2];
            } else {
                attrs1 = attrs2 = [[UICollectionViewLayoutAttributes alloc] init];
                attrs1.frame = CGRectMake(self.sectionInset.left, headerMaxY + self.sectionInset.top, 0, 0);
            }
            CGFloat offsetY = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
            CGFloat minHeaderOriginY = CGRectGetMinY(attrs1.frame) - self.sectionInset.top - CGRectGetHeight(headerFrame);
            CGFloat maxHeaderOriginY = CGRectGetMaxY(attrs2.frame) + self.sectionInset.bottom - CGRectGetHeight(headerFrame);
            headerFrame.origin.y = MIN(MAX(offsetY, minHeaderOriginY), maxHeaderOriginY);
            attributes.frame = headerFrame;
            attributes.zIndex = kDGPinnedSectionHeadersFootersLayoutZIndex;
        }
    }
}
/**
 *  修正竖直滚动方向上的section footers
 *
 *  @param attributesList layout attributes list
 */
- (void)pinVerticalSectionFooters:(inout NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *)attributesList {
    for (UICollectionViewLayoutAttributes *attributes in attributesList) {
        if ([UICollectionElementKindSectionFooter isEqualToString:attributes.representedElementKind]) {
            CGRect footerFrame = attributes.frame;
            CGFloat footerMinY = CGRectGetMinY(footerFrame);
            NSInteger section = attributes.indexPath.section;
            NSUInteger itemCount = [self.collectionView numberOfItemsInSection:section];
            UICollectionViewLayoutAttributes *attrs1 = nil;
            UICollectionViewLayoutAttributes *attrs2 = nil;
            if (itemCount) {
                NSIndexPath *idxPath1 = [NSIndexPath indexPathForItem:0 inSection:section];;
                NSIndexPath *idxPath2 = [NSIndexPath indexPathForItem:itemCount - 1 inSection:section];
                attrs1 = [self layoutAttributesForItemAtIndexPath:idxPath1];
                attrs2 = [self layoutAttributesForItemAtIndexPath:idxPath2];
            } else {
                attrs1 = attrs2 = [[UICollectionViewLayoutAttributes alloc] init];
                attrs1.frame = CGRectMake(self.sectionInset.left, footerMinY - self.sectionInset.bottom, 0, 0);
            }
            CGFloat offsetY = self.collectionView.contentOffset.y + CGRectGetHeight(self.collectionView.bounds) - self.collectionView.contentInset.bottom - CGRectGetHeight(attributes.frame);
            CGFloat minFooterOriginY = CGRectGetMinY(attrs1.frame) - self.sectionInset.top;
            CGFloat maxFooterOriginY = CGRectGetMaxY(attrs2.frame) + self.sectionInset.bottom;
            footerFrame.origin.y = MIN(MAX(offsetY, minFooterOriginY), maxFooterOriginY);
            attributes.frame = footerFrame;
            attributes.zIndex = kDGPinnedSectionHeadersFootersLayoutZIndex;
        }
    }
}
/**
 *  修正水平滚动方向上的section headers
 *
 *  @param attributesList layout attributes list
 */
- (void)pinHorizontalSectionHeaders:(inout NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *)attributesList {
    for (UICollectionViewLayoutAttributes *attributes in attributesList) {
        if ([UICollectionElementKindSectionHeader isEqualToString:attributes.representedElementKind]) {
            CGRect headerFrame = attributes.frame;
            CGFloat headerMaxX = CGRectGetMaxX(headerFrame);
            NSInteger section = attributes.indexPath.section;
            NSUInteger itemCount = [self.collectionView numberOfItemsInSection:section];
            UICollectionViewLayoutAttributes *attrs1 = nil;
            UICollectionViewLayoutAttributes *attrs2 = nil;
            if (itemCount) {
                NSIndexPath *idxPath1 = [NSIndexPath indexPathForItem:0 inSection:section];;
                NSIndexPath *idxPath2 = [NSIndexPath indexPathForItem:itemCount - 1 inSection:section];
                attrs1 = [self layoutAttributesForItemAtIndexPath:idxPath1];
                attrs2 = [self layoutAttributesForItemAtIndexPath:idxPath2];
            } else {
                attrs1 = attrs2 = [[UICollectionViewLayoutAttributes alloc] init];
                attrs1.frame = CGRectMake(self.sectionInset.left + headerMaxX, self.sectionInset.top, 0, 0);
            }
            CGFloat offsetX = self.collectionView.contentOffset.x + self.collectionView.contentInset.left;
            CGFloat minHeaderOriginX = CGRectGetMinX(attrs1.frame) - self.sectionInset.left - CGRectGetWidth(headerFrame);
            CGFloat maxHeaderOriginX = CGRectGetMaxX(attrs2.frame) + self.sectionInset.right - CGRectGetWidth(headerFrame);
            headerFrame.origin.x = MIN(MAX(offsetX, minHeaderOriginX), maxHeaderOriginX);
            attributes.frame = headerFrame;
            attributes.zIndex = kDGPinnedSectionHeadersFootersLayoutZIndex;
        }
    }
}
/**
 *  修正水平滚动方向上的section footers
 *
 *  @param attributesList layout attributes list
 */
- (void)pinHorizontalSectionFooters:(inout NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *)attributesList {
    for (UICollectionViewLayoutAttributes *attributes in attributesList) {
        if ([UICollectionElementKindSectionFooter isEqualToString:attributes.representedElementKind]) {
            CGRect footerFrame = attributes.frame;
            CGFloat footerMinX = CGRectGetMinX(footerFrame);
            NSInteger section = attributes.indexPath.section;
            NSUInteger itemCount = [self.collectionView numberOfItemsInSection:section];
            UICollectionViewLayoutAttributes *attrs1 = nil;
            UICollectionViewLayoutAttributes *attrs2 = nil;
            if (itemCount) {
                NSIndexPath *idxPath1 = [NSIndexPath indexPathForItem:0 inSection:section];;
                NSIndexPath *idxPath2 = [NSIndexPath indexPathForItem:itemCount - 1 inSection:section];
                attrs1 = [self layoutAttributesForItemAtIndexPath:idxPath1];
                attrs2 = [self layoutAttributesForItemAtIndexPath:idxPath2];
            } else {
                attrs1 = attrs2 = [[UICollectionViewLayoutAttributes alloc] init];
                attrs1.frame = CGRectMake(footerMinX - self.sectionInset.right, self.sectionInset.top, 0, 0);
            }
            CGFloat offsetX = self.collectionView.contentOffset.x + CGRectGetWidth(self.collectionView.bounds) - self.collectionView.contentInset.right - CGRectGetWidth(attributes.frame);
            CGFloat minFooterOriginX = CGRectGetMinX(attrs1.frame) - self.sectionInset.left;
            CGFloat maxFooterOriginX = CGRectGetMaxX(attrs2.frame) + self.sectionInset.right;
            footerFrame.origin.x = MIN(MAX(offsetX, minFooterOriginX), maxFooterOriginX);
            attributes.frame = footerFrame;
            attributes.zIndex = kDGPinnedSectionHeadersFootersLayoutZIndex;
        }
    }
}
#endif
@end
