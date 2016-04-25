//
//  CollectionHeaderFooterView.h
//  PinnedSectionHeadersFootersLayout
//
//  Created by Daniate on 16/4/23.
//  Copyright © 2016年 Daniate. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const CollectionHeaderFooterViewReuseID;

@interface CollectionHeaderFooterView : UICollectionReusableView
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@end
