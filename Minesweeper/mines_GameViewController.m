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
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    self.flagCount = 0;
    [self.gameEnded setText:@""];
    self.gameEnded.hidden = YES;
    
    [self setupBoard];
    
    [self.timer invalidate];
    self.timer = nil;
    [self.timeLabel setText:[NSString stringWithFormat:@"Current Time: %d:%02d", 0, 00]];
    
    self.logList = [[NSMutableArray alloc] init];
    [self loadChecklistItems];
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
    static NSString *identifier = @"GameCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];
    NSString *imageName = [NSString stringWithFormat:@"closed.png"];
    cellImageView.image = [UIImage imageNamed:imageName];
    
    if(!self.cells)
        self.cells = [[NSMutableArray alloc] init];
    [self.cells addObject:indexPath];
    cell.tag = [self.cells count] - 1;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(boardTapped:)];
    [cell addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *hold = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(boardHeld:)];
    [cell addGestureRecognizer:hold];
    
    return cell;
}

- (void) resetCollectionView {
    for(int i = 0; i < 88; i++) {
        NSUInteger indexArray[] = {i/8, i%8};
        NSIndexPath *path = [[NSIndexPath alloc] initWithIndexes:indexArray length:2];
        
        NSString *image = [NSString stringWithFormat:@"closed.png"];
        
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:path];
        
        UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];;
        cellImageView.image = [UIImage imageNamed:image];
    }
}

- (void)startTimer {
    self.timerStart = [NSDate date];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    [self.timer invalidate];
}

- (IBAction)newGame:(id)sender {
    [self viewDidLoad];
    [self resetCollectionView];
}

- (void)timerCallback:(NSTimer *)timer {
    [self.timeLabel setText:[NSString stringWithFormat:@"Current Time: %@",[self getTimerValue]]];
}

- (void)updateFlagCount {
    [self.flagLabel setText:[NSString stringWithFormat:@"Flags Used: %d/10",self.flagCount]];
}

- (NSString*)getTimerValue {
    double totalSeconds = [[NSDate date] timeIntervalSinceDate:self.timerStart];
    int minutes = totalSeconds / 60;
    int seconds = (int)totalSeconds % (int) 60;
    return [NSString stringWithFormat:@"%d:%02d",minutes,seconds];
}

- (void)boardTapped:(UIGestureRecognizer *)tap {
    NSIndexPath *path = [self.cells objectAtIndex:tap.view.tag];
    NSUInteger indexes[2];
    [path getIndexes:indexes];
    unsigned long location = indexes[1] + (8*indexes[0]);
    [self open:location withIndex:path];
    if(self.timer == nil)
        [self startTimer];
}

- (void)boardHeld:(UIGestureRecognizer *)hold {
    if(hold.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *path = [self.cells objectAtIndex:hold.view.tag];
        NSUInteger indexes[2];
        [path getIndexes:indexes];
        unsigned long location = indexes[1] + (8*indexes[0]);
        [self flag:location withIndex:path];
        if(self.timer == nil)
            [self startTimer];
    }
}

- (NSString *)documentsDirectory
{
    return [@"~/Documents" stringByExpandingTildeInPath];
}

- (NSString *)dataFilePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"HighScores.plist"];
}

- (void)saveChecklistItems
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:self.logList forKey:@"HighScores"];
    
    //archiver won't do an encode until we tell it "finishEncoding"
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePath] atomically:YES];
}

- (void)loadChecklistItems
{
    // get our data file path
    NSString *path = [self dataFilePath];
    
    //do we have anything in our documents directory?  If we have anything then load it up
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        // make an unarchiver, and point it to our data
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        // We would like to unarchive the "ChecklistItems" key and get a reference to it
        self.logList = [unarchiver decodeObjectForKey:@"HighScores"];
        // we've finished choosing keys that we want, unpack them!
        [unarchiver finishDecoding];
    }
}

