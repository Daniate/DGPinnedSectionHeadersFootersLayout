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

#if 1
CGFloat sectionInsetTop = 30;
CGFloat sectionInsetLeft = 30;
CGFloat sectionInsetBottom = 30;
CGFloat sectionInsetRight = 30;

CGFloat contentInsetTop = 30;
CGFloat contentInsetLeft = 20;
CGFloat contentInsetBottom = 30;
CGFloat contentInsetRight = 20;
#else
CGFloat sectionInsetTop = 0;
CGFloat sectionInsetLeft = 0;
CGFloat sectionInsetBottom = 0;
CGFloat sectionInsetRight = 0;

CGFloat contentInsetTop = 0;
CGFloat contentInsetLeft = 0;
CGFloat contentInsetBottom = 0;
CGFloat contentInsetRight = 0;
#endif

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset = UIEdgeInsetsMake(contentInsetTop, contentInsetLeft, contentInsetBottom, contentInsetRight);
    
    PinnedSectionHeadersFootersLayout *lyt = [[PinnedSectionHeadersFootersLayout alloc] init];
    lyt.minimumLineSpacing = minimumLineSpacing;
    lyt.minimumInteritemSpacing = minimumInteritemSpacing;
    lyt.sectionInset = UIEdgeInsetsMake(sectionInsetTop, sectionInsetLeft, sectionInsetBottom, sectionInsetRight);
    CGFloat itemWH = floor((CGRectGetWidth([UIScreen mainScreen].bounds) - (columns - 1) * minimumInteritemSpacing - sectionInsetLeft - sectionInsetRight) / columns);
    lyt.itemSize = CGSizeMake(itemWH, itemWH);
    self.collectionView.collectionViewLayout = lyt;
    
    [self.collectionView registerNib:[UINib nibWithNibName:CollectionHeaderFooterViewReuseID bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CollectionHeaderFooterViewReuseID];
    [self.collectionView registerNib:[UINib nibWithNibName:CollectionHeaderFooterViewReuseID bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:CollectionHeaderFooterViewReuseID];
}

- (IBAction)adjustScrollDirection:(UISegmentedControl *)sender {
    PinnedSectionHeadersFootersLayout *lyt = (PinnedSectionHeadersFootersLayout *)self.collectionView.collectionViewLayout;
    lyt.scrollDirection = (UICollectionViewScrollDirection)sender.selectedSegmentIndex;
}

- (IBAction)adjustPin:(UISegmentedControl *)sender {
    PinnedSectionHeadersFootersLayout *lyt = (PinnedSectionHeadersFootersLayout *)self.collectionView.collectionViewLayout;
    if (sender.selectedSegmentIndex == 0) {
        lyt.pinnedSectionHeaders = !lyt.pinnedSectionHeaders;
        [sender setTitle:[NSString stringWithFormat:@"pinned headers is %@", lyt.pinnedSectionHeaders ? @"YES" : @"NO"] forSegmentAtIndex:0];
    } else {
        lyt.pinnedSectionFooters = !lyt.pinnedSectionFooters;
        [sender setTitle:[NSString stringWithFormat:@"pinned footers is %@", lyt.pinnedSectionFooters ? @"YES" : @"NO"] forSegmentAtIndex:1];
    }
    sender.selectedSegmentIndex = UISegmentedControlNoSegment;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 10 + arc4random() % 100;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section % 2 == 0 ? 1 + arc4random() % 10 : 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellReuseID forIndexPath:indexPath];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([UICollectionElementKindSectionHeader isEqualToString:kind]) {
        CollectionHeaderFooterView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:CollectionHeaderFooterViewReuseID forIndexPath:indexPath];
        header.textLabel.text = [NSString stringWithFormat:@"h:%ld", (long)indexPath.section];
        header.backgroundColor = [UIColor magentaColor];
        return header;
    }
    if ([UICollectionElementKindSectionFooter isEqualToString:kind]) {
        CollectionHeaderFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:CollectionHeaderFooterViewReuseID forIndexPath:indexPath];
        footer.textLabel.text = [NSString stringWithFormat:@"f:%ld", (long)indexPath.section];
        footer.backgroundColor = [UIColor orangeColor];
        return footer;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    PinnedSectionHeadersFootersLayout *lyt = (PinnedSectionHeadersFootersLayout *)collectionViewLayout;
    CGSize size = CGSizeZero;
    if (lyt.scrollDirection == UICollectionViewScrollDirectionVertical) {
        size = CGSizeMake(CGRectGetWidth(collectionView.bounds), 20);
    } else {
        size = CGSizeMake(40, CGRectGetHeight(collectionView.bounds));
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    PinnedSectionHeadersFootersLayout *lyt = (PinnedSectionHeadersFootersLayout *)collectionViewLayout;
    CGSize size = CGSizeZero;
    if (lyt.scrollDirection == UICollectionViewScrollDirectionVertical) {
        size = CGSizeMake(CGRectGetWidth(collectionView.bounds), 30);
    } else {
        size = CGSizeMake(50, CGRectGetHeight(collectionView.bounds));
    }
    return size;
}

@end
