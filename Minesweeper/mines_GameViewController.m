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
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    self.cells = [[NSMutableArray alloc] init];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [self.timer invalidate];
    [self.timeLabel setText:[NSString stringWithFormat:@"Current Time: %d:%02d", 0, 00]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 11;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1, 1, 4, 0);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [self.cells addObject:indexPath];
    cell.tag = [self.cells count] - 1;
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [cell addGestureRecognizer:tapScroll];
    
    cell.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    
    return cell;
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

- (void)tapped:(UIGestureRecognizer *)tap {
    NSIndexPath *temp = [self.cells objectAtIndex:tap.view.tag];
    NSUInteger indexes[2];
    [temp getIndexes:indexes];
    for(int i = 0; i < 2; i++) {
        NSLog(@"%lu",indexes[i]);
    }
    [self startTimer];
}

@end
