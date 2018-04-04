//
//  HMShortcutField.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 17/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMShortcutField.h"

@implementation HMShortcutField

NSMutableArray *flags;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

}

-(void)awakeFromNib {
    [super awakeFromNib];
    flags = [[NSMutableArray alloc] init];
}

-(BOOL)becomeFirstResponder {
    HMLog(@"HMShortcutField started");
    return [super becomeFirstResponder];
}

-(BOOL)resignFirstResponder {
    BOOL canResign = [super resignFirstResponder];
    
    if (canResign) {
        HMLog(@"HMShortcutField stopped");
    }
    
    return canResign;
    
}



- (void)flagsChanged:(NSEvent *)event {
    [flags removeAllObjects];
    [flags addObject: ([event modifierFlags] & NSEventModifierFlagControl) ? @"⌃" : @""];
    [flags addObject: ([event modifierFlags] & NSEventModifierFlagOption) ? @"⌥" : @""];
    [flags addObject: ([event modifierFlags] & NSEventModifierFlagShift) ? @"⇧" : @""];
    [flags addObject: ([event modifierFlags] & NSEventModifierFlagCommand) ? @"⌘" : @""];
    //    [flags addObject: ([event modifierFlags] & NSEventModifierFlagFunction) ? @"fn" : @""];
    [self setStringValue:[flags componentsJoinedByString:@""]];
    [self selectAll:nil];
    
    HMLog(@"HMShortcutField doing something");
}

@end
