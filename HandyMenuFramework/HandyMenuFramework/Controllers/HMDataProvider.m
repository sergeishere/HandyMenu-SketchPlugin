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
NSArray *userCommands;

NSUserDefaults *pluginUserDefaults;

-(id)init{
    self = [super init];
    pluginUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.sergeishere.plugins.handymenu"];
    HMLog(@"Plugin's user defaults keys: %@", [[pluginUserDefaults dictionaryRepresentation] allKeys]);

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
    
    userCommands = nil;

    NSData *userCommandsArchivedSchemes = [pluginUserDefaults objectForKey:@"plugin_sketch_handymenu_user_commands"];
    
    if(userCommandsArchivedSchemes != nil) {
        
        // If a user has the last version
        NSArray *userCommandSchemes = [NSKeyedUnarchiver unarchiveObjectWithData:userCommandsArchivedSchemes];
        userCommands = [self getCommandsMatchingSchemes:userCommandSchemes];
        
    } else {
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSString *userCommandsString = [standardUserDefaults stringForKey:@"plugin_sketch_handymenu_my_commands"];
        
        if (userCommandsString != nil) {
            HMLog(@"Migrating from: %@", userCommandsString);
            // If a user has the previous version
            userCommands = [self getCommandsMatchingSchemes:[self convertFromPreviousFormat:userCommandsString]];
            
            // Removing unnecessary data
            [standardUserDefaults removeObjectForKey:@"handymenu_needs_reload"];
            [standardUserDefaults removeObjectForKey:@"plugin_sketch_handymenu_my_commands_count"];
            [standardUserDefaults removeObjectForKey:@"plugin_sketch_handymenu_my_commands_panel_height"];
            [standardUserDefaults removeObjectForKey:@"plugin_sketch_handymenu_all_commands_string"];
            [standardUserDefaults removeObjectForKey:@"plugin_sketch_handymenu_my_commands"];
            [standardUserDefaults synchronize];
        }
    }
    
    if (_delegate != nil && [_delegate conformsToProtocol:@protocol(HMDataProviderDelegate)]){
        [_delegate dataProviderWasUpdated:self withNewCommands:userCommands];
    }
}

-(void)saveUserCommandsSchemes:(NSArray *)schemes{
    @try {
        NSData *userCommandsArchivedSchemes = [NSKeyedArchiver archivedDataWithRootObject:schemes];
        [pluginUserDefaults setObject:userCommandsArchivedSchemes forKey:@"plugin_sketch_handymenu_user_commands"];
        [pluginUserDefaults synchronize];
    } @catch (NSException *exeption) {
        HMLog(@"%@", exeption);
    }

}

-(NSArray *)getCommandsMatchingSchemes:(NSArray *)schemes{
    
    NSMutableArray* commands = [[NSMutableArray alloc] init];
    
    for (HMCommandScheme *commandScheme in schemes){
        
        id command = [[[allPlugins valueForKey:commandScheme.pluginID] valueForKey:@"commands"] valueForKey:commandScheme.commandID];
        
        if(command) {
            [commands addObject:command];
        }
        
    }
    
    return commands;
}

-(NSArray *)convertFromPreviousFormat:(NSString *)userCommandsString{
    
    NSMutableArray *userCommandSchemes = [[NSMutableArray alloc] init];
    
    NSData *decodedUserCommands = [[userCommandsString stringByRemovingPercentEncoding] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *jsonError;
    NSDictionary *userCommandsDictionary = [NSJSONSerialization JSONObjectWithData:decodedUserCommands options:NSJSONReadingMutableContainers error:&jsonError];
    
    for (NSDictionary *oldCommand in [userCommandsDictionary objectForKey:@"list"]) {
        
        // Ignoring separators
        if ([[oldCommand valueForKey:@"type"]  isEqual: @"command"]) {
            
            HMCommandScheme *commandScheme = [[HMCommandScheme alloc] init];
            commandScheme.pluginID = [oldCommand valueForKey:@"pluginID"];
            commandScheme.commandID = [oldCommand valueForKey:@"commandID"];
            [userCommandSchemes addObject:commandScheme];
        }
        
    }
    
    // Saving new data
    [self saveUserCommandsSchemes:[userCommandSchemes copy]];
    return [userCommandSchemes copy];
}


-(NSArray *)getSortedListOfAllPlugins {
    NSArray * sortedPlugins = [[allPlugins allValues] sortedArrayUsingComparator:^(id first, id second) {
        
        NSString *firstName = [first valueForKey:@"name"];
        NSString *secondName = [second valueForKey:@"name"];
        
        return [firstName compare:secondName];
        
    }];
    return sortedPlugins;
}


@end