- (void)open:(unsigned long) location withIndex:(NSIndexPath *)indexPath {
    if(!self.gameEnded.hidden)
        return;
    
    if(![self.currentBoard[location] isEqual:@"open"] && ![self.currentBoard[location] isEqual:@"flagged"]) {
        if(![self.mines[location] isEqual:@"bomb"]) {
            NSString *image = [NSString stringWithFormat:@"open_%@.png",[self.mines objectAtIndex:location]];
            
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            
            UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];;
            cellImageView.image = [UIImage imageNamed:image];
            
            self.openCount++;
            if(self.openCount == 78) {
                [self stopTimer];
                [self gameWon];
                [self.gameEnded setText:@"Congratulations! You won!"];
                self.gameEnded.textColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
                self.gameEnded.hidden = NO;
                NSLog(@"Yay you won!");
            }
        }
        else {
            [self stopTimer];
            [self.gameEnded setText:@"You have lost!"];
            self.gameEnded.textColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
            self.gameEnded.hidden = NO;
            NSLog(@"LOL DIEEEE");
        }
    }
}

- (void)flag:(unsigned long) location withIndex:(NSIndexPath *)indexPath {
    if(!self.gameEnded.hidden)
        return;
    
    if([self.currentBoard[location] isEqual:@"closed"] && self.flagCount < 10) {
        NSString *image = [NSString stringWithFormat:@"flagged.png"];
        
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        
        UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];;
        cellImageView.image = [UIImage imageNamed:image];

        [self.currentBoard replaceObjectAtIndex:location withObject:@"flagged"];

        self.flagCount++;
        [self updateFlagCount];
    }
    else if([self.currentBoard[location] isEqual:@"flagged"]) {
        NSString *image = [NSString stringWithFormat:@"closed.png"];
        
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        
        UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];;
        cellImageView.image = [UIImage imageNamed:image];
        
        [self.currentBoard replaceObjectAtIndex:location withObject:@"closed"];
        
        self.flagCount--;
        [self updateFlagCount];
    }
}

