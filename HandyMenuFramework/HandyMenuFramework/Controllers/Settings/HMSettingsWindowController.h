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
#import <HMDataProvider.h>
#import <HMCommandScheme.h>
#import <HMPluginScheme.h>

#define HMLog(fmt, ...) NSLog((@"HandyMenu (Sketch Plugin) %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@protocol HMSettingsWindowControllerDelegate<NSObject>
@required

-(void)settingsWindowController:(id)settingsWindowController didUpdateCommandsSchemes:(NSArray *)newCommandsSchemes;

@end

@interface HMSettingsWindowController : NSWindowController<NSTextFieldDelegate, NSWindowDelegate,  NSOutlineViewDataSource, NSOutlineViewDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet HMShortcutField *shortcutTextField;
@property (weak) IBOutlet NSOutlineView *allCommandsOutlineView;
@property (weak) IBOutlet NSTableView *userCommandsTableView;

@property (weak) id<HMSettingsWindowControllerDelegate> delegate;

-(void)updatePlugins:(NSArray *)schemes;
-(void)updateUserCommands:(NSArray *)schemes;

@end
