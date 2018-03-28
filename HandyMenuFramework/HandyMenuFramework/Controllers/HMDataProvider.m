//
//  HMPluginsDataController.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMDataProvider.h"

@implementation HMDataProvider

NSDictionary *allPlugins;
NSArray *userCommandsSchemes;

NSUserDefaults *pluginUserDefaults;

-(id)init{
    self = [super init];
    pluginUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@_SUIT_IDENTIFIER_];
//    HMLog(@"Plugin's user defaults keys: %@", [[pluginUserDefaults dictionaryRepresentation] allKeys]);

//    [pluginUserDefaults removeObjectForKey:@"plugin_sketch_handymenu_user_commands"];
    
    return self;
}

-(void)loadData{
    [self loadAllPlugins];
    [self loadUserPlugins];
}

-(void)loadAllPlugins {
    id AppController = NSClassFromString(@"AppController");
    allPlugins = [AppController valueForKeyPath:@"sharedInstance.pluginManager.plugins"];
}

-(void)loadUserPlugins{
    
    userCommandsSchemes = nil;

    NSData *userCommandsArchivedSchemes = [pluginUserDefaults objectForKey:@_USER_COMMANDS_KEY_];
    
    if(userCommandsArchivedSchemes != nil) {
        
        // If a user has the last version
        userCommandsSchemes = [NSKeyedUnarchiver unarchiveObjectWithData:userCommandsArchivedSchemes];
        
    } else {
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSString *userCommandsString = [standardUserDefaults stringForKey:@_OLD_USER_COMMANDS_KEY_];
        
        if (userCommandsString != nil) {
            HMLog(@"Migrating from: %@", userCommandsString);
            // If a user has the previous version
            userCommandsSchemes = [self convertFromPreviousFormat:userCommandsString];
            
            // Removing unnecessary data
            [standardUserDefaults removeObjectForKey:@"handymenu_needs_reload"];
            [standardUserDefaults removeObjectForKey:@"plugin_sketch_handymenu_my_commands_count"];
            [standardUserDefaults removeObjectForKey:@"plugin_sketch_handymenu_my_commands_panel_height"];
            [standardUserDefaults removeObjectForKey:@"plugin_sketch_handymenu_all_commands_string"];
//            [standardUserDefaults removeObjectForKey:@_OLD_USER_COMMANDS_KEY_];
            [standardUserDefaults synchronize];
        } else {
            HMLog(@"No commands are found");
        }
    }
    
    if (_delegate != nil && [_delegate conformsToProtocol:@protocol(HMDataProviderDelegate)]){
        [_delegate dataProviderWasUpdated:self withNewCommandsSchemes:userCommandsSchemes];
    }
}

-(void)saveUserCommandsSchemes:(NSArray *)schemes{
    @try {
        HMLog(@"Saving: %@", schemes);
        NSData *userCommandsArchivedSchemes = [NSKeyedArchiver archivedDataWithRootObject:schemes];
        [pluginUserDefaults setObject:userCommandsArchivedSchemes forKey:@_USER_COMMANDS_KEY_];
        [pluginUserDefaults synchronize];
    } @catch (NSException *exeption) {
        HMLog(@"%@", exeption);
    }
}


-(NSArray *)getUserCommands{
    
    NSMutableArray* commands = [[NSMutableArray alloc] init];
    
    for (HMCommandScheme *commandScheme in userCommandsSchemes){
        
        id command = [[[allPlugins valueForKey:commandScheme.pluginID] valueForKey:@"commands"] valueForKey:commandScheme.commandID];
        
        if(command) {
            [commands addObject:command];
        }
        
    }
    
    return commands;
}

-(NSArray *)convertFromPreviousFormat:(NSString *)userCommandsString{
    
    NSMutableArray *temporaryUserCommandSchemes = [[NSMutableArray alloc] init];
    
    NSData *decodedUserCommands = [[userCommandsString stringByRemovingPercentEncoding] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *jsonError;
    NSDictionary *userCommandsDictionary = [NSJSONSerialization JSONObjectWithData:decodedUserCommands options:NSJSONReadingMutableContainers error:&jsonError];
    
    for (NSDictionary *oldCommand in [userCommandsDictionary objectForKey:@"list"]) {
        
        // Ignoring separators
        if ([[oldCommand valueForKey:@"type"]  isEqual: @"command"]) {
            
            HMCommandScheme *commandScheme = [[HMCommandScheme alloc] init];
            commandScheme.pluginID = [oldCommand valueForKey:@"pluginID"];
            commandScheme.commandID = [oldCommand valueForKey:@"commandID"];
            commandScheme.name = [oldCommand valueForKey:@"name"];
            [temporaryUserCommandSchemes addObject:commandScheme];
        }
        
    }
    
    // Saving new data
    [self saveUserCommandsSchemes:[temporaryUserCommandSchemes copy]];
    return [temporaryUserCommandSchemes copy];
}

-(NSArray *)getPluginsSchemes {
    
    NSMutableArray *unsortedPluginsSchemes = [[NSMutableArray alloc] init];
    
    for (NSString *key in allPlugins){
        
        id plugin = [allPlugins objectForKey:key]; // Plugin
        NSDictionary *pluginCommands = [plugin valueForKey:@"commands"]; // Dictionary of the plugin's commands
        
        HMPluginScheme *newPluginScheme = [[HMPluginScheme alloc] init];
        newPluginScheme.identifier = [plugin valueForKey:@"identifier"];
        newPluginScheme.name = [plugin valueForKey:@"name"];
        
        NSMutableArray *pluginSchemeCommands = [[NSMutableArray alloc] init]; // Temporary mutable array for plugin's commands
        
        for (NSString *commandID in pluginCommands){
            
            HMCommandScheme *newCommandScheme = [[HMCommandScheme alloc] init];
            
            id command = pluginCommands[commandID];
            
            newCommandScheme.name = [command valueForKey:@"name"];
            newCommandScheme.commandID = [command valueForKey:@"identifier"];
            newCommandScheme.pluginID = [plugin valueForKey:@"identifier"];
            
            [pluginSchemeCommands addObject:newCommandScheme];
        }
        
        newPluginScheme.commands = [pluginSchemeCommands copy];
        [unsortedPluginsSchemes addObject:newPluginScheme];
    }
    
    // Sorting plugins alphabetically
    NSArray *sortedPluginSchemes = [unsortedPluginsSchemes sortedArrayUsingComparator:^(id first, id second) {
        
        NSString *firstName = [(HMPluginScheme*)first name];
        NSString *secondName = [(HMPluginScheme*)second name];
        
        return [firstName compare:secondName];
        
    }];
    
    return sortedPluginSchemes;
}

-(NSArray *)getUserCommandsSchemes{
    return userCommandsSchemes;
}

-(void)updatedUserCommandsSchemes:(NSArray *)newCommandSchemes {
    userCommandsSchemes = newCommandSchemes;
    [self saveUserCommandsSchemes:newCommandSchemes];
    
    if (_delegate != nil && [_delegate conformsToProtocol:@protocol(HMDataProviderDelegate)]){
        [_delegate dataProviderWasUpdated:self withNewCommandsSchemes:userCommandsSchemes];
    }
}



@end

