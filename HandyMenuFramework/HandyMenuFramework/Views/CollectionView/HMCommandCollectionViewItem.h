//
//  HMCommandCollectionViewItem.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 03/04/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol HMCommandCollectionViewItemDelegate<NSObject>
@optional

-(void)doubleClickInCollectionView:(id)sender;

@end

@interface HMCommandCollectionViewItem : NSCollectionViewItem

@end
