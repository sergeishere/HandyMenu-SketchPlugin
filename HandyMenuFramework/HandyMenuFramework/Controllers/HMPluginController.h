//
//  HMPluginController.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 26/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HMDataProvider.h>
#import <HMMenu.h>
#import <HMSettingsWindowController.h>
#import <HMDataProvider.h>

#define HMLog(fmt, ...) NSLog((@"HandyMenu (Sketch Plugin) %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@interface HMPluginController : NSObject<HMDataProviderDelegate, HMSettingsWindowControllerDelegate>

-(id)init;
-(void)showMenu;
-(void)showSettings;


@end
