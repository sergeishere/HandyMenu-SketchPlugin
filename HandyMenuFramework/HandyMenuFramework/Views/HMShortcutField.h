//
//  HMShortcutField.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 17/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define HMLog(fmt, ...) NSLog((@"HandyMenu (Sketch Plugin) %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@interface HMShortcutField : NSTextField

@end
