//
//  HMPluginSectionHeaderView.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 03/04/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMPluginSectionHeaderView.h"

@implementation HMPluginSectionHeaderView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)prepareForReuse{
    [self.horizontalLine setHidden:NO];
}

@end
