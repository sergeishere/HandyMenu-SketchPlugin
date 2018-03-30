//
//  HMPluginScheme.m
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 28/03/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

#import "HMPluginScheme.h"

@implementation HMPluginScheme

-(NSString *)description
{
    return [NSString stringWithFormat:@"<HMPluginScheme: %@, ID: %@, commands: %@>",
            [self name], [self identifier], [self commands]];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    id copy = [[[self class] alloc] init];
    [copy setName:[self name]];
    [copy setIdentifier:[self identifier]];
    [copy setCommands:[[self commands] copy]];
    return copy;
}

@end
