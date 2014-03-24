//
//  mines_GameViewController.m
//  Minesweeper
//
//  Created by Rizwan Ahmad on 3/20/14.
//  Copyright (c) 2014 Bay Trailers. All rights reserved.
//

#import "mines_GameViewController.h"

@interface mines_GameViewController ()

@end

@implementation mines_GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped)];
    [self.collectionView addGestureRecognizer:tapScroll];
    
    [self.timer invalidate];
    [self.timeLabel setText:[NSString stringWithFormat:@"Current Time: %d:%02d", 0, 00]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startTimer {
    self.timerStart = [NSDate date];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
}

- (IBAction)newGame:(id)sender {
    [self viewDidLoad];
}

- (void)timerCallback:(NSTimer *)timer {
    [self.timeLabel setText:[NSString stringWithFormat:@"Current Time: %@",[self getTimerValue]]];
}

- (NSString*)getTimerValue {
    double totalSeconds = [[NSDate date] timeIntervalSinceDate:self.timerStart];
    int minutes = totalSeconds / 60;
    int seconds = (int)totalSeconds % (int) 60;
    return [NSString stringWithFormat:@"%d:%02d",minutes,seconds];
}

- (void)tapped {
    [self startTimer];
}

@end
