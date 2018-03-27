//
//  HMMenuManager.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <objc/message.h>

#define HMLog(fmt, ...) NSLog((@"HandyMenu (Sketch Plugin) %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@interface HMMenu : NSMenu

@property (nonatomic) BOOL groupComands;

-(id)init;
-(void)showMenu;
-(void)updateMenuFromCommandsList:(NSArray *)commands;


@end
