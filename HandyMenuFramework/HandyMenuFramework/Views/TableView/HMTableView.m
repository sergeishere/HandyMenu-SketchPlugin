//
//  HMTableView.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 29/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMTableView.h"

@implementation HMTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)keyDown:(NSEvent *)event
{
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
    
    if(key == NSDeleteCharacter)
    {
        if ([self selectedRow] != -1){
            id delegate = [self delegate];
            if (delegate != nil && [delegate conformsToProtocol:@protocol(HMTableViewDelegate)]){
                [delegate deleteIsPressedInTableView:self];
            }
        }
    }
    [super keyDown:event];
}

-(void)draggingSession:(NSDraggingSession *)session movedToPoint:(NSPoint)screenPoint{
    NSRect rectInWindow =  NSInsetRect([self convertRect:[self bounds] toView:nil], -10.0, -10.0);
    NSRect screenRect = [[self window] convertRectToScreen:rectInWindow];
    
    if(!NSPointInRect(screenPoint, screenRect)) {
        [[NSCursor disappearingItemCursor] set];
    } else {
        [[NSCursor arrowCursor] set];
    }
}

@end
