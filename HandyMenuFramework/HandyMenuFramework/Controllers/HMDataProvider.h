//
//  HMPluginsDataController.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HMCommandScheme.h>
#import <HMPluginScheme.h>

#define HMLog(fmt, ...) NSLog((@"HandyMenu (Sketch Plugin) %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@protocol HMDataProviderDelegate<NSObject>
@required

-(void)dataProviderWasUpdated:(id)dataProvider withNewCommandsSchemes:(id)schemes;

@end

@interface HMDataProvider : NSObject

-(id)init;
-(void)loadData;

-(NSArray *)getPluginsSchemes;
-(NSArray *)getUserCommandsSchemes;

-(void)updatedUserCommandsSchemes:(NSArray *)newCommandSchemes;

-(NSArray *)getUserCommands;

@property (weak) id<HMDataProviderDelegate> delegate;

@end
