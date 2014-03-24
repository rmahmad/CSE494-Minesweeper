//
//  mines_GameViewController.h
//  Minesweeper
//
//  Created by Rizwan Ahmad on 3/20/14.
//  Copyright (c) 2014 Bay Trailers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mines_GameViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *startGameButton;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *flagLabel;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *timerStart;

- (void) timerCallback:(NSTimer *)timer;
- (NSString*) getTimerValue;
- (void) startTimer;
@end
