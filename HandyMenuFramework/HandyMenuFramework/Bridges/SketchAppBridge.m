//
//  SketchAppBridge.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "SketchAppBridge.h"
#import "AppKit/Appkit.h"

@implementation SketchAppBridge

@synthesize installedPlugins;

// MARK: - Singletone
+ (SketchAppBridge*)sharedInstance {
    static SketchAppBridge *mySharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedInstance = [[self alloc] init];
    });
    return mySharedInstance;
}

- (id)init {
    if (self = [super init]) {
        id AppController = NSClassFromString(@"AppController");
        installedPlugins = [AppController valueForKeyPath:@"sharedInstance.pluginManager.plugins"];
    }
    return self;
}

-(void)runSketchPluginCommand:(NSString*)commandID from:(NSString*)pluginID {
    
    id command = [[[installedPlugins valueForKey:pluginID] valueForKey:@"commands"] valueForKey:commandID];
    
    id MSDocument = NSClassFromString(@"MSDocument");
    id pluginContext = [MSDocument valueForKeyPath:@"currentDocument.pluginContext"];
    
    SEL a_selector = NSSelectorFromString(@"runPluginCommand:fromMenu:context:");
    id delegate = [NSApp delegate];
    
    if ([delegate respondsToSelector:a_selector]) {
        typedef void (*MethodType)(id, SEL, id, BOOL, id);
        MethodType methodToCall;
        methodToCall = (MethodType)[delegate methodForSelector:a_selector];
        methodToCall(delegate, a_selector, command, YES, pluginContext);
    }
}

@end
