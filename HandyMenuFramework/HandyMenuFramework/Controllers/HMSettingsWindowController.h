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
#import <HMTableCellView.h>
#import <HMCommandCollectionViewItem.h>
#import <HMSettingsWindowViewController.h>
#import <HMPluginSectionHeaderView.h>


@protocol HMSettingsWindowControllerDelegate<NSObject>
@optional

-(void)settingsWindowController:(id)settingsWindowController didUpdateCommandsSchemes:(NSArray *)newCommandsSchemes andGroupOption:(BOOL)group;

@end


@interface HMSettingsWindowController : NSWindowController<NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout, NSTableViewDataSource, NSTableViewDelegate, HMTableViewDelegate, HMSettingsWindowViewControllerDelegate, HMCommandCollectionViewItemDelegate, NSTextFieldDelegate>

@property (weak) IBOutlet NSCollectionView *allCommandsCollectionView;
@property (weak) IBOutlet HMTableView *userCommandsTableView;
@property (weak) IBOutlet NSTextField *searchField;
@property (weak) IBOutlet NSTextField *noCommandsNotificationLabel;
@property (weak) IBOutlet NSButton *clearButton;

@property (weak) id<HMSettingsWindowControllerDelegate> delegate;

-(void)updatePlugins:(NSArray *)schemes;
-(void)updateUserCommands:(NSArray *)schemes;

@end
