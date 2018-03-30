//
//  HMCommandScheme.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 27/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMCommandScheme : NSObject<NSCopying>

@property (nonatomic) NSString* pluginID;
@property (nonatomic) NSString* commandID;
@property (nonatomic) NSString* name;

@end
