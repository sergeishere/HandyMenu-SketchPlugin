//
//  HMSearchField.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 04/04/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMSearchField.h"

@implementation HMSearchField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)keyDown:(NSEvent *)event{
    if (event.keyCode == 23) {
        [self.window makeFirstResponder:nil];
    }
}
@end
