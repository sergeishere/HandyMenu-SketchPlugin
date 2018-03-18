//
//  HMSettingsWindowController.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 16/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <HMShortcutField.h>

#define HMLog(fmt, ...) NSLog((@"HandyMenu (Sketch Plugin) %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@interface HMSettingsWindowController : NSWindowController<NSTextFieldDelegate, NSWindowDelegate>

@property (weak) IBOutlet HMShortcutField *shortcutTextField;

@end
