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
#import "HMLog.h"
#import <HandyMenu.h>

@interface HMMenu : NSMenu

@property (nonatomic) BOOL groupComands;

-(id)init;
-(void)showMenu;
-(void)updateMenuFromCommandsList:(NSArray *)commands;


@end
