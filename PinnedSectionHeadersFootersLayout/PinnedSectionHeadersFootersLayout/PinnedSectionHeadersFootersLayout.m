//
//  PinnedSectionHeadersFootersLayout.m
//  PinnedSectionHeadersFootersLayout
//
//  Created by Daniate on 16/4/23.
//  Copyright © 2016年 Daniate. All rights reserved.
//

#import "PinnedSectionHeadersFootersLayout.h"

@implementation PinnedSectionHeadersFootersLayout

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
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    // fix iOS 6 bugs
    if ([[UIDevice currentDevice].systemVersion compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending) {
        self.collectionView.directionalLockEnabled = YES;
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            self.collectionView.showsHorizontalScrollIndicator = NO;
            self.collectionView.showsVerticalScrollIndicator = YES;
        } else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            self.collectionView.showsHorizontalScrollIndicator = YES;
            self.collectionView.showsVerticalScrollIndicator = NO;
        }
    }
    // pin headers & footers
    NSArray<__kindof UICollectionViewLayoutAttributes *> *superAttrsList = [super layoutAttributesForElementsInRect:rect];
    // If system version is less than 9.0, using custom implementations
    if ([[UIDevice currentDevice].systemVersion compare:@"9.0" options:NSNumericSearch] == NSOrderedAscending) {
        if (self.pinnedSectionHeaders || self.pinnedSectionFooters) {
            NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *attrsList = [superAttrsList mutableCopy];
            if (self.pinnedSectionHeaders) {
                NSIndexSet *indexSet = [self disappearedSections:attrsList supplementaryViewOfKind:UICollectionElementKindSectionHeader];
                [self complementDisappearedAttributesList:attrsList indexSet:indexSet supplementaryViewOfKind:UICollectionElementKindSectionHeader];
                if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                    [self pinVerticalSectionHeaders:attrsList];
                } else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                    [self pinHorizontalSectionHeaders:attrsList];
                }
            }
            if (self.pinnedSectionFooters) {
                NSIndexSet *indexSet = [self disappearedSections:attrsList supplementaryViewOfKind:UICollectionElementKindSectionFooter];
                [self complementDisappearedAttributesList:attrsList indexSet:indexSet supplementaryViewOfKind:UICollectionElementKindSectionFooter];
                if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                    [self pinVerticalSectionFooters:attrsList];
                } else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                    [self pinHorizontalSectionFooters:attrsList];
                }
            }
            return attrsList;
        }
    }
    return superAttrsList;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    // If system version is less than 9.0, using custom implementations
    if ([[UIDevice currentDevice].systemVersion compare:@"9.0" options:NSNumericSearch] == NSOrderedAscending) {
        return (self.pinnedSectionHeaders || self.pinnedSectionFooters);
    }
    return [super shouldInvalidateLayoutForBoundsChange:newBounds];
}
#endif

#if __ENVIRONMENT_IPHONE_OS_VERSION_MIN_REQUIRED__ < 90000
- (NSIndexSet *)disappearedSections:(NSArray<__kindof UICollectionViewLayoutAttributes *> *)attributesList supplementaryViewOfKind:(NSString *)elementKind {
    // 查找可能已经消失的header/footer对应的section
    NSMutableIndexSet *disappearedSections = [NSMutableIndexSet indexSet];
    // 根据当前显示的cell，获取section
    for (UICollectionViewLayoutAttributes *attributes in attributesList) {
        NSInteger section = attributes.indexPath.section;
        if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
            [disappearedSections addIndex:section];
        }
    }
    // 将当前显示的section header/footer，从索引中移除
    for (UICollectionViewLayoutAttributes *attributes in attributesList) {
        NSInteger section = attributes.indexPath.section;
        if ([attributes.representedElementKind isEqualToString:elementKind]) {
            [disappearedSections removeIndex:section];
        }
    }
    return disappearedSections;
}

- (void)complementDisappearedAttributesList:(inout NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *)attributesList indexSet:(NSIndexSet *)indexSet supplementaryViewOfKind:(NSString *)elementKind {
    // 为已经消失的header/footer，补充layout attributes
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

- (void)pinVerticalSectionHeaders:(inout NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *)attributesList {
    // 修正vertical header的layout attributes
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
            attributes.zIndex = 10;
        }
    }
}
- (void)pinVerticalSectionFooters:(inout NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *)attributesList {
    // 修正vertical footer的layout attributes
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
            attributes.zIndex = 10;
        }
    }
}
- (void)pinHorizontalSectionHeaders:(inout NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *)attributesList {
    // 修正horizontal header的layout attributes
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
            attributes.zIndex = 10;
        }
    }
}
- (void)pinHorizontalSectionFooters:(inout NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *)attributesList {
    // 修正horizontal footer的layout attributes
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
            attributes.zIndex = 10;
        }
    }
}
#endif
@end
