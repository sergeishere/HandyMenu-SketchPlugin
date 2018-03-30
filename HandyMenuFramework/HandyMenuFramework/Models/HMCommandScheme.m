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
    [encoder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if((self = [super init])) {
        self.pluginID = [decoder decodeObjectForKey:@"pluginID"];
        self.commandID  = [decoder decodeObjectForKey:@"commandID"];
        self.name  = [decoder decodeObjectForKey:@"name"];
    }
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"<HMCommandScheme: %@, pluginID: %@, commandID: %@>",
            [self name], [self pluginID], [self commandID]];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    id copy = [[[self class] alloc] init];
    [copy setName:[self name]];
    [copy setPluginID:[self pluginID]];
    [copy setPluginID:[self pluginID]];
    return copy;
}

@end
