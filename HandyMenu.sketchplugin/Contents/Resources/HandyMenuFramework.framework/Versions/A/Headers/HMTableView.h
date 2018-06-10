//
//  HMTableView.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 29/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HMLog.h"

@protocol HMTableViewDelegate<NSObject>
@optional
-(void)deleteIsPressedInTableView:(id)tableView;
@end

@interface HMTableView : NSTableView

@end
