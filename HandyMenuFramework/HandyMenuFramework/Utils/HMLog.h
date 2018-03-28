//
//  HMLog.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 29/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#define HMLog(fmt, ...) NSLog((@"HandyMenu (Sketch Plugin) %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
