//
//  HMBackgroundView.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 02/04/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMBackgroundView.h"

@implementation HMBackgroundView

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithCalibratedRed:0.96 green:0.96 blue:0.96 alpha:1.0] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
