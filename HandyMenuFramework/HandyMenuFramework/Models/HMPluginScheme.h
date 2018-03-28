//
//  HMPluginScheme.h
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 28/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HMCommandScheme.h>

@interface HMPluginScheme : NSObject

@property (nonatomic) NSString* identifier;
@property (nonatomic) NSString* name;

@property (nonatomic) NSArray* commands;

@end
