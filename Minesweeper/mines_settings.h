//
//  mines_settings.h
//  Minesweeper
//
//  Created by Rizwan Ahmad and Stephen Pluta on 4/21/14.
//  Copyright (c) 2014 Bay Trailers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mines_settings : NSObject

@property (nonatomic) int difficulty;

-(int)numberOfBombs;
+(mines_settings*)sharedSettings;

@end
