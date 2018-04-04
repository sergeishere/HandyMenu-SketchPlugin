//
//  HMCommandCollectionViewItem.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 03/04/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMCommandCollectionViewItem.h"

@interface HMCommandCollectionViewItem ()

@end

@implementation HMCommandCollectionViewItem

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
    self.view.layer.backgroundColor = selected ? [[NSColor alternateSelectedControlColor] CGColor] : [[NSColor whiteColor] CGColor];
    self.textField.textColor = selected ? [NSColor whiteColor] : [NSColor controlTextColor];
}

-(void)mouseDown:(NSEvent *)event{
    [super mouseDown:event];
    if (event.clickCount > 1) {
        if([self collectionView] && [[self collectionView] delegate] && [[[self collectionView] delegate] conformsToProtocol:@protocol(HMCommandCollectionViewItemDelegate)]) {
            [(id<HMCommandCollectionViewItemDelegate>)[[self collectionView] delegate] doubleClickInCollectionView:self];
        }
    }
}

@end
