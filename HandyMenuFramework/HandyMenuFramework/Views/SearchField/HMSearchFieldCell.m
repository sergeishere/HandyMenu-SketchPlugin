//
//  HMSearchFieldCell.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 04/04/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMSearchFieldCell.h"

@implementation HMSearchFieldCell

- (NSRect)drawingRectForBounds:(NSRect)rect{
    NSRect originalRect = [super drawingRectForBounds:rect];
    NSRect rectInset = NSMakeRect(originalRect.origin.x + _leftPadding - 2,
                                  originalRect.origin.y,
                                  originalRect.size.width-_leftPadding-24,
                                  originalRect.size.height);
    return rectInset;
}

//- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
//    NSRect newRect = cellFrame;
//    newRect.size.width -= 24;
//    [super drawInteriorWithFrame:newRect inView:controlView];
//}

- (void)resetCursorRect:(NSRect)cellFrame inView:(NSView *)controlView{
    NSRect newRect = cellFrame;
    newRect.size.width -= 24;
    [super resetCursorRect:newRect inView:controlView];
}

@end
