//
//  HMCommandScheme.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 27/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMCommandScheme.h"

@implementation HMCommandScheme

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.pluginID forKey:@"pluginID"];
    [encoder encodeObject:self.commandID forKey:@"commandID"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if((self = [super init])) {
        self.pluginID = [decoder decodeObjectForKey:@"pluginID"];
        self.commandID  = [decoder decodeObjectForKey:@"commandID"];
    }
    return self;
}

@end
