//
//  HMPluginController.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 26/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMPluginController.h"

@implementation HMPluginController

HMSettingsWindowController *settingsWindowController;
HMMenu *menu;
HMDataProvider *dataProvider;

-(id)init {
    self = [super init];
    
    menu = [[HMMenu alloc] init];
    menu.groupComands = YES;
    
    dataProvider = [[HMDataProvider alloc] init];
    
    [dataProvider setDelegate:self];
    [dataProvider loadData];
    
    settingsWindowController = [[HMSettingsWindowController alloc] initWithWindowNibName:@"HMSettingsWindowController"];

    [settingsWindowController updatePlugins:[dataProvider getPluginsSchemes]];
    [settingsWindowController updateUserCommands:[dataProvider getUserCommandsSchemes]];
    [settingsWindowController setDelegate:self];
    
    return self;
}

-(void)showMenu{
    [menu showMenu];
}

-(void)showSettings{
    [settingsWindowController updateUserCommands:[dataProvider getUserCommandsSchemes]];
    [settingsWindowController showWindow:nil];
}

#pragma mark - HMDataProvider Delegate

-(void)dataProviderWasUpdated:(id)dataProvider withNewCommandsSchemes:(id)commands{
    HMLog(@"Data provider was updated");
    [menu updateMenuFromCommandsList:[dataProvider getUserCommands]];
}

#pragma mark - HMSettingsWindowController Delegate

-(void)settingsWindowController:(id)settingsWindowController didUpdateCommandsSchemes:(NSArray *)newCommandsSchemes andGroupOption:(BOOL)group{
    [menu setGroupComands:group];
    [dataProvider updatedUserCommandsSchemes:newCommandsSchemes];
}

@end
