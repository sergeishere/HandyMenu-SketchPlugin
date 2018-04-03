//
//  HMSettingsWindowViewController.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 03/04/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMSettingsWindowViewController.h"

@interface HMSettingsWindowViewController ()

@end

@implementation HMSettingsWindowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillLayout {
    if (_delegate != nil && [_delegate conformsToProtocol:@protocol(HMSettingsWindowViewControllerDelegate)]) {
        [_delegate settingsWindowViewController:self viewWillLayout:self.view];
    }
}

@end
