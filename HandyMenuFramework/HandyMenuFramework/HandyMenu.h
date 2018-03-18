//
//  HandyMenu.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 13/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <objc/message.h>
#import <HMSettingsWindowController.h>

#define HMLog(fmt, ...) NSLog((@"HandyMenu (Sketch Plugin) %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@interface HandyMenu : NSObject

+ (void) initializePlugin;
+ (void) showMenu;
+ (void) runCommand:(NSMenuItem *)sender;
+ (void) showSettings;

@end
