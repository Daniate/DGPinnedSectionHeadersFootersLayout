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
    NSArray<__kindof UICollectionViewLayoutAttributes *> *superAttrsList = [super layoutAttributesForElementsInRect:rect];
    // If system version is less than 9.0, using custom implementations
    if ([[UIDevice currentDevice].systemVersion compare:@"9.0" options:NSNumericSearch] == NSOrderedAscending) {
        if (self.pinnedSectionHeaders || self.pinnedSectionFooters) {
            __typeof(&*self) __weak zelf = self;
            NSMutableArray<__kindof UICollectionViewLayoutAttributes *> *attrsList = [superAttrsList mutableCopy];
            if (self.pinnedSectionHeaders) {
                // 查找可能已经消失的header对应的section
                NSMutableIndexSet *disappearedHeaderSections = [NSMutableIndexSet indexSet];
                for (UICollectionViewLayoutAttributes *attrs in attrsList) {
                    NSInteger section = attrs.indexPath.section;
                    if (attrs.representedElementCategory == UICollectionElementCategoryCell) {
                        [disappearedHeaderSections addIndex:section];
                    } else if ([attrs.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
                        [disappearedHeaderSections removeIndex:section];
                    }
                }
                if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                    // 为已经消失的header，补充layout attributes
                    [disappearedHeaderSections enumerateIndexesWithOptions:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        NSIndexPath *idxPath = [NSIndexPath indexPathForItem:0 inSection:idx];
                        UICollectionViewLayoutAttributes *attrs = [zelf layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:idxPath];
                        if (attrs && attrs.frame.size.height > DBL_EPSILON) {
                            [attrsList addObject:attrs];
                        }
                    }];
                    // 修正header的layout attributes
                    for (UICollectionViewLayoutAttributes *attrs in attrsList) {
                        if ([UICollectionElementKindSectionHeader isEqualToString:attrs.representedElementKind]) {
                            CGRect headerFrame = attrs.frame;
                            CGFloat headerMaxY = CGRectGetMaxY(headerFrame);
                            
                            NSInteger section = attrs.indexPath.section;
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
                            attrs.frame = headerFrame;
                            attrs.zIndex = 10;
                        }
                    }
                } else {
                    // 为已经消失的header，补充layout attributes
                    [disappearedHeaderSections enumerateIndexesWithOptions:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        NSIndexPath *idxPath = [NSIndexPath indexPathForItem:0 inSection:idx];
                        UICollectionViewLayoutAttributes *attrs = [zelf layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:idxPath];
                        if (attrs && attrs.frame.size.width > DBL_EPSILON) {
                            [attrsList addObject:attrs];
                        }
                    }];
                    // 修正header的layout attributes
                    for (UICollectionViewLayoutAttributes *attrs in attrsList) {
                        if ([UICollectionElementKindSectionHeader isEqualToString:attrs.representedElementKind]) {
                            CGRect headerFrame = attrs.frame;
                            CGFloat headerMaxY = CGRectGetMaxY(headerFrame);
                            
                            NSInteger section = attrs.indexPath.section;
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
                            CGFloat offsetX = self.collectionView.contentOffset.x + self.collectionView.contentInset.left;
                            CGFloat minHeaderOriginX = CGRectGetMinX(attrs1.frame) - self.sectionInset.left - CGRectGetWidth(headerFrame);
                            CGFloat maxHeaderOriginX = CGRectGetMaxX(attrs2.frame) + self.sectionInset.right - CGRectGetWidth(headerFrame);
                            headerFrame.origin.x = MIN(MAX(offsetX, minHeaderOriginX), maxHeaderOriginX);
                            attrs.frame = headerFrame;
                            attrs.zIndex = 10;
                        }
                    }
                }
            }
            if (self.pinnedSectionFooters) {
                // 查找可能已经消失的footer对应的section
                NSMutableIndexSet *disappearedFooterSections = [NSMutableIndexSet indexSet];
                for (UICollectionViewLayoutAttributes *attrs in attrsList) {
                    NSInteger section = attrs.indexPath.section;
                    if (attrs.representedElementCategory == UICollectionElementCategoryCell) {
                        [disappearedFooterSections addIndex:section];
                    } else if ([attrs.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]) {
                        [disappearedFooterSections removeIndex:section];
                    }
                }
                if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                    // 为已经消失的footer，补充layout attributes
                    [disappearedFooterSections enumerateIndexesWithOptions:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        NSIndexPath *idxPath = [NSIndexPath indexPathForItem:0 inSection:idx];
                        UICollectionViewLayoutAttributes *attrs = [zelf layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:idxPath];
                        if (attrs && attrs.frame.size.height > DBL_EPSILON) {
                            [attrsList addObject:attrs];
                        }
                    }];
                    // 修正footer的layout attributes
                    for (UICollectionViewLayoutAttributes *attrs in attrsList) {
                        if ([UICollectionElementKindSectionFooter isEqualToString:attrs.representedElementKind]) {
                            CGRect footerFrame = attrs.frame;
                            CGFloat footerMinY = CGRectGetMinY(footerFrame);
                            
                            NSInteger section = attrs.indexPath.section;
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
                            CGFloat offsetY = self.collectionView.contentOffset.y + CGRectGetHeight(self.collectionView.bounds) - self.collectionView.contentInset.bottom - CGRectGetHeight(attrs.frame);
                            CGFloat minFooterOriginY = CGRectGetMinY(attrs1.frame) - self.sectionInset.top;
                            CGFloat maxFooterOriginY = CGRectGetMaxY(attrs2.frame) + self.sectionInset.bottom;
                            footerFrame.origin.y = MIN(MAX(offsetY, minFooterOriginY), maxFooterOriginY);
                            attrs.frame = footerFrame;
                            attrs.zIndex = 10;
                        }
                    }
                } else {
                    // 为已经消失的footer，补充layout attributes
                    [disappearedFooterSections enumerateIndexesWithOptions:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        NSIndexPath *idxPath = [NSIndexPath indexPathForItem:0 inSection:idx];
                        UICollectionViewLayoutAttributes *attrs = [zelf layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:idxPath];
                        if (attrs && attrs.frame.size.width > DBL_EPSILON) {
                            [attrsList addObject:attrs];
                        }
                    }];
                    // 修正footer的layout attributes
                    for (UICollectionViewLayoutAttributes *attrs in attrsList) {
                        if ([UICollectionElementKindSectionFooter isEqualToString:attrs.representedElementKind]) {
                            CGRect footerFrame = attrs.frame;
                            CGFloat footerMinY = CGRectGetMinY(footerFrame);
                            
                            NSInteger section = attrs.indexPath.section;
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
                            CGFloat offsetX = self.collectionView.contentOffset.x + CGRectGetWidth(self.collectionView.bounds) - self.collectionView.contentInset.right - CGRectGetWidth(attrs.frame);
                            CGFloat minFooterOriginX = CGRectGetMinX(attrs1.frame) - self.sectionInset.left;
                            CGFloat maxFooterOriginX = CGRectGetMaxX(attrs2.frame) + self.sectionInset.right;
                            footerFrame.origin.x = MIN(MAX(offsetX, minFooterOriginX), maxFooterOriginX);
                            attrs.frame = footerFrame;
                            attrs.zIndex = 10;
                        }
                    }
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
@end
