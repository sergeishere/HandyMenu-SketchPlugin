//
//  HandyMenu.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 13/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <HMPluginController.h>

@interface HandyMenu : NSObject

+ (void) initializePlugin;
+ (void) showMenu;
+ (void) showSettings;

@end
