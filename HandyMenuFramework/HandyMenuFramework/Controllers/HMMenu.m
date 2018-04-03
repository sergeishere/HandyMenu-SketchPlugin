//
//  HMMenuManager.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMMenu.h"

@implementation HMMenu

-(id)init {
    self = [super init];
    
    return self;
}

-(void)showMenu {
    [self popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
}

-(void)updateMenuFromCommandsList:(NSArray *)commands {
    
    [self removeAllItems];
    
    // Checking if a user has added commands
    if (commands.count > 0) {
        
        NSString *lastPluginIdentifier = nil;
        
        for (id command in commands) {
            if ([command respondsToSelector:NSSelectorFromString(@"hasRunHandler")]) {
                if ((BOOL)objc_msgSend(command, NSSelectorFromString(@"hasRunHandler")) == YES) {
                    
                    if (_groupComands) {
                        NSString *pluginIdentifier = [command valueForKeyPath:@"pluginBundle.identifier"];
                        if(lastPluginIdentifier != nil && lastPluginIdentifier != pluginIdentifier){
                            [self addItem:[NSMenuItem separatorItem]];
                        }
                        lastPluginIdentifier = pluginIdentifier;
                    }
                    
                    
                    
                    NSString *commandName = [command valueForKey:@"name"];
                    
                    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:commandName action:@selector(runCommand:) keyEquivalent:@""];
                    menuItem.target = self;
                    menuItem.representedObject = command;
                    
                    [self addItem:menuItem];
                }
            }
        }
    } else {
        
        // If a user doesn't have added commands we show hint
        
        NSMenuItem *hintItem = [[NSMenuItem alloc] initWithTitle:@"No added plugins" action:nil keyEquivalent:@""];
        [self addItem:hintItem];
        
        [self addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *settingsItem = [[NSMenuItem alloc] initWithTitle:@"Settings" action:@selector(showSettings) keyEquivalent:@""];
        settingsItem.target = self;
        [self addItem:settingsItem];
        
    }
    
    //    for (id plugin in commands) {
    //        NSString *pluginName = [plugin valueForKey:@"name"];
    //
    //        if ([pluginName isEqualToString:@"HandyMenu"]) {
    //            continue;
    //        }
    //
    //        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:pluginName action:nil keyEquivalent:@""];
    //        NSMenu *subMenu = [[NSMenu alloc] init];
    //        menuItem.submenu = subMenu;
    //        [self addItem:menuItem];
    //
    //        NSDictionary *commands = [plugin valueForKey:@"commands"];
    //
    //        for(NSString *commandKey in commands){
    //
    //            id command = [commands objectForKey:commandKey];
    //            if ([command respondsToSelector:NSSelectorFromString(@"hasRunHandler")]) {
//                    if ((BOOL)objc_msgSend(command, NSSelectorFromString(@"hasRunHandler")) == YES) {
    //
    //                    NSString *commandName = [command valueForKey:@"name"];
    //
    //                    NSMenuItem *subMenuItem = [[NSMenuItem alloc] initWithTitle:commandName action:@selector(runCommand:) keyEquivalent:@""];
    //                    subMenuItem.target = self;
    //                    subMenuItem.representedObject = command;
    //                    //                [menu addItem:menuItem];
    //
    //                    [subMenu addItem:subMenuItem];
    //                }
    //            }
    //        }
    //    }
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

-(void)showSettings {
    [HandyMenu showSettings];
}



@end
