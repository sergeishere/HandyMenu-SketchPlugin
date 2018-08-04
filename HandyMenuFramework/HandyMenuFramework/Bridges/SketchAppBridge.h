//
//  SketchAppBridge.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SketchAppBridge : NSObject {
    id installedPlugins;
}

@property (nonatomic, retain) id installedPlugins;

+(SketchAppBridge*)sharedInstance;

-(void)runSketchPluginCommand:(NSString*)commandID from:(NSString*)pluginID;
-(BOOL)isExists:(NSString *)pluginID with:(NSString*)commandID;

@end
