//
//  WaterFlowLayout.h
//  Gray_main
//
//  本方法只需要传递进来列数，就可以做到自动布局。
//  目前只支持collectionView单组情况
//  优点:每次进来小方格都会填充到最矮行，避免了瀑布流不同列间高矮相差一行以上情况。CE
//
//  Created by CE on 15/10/20.
//  Copyright © 2015年 CE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WaterFlowLayoutDelegate<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfLineForSection:(NSInteger)section;

@end

@interface WaterFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, weak) id<WaterFlowLayoutDelegate> delegate;

@end
