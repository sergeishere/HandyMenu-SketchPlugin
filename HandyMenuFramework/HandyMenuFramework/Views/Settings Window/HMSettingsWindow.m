//
//  HMSettingsWindow.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 01/04/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMSettingsWindow.h"

@implementation HMSettingsWindow

-(void)awakeFromNib{
    [super awakeFromNib];
    
    // Setting up the window
    [self setLevel:NSNormalWindowLevel];
//    [[self standardWindowButton:NSWindowZoomButton] setHidden:YES];
//    [[self standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
    
    [self setStyleMask:[self styleMask] | NSWindowStyleMaskResizable];
    [[self standardWindowButton:NSWindowZoomButton] setEnabled:NO];
    
    [self setMovableByWindowBackground:YES];
    
    [self setFrameAutosaveName:@"HandyMenu Settings Window"];
    if(![self setFrameUsingName:@"HandyMenu Settings Window"]) {
        [self center];
    }

}

@end
