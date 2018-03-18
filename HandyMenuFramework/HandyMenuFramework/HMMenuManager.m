//
//  HMMenuManager.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMMenuManager.h"

@implementation HMMenuManager

NSMenu *menu;

-(void)initializeMenu {
    menu = [[NSMenu alloc] init];
    [self updateMenu];
}

-(void)showMenu {
    [menu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
}

-(void)updateMenu {
    NSArray * sortedPlugins = [HMPluginsDataController getSortedListOfPlugins];
    for (id plugin in sortedPlugins)
    {
        NSString *pluginName = [plugin valueForKey:@"name"];
        
        if ([pluginName isEqualToString:@"SwiftPlugin"]) {
            continue;
        }
        
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:pluginName action:nil keyEquivalent:@""];
        NSMenu *subMenu = [[NSMenu alloc] init];
        menuItem.submenu = subMenu;
        [menu addItem:menuItem];
        
        NSDictionary *commands = [plugin valueForKey:@"commands"];
        
        for(NSString *commandKey in commands){
            
            id command = [commands objectForKey:commandKey];
            if ([command respondsToSelector:NSSelectorFromString(@"hasRunHandler")]) {
                if ((BOOL)objc_msgSend(command, NSSelectorFromString(@"hasRunHandler")) == YES) {
                    
                    NSString *commandName = [command valueForKey:@"name"];
                    
                    NSMenuItem *subMenuItem = [[NSMenuItem alloc] initWithTitle:commandName action:@selector(runCommand:) keyEquivalent:@""];
                    subMenuItem.target = self;
                    subMenuItem.representedObject = command;
                    //                [menu addItem:menuItem];
                    
                    [subMenu addItem:subMenuItem];
                }
            }
        }
    }
}

-(void) runCommand:(NSMenuItem *)sender {
    
    id MSDocument = NSClassFromString(@"MSDocument");
    id pluginContext = [MSDocument valueForKeyPath:@"currentDocument.pluginContext"];
    
    id runningCommand = [sender representedObject];
    SEL a_selector = NSSelectorFromString(@"runPluginCommand:fromMenu:context:");
    id delegate = [NSApp delegate];
    
    if ([delegate respondsToSelector:a_selector]) {
        objc_msgSend(delegate, a_selector, runningCommand, NO, pluginContext);
    }
    
    //  Alternative way:
    //      typedef void (*MethodType)(id, SEL, id, BOOL, id);
    //      MethodType methodToCall;
    //      methodToCall = (MethodType)[delegate methodForSelector:a_selector];
    //      methodToCall(delegate, a_selector, command, YES, context);
}

@end
