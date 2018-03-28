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

@end
