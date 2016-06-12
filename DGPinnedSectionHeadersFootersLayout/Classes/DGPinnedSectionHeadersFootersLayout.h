//
//  DGPinnedSectionHeadersFootersLayout.h
//  DGPinnedSectionHeadersFootersLayout
//
//  Created by Daniate on 16/4/23.
//  Copyright © 2016年 Daniate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGPinnedSectionHeadersFootersLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) BOOL pinnedSectionHeaders;// default is YES
@property (nonatomic, assign) BOOL pinnedSectionFooters;// default is YES
@end