- (void)setupBoard
{
    int count = 0;
    int rand = 0;
    int mineClose = 0;
    self.mines = [[NSMutableArray alloc] init];
    self.currentBoard = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 88; i++) {
        [self.mines addObject:@"safe"];
        [self.currentBoard addObject:@"closed"];
    }
    
    while (count < 10) {
        rand = arc4random_uniform(88);
        if ([[self.mines objectAtIndex:rand] isEqual:@"bomb"]) {
        } else {
            [self.mines replaceObjectAtIndex:rand withObject:@"bomb"];
            count++;
        }
    }
    
    for (int i = 0; i < 6; i++) {
        for (int j = 9; j < 79; j += 8) {
            mineClose = 0;
            if ([[self.mines objectAtIndex:(j+i)+7] isEqual:@"bomb"]) {
                mineClose++;
            }
            if ([[self.mines objectAtIndex:(j+i)+8] isEqual:@"bomb"]) {
                mineClose++;
            }
            if ([[self.mines objectAtIndex:(j+i)+9] isEqual:@"bomb"]) {
                mineClose++;
            }
            if ([[self.mines objectAtIndex:(j+i)-7] isEqual:@"bomb"]) {
                mineClose++;
            }
            if ([[self.mines objectAtIndex:(j+i)-8] isEqual:@"bomb"]) {
                mineClose++;
            }
            if ([[self.mines objectAtIndex:(j+i)-9] isEqual:@"bomb"]) {
                mineClose++;
            }
            if ([[self.mines objectAtIndex:(j+i)-1] isEqual:@"bomb"]) {
                mineClose++;
            }
            if ([[self.mines objectAtIndex:(j+i)+1] isEqual:@"bomb"]) {
                mineClose++;
            }
            if (![[self.mines objectAtIndex:j+i] isEqual:@"bomb"]) {
                [self.mines replaceObjectAtIndex:j+i withObject:[NSString stringWithFormat:@"%d", mineClose]];
            }
        }
    }
    
    for (int i = 1; i < 7; i++) {
        mineClose = 0;
        if ([[self.mines objectAtIndex:(i-1)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i+1)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i+7)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i+8)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i+9)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if (![[self.mines objectAtIndex:i] isEqual:@"bomb"]) {
            [self.mines replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%d", mineClose]];
        }
    }
    
    for (int i = 81; i < 87; i++) {
        mineClose = 0;
        if ([[self.mines objectAtIndex:(i-1)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i+1)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i-7)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i-8)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i-9)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if (![[self.mines objectAtIndex:i] isEqual:@"bomb"]) {
            [self.mines replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%d", mineClose]];
        }
    }
    
    for (int i = 8; i < 80; i += 8) {
        mineClose = 0;
        if ([[self.mines objectAtIndex:(i-8)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i+1)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i-7)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i+8)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i+9)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if (![[self.mines objectAtIndex:i] isEqual:@"bomb"]) {
            [self.mines replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%d", mineClose]];
        }
    }
    
    for (int i = 15; i < 87; i += 8) {
        mineClose = 0;
        if ([[self.mines objectAtIndex:(i-1)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i-9)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i-8)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i+7)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if ([[self.mines objectAtIndex:(i+8)] isEqual:@"bomb"]) {
            mineClose++;
        }
        if (![[self.mines objectAtIndex:i] isEqual:@"bomb"]) {
            [self.mines replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%d", mineClose]];
        }
    }
    
    int i = 0;
    mineClose = 0;
    if ([[self.mines objectAtIndex:(i+1)] isEqual:@"bomb"]) {
        mineClose++;
    }
    if ([[self.mines objectAtIndex:(i+8)] isEqual:@"bomb"]) {
        mineClose++;
    }
    if ([[self.mines objectAtIndex:(i+9)] isEqual:@"bomb"]) {
        mineClose++;
    }
    if (![[self.mines objectAtIndex:i] isEqual:@"bomb"]) {
        [self.mines replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%d", mineClose]];
    }
    
    i = 7;
    mineClose = 0;
    if ([[self.mines objectAtIndex:(i-1)] isEqual:@"bomb"]) {
        mineClose++;
    }
    if ([[self.mines objectAtIndex:(i+7)] isEqual:@"bomb"]) {
        mineClose++;
    }
    if ([[self.mines objectAtIndex:(i+8)] isEqual:@"bomb"]) {
        mineClose++;
    }
    if (![[self.mines objectAtIndex:i] isEqual:@"bomb"]) {
        [self.mines replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%d", mineClose]];
    }
    
    i = 80;
    mineClose = 0;
    if ([[self.mines objectAtIndex:(i+1)] isEqual:@"bomb"]) {
        mineClose++;
    }
    if ([[self.mines objectAtIndex:(i-8)] isEqual:@"bomb"]) {
        mineClose++;
    }
    if ([[self.mines objectAtIndex:(i-7)] isEqual:@"bomb"]) {
        mineClose++;
    }
    if (![[self.mines objectAtIndex:i] isEqual:@"bomb"]) {
        [self.mines replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%d", mineClose]];
    }
    
    i = 87;
    mineClose = 0;
    if ([[self.mines objectAtIndex:(i-1)] isEqual:@"bomb"]) {
        mineClose++;
    }
    if ([[self.mines objectAtIndex:(i-8)] isEqual:@"bomb"]) {
        mineClose++;
    }
    if ([[self.mines objectAtIndex:(i-9)] isEqual:@"bomb"]) {
        mineClose++;
    }
    if (![[self.mines objectAtIndex:i] isEqual:@"bomb"]) {
        [self.mines replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%d", mineClose]];
    }
}

- (void)gameWon
{
    [(NSMutableArray *)self.logList addObject:[[NSArray alloc] initWithObjects:[self getTimerValue], [self getDate], nil]];
    [self saveChecklistItems];
}

-(NSString *)getDate
{
    // Gets the current date and returns it as a string in the format of 02/19/14, 4:53 pm
    NSDate *date = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy, hh:mma"];
    NSString *strMyDate= [dateFormatter stringFromDate:date];
    return strMyDate;
}

@end
