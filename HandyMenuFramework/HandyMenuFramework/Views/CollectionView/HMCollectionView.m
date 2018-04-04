//
//  HMCollectionView.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 04/04/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMCollectionView.h"

@implementation HMCollectionView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(BOOL)resignFirstResponder{
    [self deselectAll:nil];
    return [super resignFirstResponder];
}

@end
