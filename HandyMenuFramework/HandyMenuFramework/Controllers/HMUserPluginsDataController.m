//
//  HMPluginsDataController.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMUserPluginsDataController.h"

@implementation HMUserPluginsDataController

NSArray *allCommands;
NSMutableArray *userCommands;

+ (void)loadPlugins {
    id AppController = NSClassFromString(@"AppController");
    allCommands = [[AppController valueForKeyPath:@"sharedInstance.pluginManager.plugins"] allValues];
    [self loadUserPlugins];
}

+(NSArray *)getSortedListOfAllPlugins {
    
    NSArray * sortedPlugins = [allCommands sortedArrayUsingComparator:^(id first, id second) {
        
        NSString *firstName = [first valueForKey:@"name"];
        NSString *secondName = [second valueForKey:@"name"];
        
        return [firstName compare:secondName];
        
    }];
    return sortedPlugins;
}

+(NSArray *)getListOfUserPlugins {
    HMLog(@"requesting user commands: %@", userCommands);
    return [userCommands copy];
}


+(void)loadUserPlugins{
    
    userCommands = [[NSMutableArray alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *encodedUserCommands = [[userDefaults stringForKey:@"plugin_sketch_handymenu_my_commands"] stringByRemovingPercentEncoding];
    NSData *decodedUserCommands = [encodedUserCommands dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError;
    NSDictionary *userCommandsDictionary = [NSJSONSerialization JSONObjectWithData:decodedUserCommands options:NSJSONReadingMutableContainers error:&jsonError];
    NSArray *userCommandsList = [userCommandsDictionary objectForKey:@"list"];
    
    for (NSDictionary *command in userCommandsList) {
        
        if ([[command valueForKey:@"type"]  isEqual: @"command"]) {
        
            for (id plugin in allCommands) {
                
                if([[plugin valueForKey:@"identifier"] isEqual:[command valueForKey:@"pluginID"]]){
                    
                    NSDictionary *pluginCommands = [plugin valueForKey:@"commands"];
                    
                    for (NSString *pluginIdentifier in pluginCommands){
                        HMLog(@"%@", [pluginCommands objectForKey:pluginIdentifier]);
                        if([pluginIdentifier isEqual:[command valueForKey:@"commandID"]]) {
                            HMLog(@"%@", [pluginCommands objectForKey:pluginIdentifier]);
                            [userCommands addObject:[pluginCommands objectForKey:pluginIdentifier]];
                        }

                    }

                }
            }
        }
        
    }
}

@end
