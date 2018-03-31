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
#import <HMTableView.h>
#import "HMLog.h"
#import <CoreGraphics/CoreGraphics.h>


@protocol HMSettingsWindowControllerDelegate<NSObject>
@optional

-(void)settingsWindowController:(id)settingsWindowController didUpdateCommandsSchemes:(NSArray *)newCommandsSchemes andGroupOption:(BOOL)group;

@end


@interface HMSettingsWindowController : NSWindowController<NSOutlineViewDataSource, NSOutlineViewDelegate, NSTableViewDataSource, NSTableViewDelegate, HMTableViewDelegate>

@property (weak) IBOutlet NSOutlineView *allCommandsOutlineView;
@property (weak) IBOutlet HMTableView *userCommandsTableView;
@property (weak) IBOutlet NSSearchField *searchField;

@property (weak) id<HMSettingsWindowControllerDelegate> delegate;

-(void)updatePlugins:(NSArray *)schemes;
-(void)updateUserCommands:(NSArray *)schemes;

@end
