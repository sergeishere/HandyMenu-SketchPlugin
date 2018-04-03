//
//  HMSettingsWindowViewController.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 03/04/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol HMSettingsWindowViewControllerDelegate<NSObject>
@optional

-(void)settingsWindowViewController:(id)settingsWindowViewController viewWillLayout:(NSView *)view;

@end

@interface HMSettingsWindowViewController : NSViewController

@property (weak) id<HMSettingsWindowViewControllerDelegate> delegate;

@end
