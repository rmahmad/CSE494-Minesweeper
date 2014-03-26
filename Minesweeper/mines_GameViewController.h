//
//  mines_GameViewController.h
//  Minesweeper
//
//  Created by Rizwan Ahmad on 3/20/14.
//  Copyright (c) 2014 Bay Trailers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mines_GameViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *startGameButton;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *flagLabel;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *timerStart;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *cells;
@property (strong, nonatomic) NSArray *logList;
@property (strong, nonatomic) NSMutableArray *mines;
@property (strong, nonatomic) NSMutableArray *currentBoard;
@property (strong, nonatomic) IBOutlet UILabel *gameEnded;
@property int flagCount;
@property int openCount;
@property bool gameOver;

- (void) timerCallback:(NSTimer *)timer;
- (NSString*) getTimerValue;
- (void) startTimer;
- (IBAction)newGame:(id)sender;
- (void)setupBoard;
- (void)open:(unsigned long) location withIndex:(NSIndexPath *)indexPath;
- (void)gameWon;
@end
