//
//  mines_settings.m
//  Minesweeper
//
//  Created by spluta on 4/21/14.
//  Copyright (c) 2014 Bay Trailers. All rights reserved.
//

#import "mines_settings.h"

@implementation mines_settings

static mines_settings* theSettings = nil;

-(int)numberOfBombs
{
    return (self.difficulty * 5) + 10;
}

+(mines_settings*)sharedSettings
{
    if(theSettings == nil)
        theSettings = [[mines_settings alloc] init];
    return theSettings;
}



@end
