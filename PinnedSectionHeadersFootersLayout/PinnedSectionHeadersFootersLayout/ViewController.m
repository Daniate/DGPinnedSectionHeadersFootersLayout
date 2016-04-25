//
//  ViewController.m
//  PinnedSectionHeadersFootersLayout
//
//  Created by Daniate on 16/4/23.
//  Copyright © 2016年 Daniate. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import "CollectionHeaderFooterView.h"
#import "PinnedSectionHeadersFootersLayout.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end

NSUInteger columns = 4;
CGFloat minimumLineSpacing = 10;
CGFloat minimumInteritemSpacing = 10;
CGFloat sectionInsetTop = 10;
CGFloat sectionInsetLeft = 10;
CGFloat sectionInsetBottom = 10;
CGFloat sectionInsetRight = 10;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.collectionView.backgroundColor = self.view.backgroundColor;
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset = UIEdgeInsetsMake(100, 0, 100, 0);
    
    PinnedSectionHeadersFootersLayout *lyt = [[PinnedSectionHeadersFootersLayout alloc] init];
//    lyt.pinnedSectionHeaders = NO;
//    lyt.pinnedSectionFooters = NO;
    lyt.minimumLineSpacing = minimumLineSpacing;
    lyt.minimumInteritemSpacing = minimumInteritemSpacing;
    lyt.sectionInset = UIEdgeInsetsMake(sectionInsetTop, sectionInsetLeft, sectionInsetBottom, sectionInsetRight);
    CGFloat itemWH = floor((CGRectGetWidth([UIScreen mainScreen].bounds) - (columns - 1) * minimumInteritemSpacing - sectionInsetLeft - sectionInsetRight) / columns);
    lyt.itemSize = CGSizeMake(itemWH, itemWH);
    self.collectionView.collectionViewLayout = lyt;
    
    [self.collectionView registerNib:[UINib nibWithNibName:CollectionHeaderFooterViewReuseID bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CollectionHeaderFooterViewReuseID];
    [self.collectionView registerNib:[UINib nibWithNibName:CollectionHeaderFooterViewReuseID bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:CollectionHeaderFooterViewReuseID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 5 + arc4random() % 20;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return arc4random() % 20;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellReuseID forIndexPath:indexPath];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([UICollectionElementKindSectionHeader isEqualToString:kind]) {
        CollectionHeaderFooterView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:CollectionHeaderFooterViewReuseID forIndexPath:indexPath];
        header.textLabel.text = [NSString stringWithFormat:@"header: %ld", (long)indexPath.section];
        header.backgroundColor = [UIColor magentaColor];
        return header;
    }
    if ([UICollectionElementKindSectionFooter isEqualToString:kind]) {
        CollectionHeaderFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:CollectionHeaderFooterViewReuseID forIndexPath:indexPath];
        footer.textLabel.text = [NSString stringWithFormat:@"footer: %ld", (long)indexPath.section];
        footer.backgroundColor = [UIColor orangeColor];
        return footer;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size = CGSizeMake(CGRectGetWidth(collectionView.bounds), 20);
    
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize size = CGSizeMake(CGRectGetWidth(collectionView.bounds), 20);
    
    return size;
}

@end
