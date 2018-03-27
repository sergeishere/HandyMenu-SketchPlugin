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
    [settingsWindowController updatePluginsLists:[dataProvider getSortedListOfAllPlugins]];
    
    return self;
}

-(void)showMenu{
    [menu showMenu];
}

-(void)showSettings{

    [settingsWindowController showWindow:nil];
}

-(void)dataProviderWasUpdated:(id)dataProvider withNewCommands:(id)commands{
    [menu updateMenuFromCommandsList:commands];
}

@end
