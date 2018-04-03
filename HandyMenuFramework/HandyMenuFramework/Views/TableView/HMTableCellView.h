//
//  HMTableCellView.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 02/04/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HMTableCellView : NSTableCellView


@property (weak) IBOutlet NSTextField *commandName;
@property (weak) IBOutlet NSTextField *pluginName;

@end
