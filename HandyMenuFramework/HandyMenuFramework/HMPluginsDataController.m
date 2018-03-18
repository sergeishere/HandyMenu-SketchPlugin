//
//  HMPluginsDataController.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMPluginsDataController.h"

@implementation HMPluginsDataController

NSArray *allCommands;

+ (void)loadPlugins {
    id AppController = NSClassFromString(@"AppController");
    allCommands = [[AppController valueForKeyPath:@"sharedInstance.pluginManager.plugins"] allValues];
}

+(NSArray *)getSortedListOfPlugins {
    
    [HMPluginsDataController loadPlugins];
    
    NSArray * sortedPlugins = [allCommands sortedArrayUsingComparator:^(id first, id second) {
        
        NSString *firstName = [first valueForKey:@"name"];
        NSString *secondName = [second valueForKey:@"name"];
        
        return [firstName compare:secondName];
        
    }];
    return sortedPlugins;
}

@end
