//
//  mines_GameViewController.m
//  Minesweeper
//
//  Created by Rizwan Ahmad and Stephen Pluta on 3/20/14.
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
    
    // Reset the flag count, number of open spaces, and update the flag label
    self.flagCount = 0;
    self.openCount = 0;
    [self updateFlagCount];
    
    // Hide the game over text in case it was showing, and set the gameOver boolean to false
    [self.gameEnded setText:@""];
    self.gameEnded.hidden = YES;
    self.gameOver = NO;
    
    // Randomly generate a board
    [self setupBoard];
    
    // Reset the timer and the timeLabel
    [self.timer invalidate];
    self.timer = nil;
    [self.timeLabel setText:[NSString stringWithFormat:@"Current Time: %d:%02d", 0, 00]];
    
    // Initialize log list, and populate it with the current high scores
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
    // There are 11 rows in the board
    return 11;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    // Set the margins of the tiles
    return UIEdgeInsetsMake(1, 1, 4, 0);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // There are 8 columns in the board
    return 8;
}

// Set up the initial collection view with cells that all dispaly that they are closed
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the current cell
    static NSString *identifier = @"GameCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    // Set the image in the cell to closed.png
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];
    NSString *imageName = [NSString stringWithFormat:@"closed.png"];
    cellImageView.image = [UIImage imageNamed:imageName];
    
    // Add the cell's index path to the cells array - this is used in the gesture recognizers
    if(!self.cells)
        self.cells = [[NSMutableArray alloc] init];
    [self.cells addObject:indexPath];
    cell.tag = [self.cells count] - 1;
    
    // Add tap and hold gesture recognizers to the cell
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(boardTapped:)];
    [cell addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *hold = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(boardHeld:)];
    [cell addGestureRecognizer:hold];
    
    return cell;
}

// Resets the collection view when new game is hit
- (void) resetCollectionView {
    // Iterate through the 88 cells
    for(int i = 0; i < 88; i++) {
        // Get the cell at the current location
        NSUInteger indexArray[] = {i/8, i%8};
        NSIndexPath *path = [[NSIndexPath alloc] initWithIndexes:indexArray length:2];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:path];
        
        // Set the image in the cell to closed.png
        NSString *image = [NSString stringWithFormat:@"closed.png"];
        UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];;
        cellImageView.image = [UIImage imageNamed:image];
    }
}

- (void)startTimer {
    // Set the timer start date to now, and start a timer that calls a callback method every 0.5 seconds
    self.timerStart = [NSDate date];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    // Stop the timers
    [self.timer invalidate];
    self.timer = nil;
}

- (IBAction)newGame:(id)sender {
    // If the new game button is pressed, reload the view and reset the collection view
    [self viewDidLoad];
    [self resetCollectionView];
}

- (void)timerCallback:(NSTimer *)timer {
    // When the timer calls back, set the timeLabel to display the current time
    [self.timeLabel setText:[NSString stringWithFormat:@"Current Time: %@",[self getTimerValue]]];
}

- (void)updateFlagCount {
    // Set the flagLabel to display the current number of used flags
    [self.flagLabel setText:[NSString stringWithFormat:@"Flags Used: %d/%d",self.flagCount, [[mines_settings sharedSettings] numberOfBombs]]];
}

// Convert the number of seconds the timer has been running to a minutes:seconds format
- (NSString*)getTimerValue {
    double totalSeconds = [[NSDate date] timeIntervalSinceDate:self.timerStart];
    int minutes = totalSeconds / 60;
    int seconds = (int)totalSeconds % (int) 60;
    return [NSString stringWithFormat:@"%d:%02d",minutes,seconds];
}

// Gesture recognizer for when a cell in the collection view is tapped
- (void)boardTapped:(UIGestureRecognizer *)tap {
    // Get the coordinates of the tapped cell, as well as its location in the mines/currentBoard array
    NSIndexPath *path = [self.cells objectAtIndex:tap.view.tag];
    NSUInteger indexes[2];
    [path getIndexes:indexes];
    unsigned long location = indexes[1] + (8*indexes[0]);
    
    // Open that location
    [self open:location withIndex:path];
    
    // If the timer has not been started yet, and the game is not over, start the timer
    if(self.timer == nil && !self.gameOver)
        [self startTimer];
}

// Gesture recognizer for when a cell in the collection view is held
- (void)boardHeld:(UIGestureRecognizer *)hold {
    if(hold.state == UIGestureRecognizerStateBegan) {
        // Get the coordinates of the held cell, as well as its location in the mines/currentBoard array
        NSIndexPath *path = [self.cells objectAtIndex:hold.view.tag];
        NSUInteger indexes[2];
        [path getIndexes:indexes];
        unsigned long location = indexes[1] + (8*indexes[0]);
        
        // Flag that location
        [self flag:location withIndex:path];
        
        // If the timer has not been started yet, and the game is not over, start the timer
        if(self.timer == nil && !self.gameOver)
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

// Save the loglist to HighScores.plist
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

// Opens a location on the board
- (void)open:(unsigned long) location withIndex:(NSIndexPath *)indexPath {
    // If the game has ended and a new game has not been started, do nothing
    if(!self.gameEnded.hidden)
        return;
    
    // Check to see if the location is already open or flagged by comparing it to the currentBoard array
    // If it is, then do nothing
    if(![self.currentBoard[location] isEqual:@"open"] && ![self.currentBoard[location] isEqual:@"flagged"]) {
        // Check to see if the location contains a bomb by comparing it to the minse array
        if(![self.mines[location] isEqual:@"bomb"]) {
            
            // If the location is not near any mines, then open up all the whitespace around it
            if([self.mines[location] isEqual:@"0"]) {
                [self uncoverWhitespace:location];
                self.openCount--;
            }
            
            // Set the image of the opening cell to the appropriate image - open_x.png, where x is the
            // number of mines around it
            NSString *image = [NSString stringWithFormat:@"open_%@.png",[self.mines objectAtIndex:location]];
            
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            
            UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];;
            cellImageView.image = [UIImage imageNamed:image];
            
            // Set this cell to "open" in the currentBoard array
            [self.currentBoard replaceObjectAtIndex:location withObject:@"open"];
            
            // Increment the count of opened spaces
            self.openCount++;
            
            // If 78 spaces have been opened, the game has been won
            if(self.openCount >= 88-[[mines_settings sharedSettings] numberOfBombs]) {
                [self stopTimer];
                [self gameWon];
                [self.gameEnded setText:@"Congratulations! You won!"];
                self.gameEnded.textColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
                self.gameEnded.hidden = NO;
                self.gameOver = YES;
            }
        }
        else {
            // If the current location contained a bomb, the game has been lost
            [self stopTimer];
            [self.gameEnded setText:@"You have lost!"];
            self.gameEnded.textColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
            self.gameEnded.hidden = NO;
            self.gameOver = YES;
            [self uncoverBombs];
        }
    }
}

- (void)flag:(unsigned long) location withIndex:(NSIndexPath *)indexPath {
    // If the game has ended and a new game has not been started, do nothing
    if(!self.gameEnded.hidden)
        return;
    
    // Check to see that the location is closed, and the player still has flags to put down
    if([self.currentBoard[location] isEqual:@"closed"] && self.flagCount < [[mines_settings sharedSettings] numberOfBombs]) {
        // Set the image of the current cell to flagged.png
        NSString *image = [NSString stringWithFormat:@"flagged.png"];
        
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        
        UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];;
        cellImageView.image = [UIImage imageNamed:image];
        
        // Set this cell to "flagged" in the currentBoard array
        [self.currentBoard replaceObjectAtIndex:location withObject:@"flagged"];
        
        // Increment the flagCount and update the flagLabel
        self.flagCount++;
        [self updateFlagCount];
    }
    // Check to see if the current location is already flagged. If it is, we need to unflag it
    else if([self.currentBoard[location] isEqual:@"flagged"]) {
        // Set the image of the cell to closed.png
        NSString *image = [NSString stringWithFormat:@"closed.png"];
        
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        
        UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];;
        cellImageView.image = [UIImage imageNamed:image];
        
        // Set this cell to "closed" in the currentBoard array
        [self.currentBoard replaceObjectAtIndex:location withObject:@"closed"];
        
        // Decrement the flagCount and update the flagLabel
        self.flagCount--;
        [self updateFlagCount];
    }
    else if([self.currentBoard[location] isEqual:@"open"]) {
        if(![self.mines[location] isEqual:@"bomb"]) {
            [self uncoverSafe:location];
        }
    }
}

// Uncover all the bombs - used when the player loses a game
- (void) uncoverBombs {
    // Iterate through the mines array
    for(int i = 0; i < 88; i++) {
        if([self.mines[i] isEqual:@"bomb"]) {
            // If the current location contains a bomb, set the image of the cell to open_bomb.png
            NSString *image = [NSString stringWithFormat:@"open_bomb.png"];
            NSUInteger indexArray[] = {i/8, i%8};
            NSIndexPath *path = [[NSIndexPath alloc] initWithIndexes:indexArray length:2];
            
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:path];
            
            UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];;
            cellImageView.image = [UIImage imageNamed:image];
        }
    }
}

- (void) uncoverSafe:(unsigned long) location {
    
    // Set the constraints that we will loop through - this makes sure we don't try to open
    // cells that do not exist in the collection view (e.g. (-1, 0) or (12,9))
    int i_min = -1;
    int i_max = 2;
    int j_min = -1;
    int j_max = 2;
    
    // If we are on the top row, do not try to go to the previous row
    if(location%8 == 0)
        j_min = 0;
    // If we are on the bottom row, do not try to go to the next row
    else if(location%8 == 7)
        j_max = 1;
    
    // If we are on the left column, do not try to go to the previous column
    if(location/8 == 0)
        i_min = 0;
    // If we are on the right column, do not try to go to the next column
    else if(location/8 == 10)
        i_max = 1;
    
    int count = 0;
    // Iterate through all the surrounding locations to obtain the number of nearby flags
    for(int i = i_min; i < i_max; i++) {
        for(int j = j_min; j < j_max; j++) {
            unsigned long surroundingLocation = location + (i*8) + j;
            
            if([self.currentBoard[surroundingLocation] isEqual:@"flagged"]) {
                count += 1;
            }
        }
    }
    
    // Only open safe squares if the the number of surrounding flags is equal to the number on that tile
    if(count == [[self.mines objectAtIndex:location] integerValue]) {
        // Iterate through all the surrounding locations
        for(int i = i_min; i < i_max; i++) {
            for(int j = j_min; j < j_max; j++) {
                unsigned long surroundingLocation = location + (i*8) + j;
                
                // Check to see that the currently selected surrounding location is closed and not a flag
                if(![self.currentBoard[surroundingLocation] isEqual:@"flagged"] && [self.currentBoard[surroundingLocation] isEqual:@"closed"]) {
                    
                    // Call the open whitespaces function
                    if([[self.mines objectAtIndex:surroundingLocation] isEqual:@"0"]) {
                        [self uncoverWhitespace:surroundingLocation];
                    }
                    
                    // Trigger a gameover if a bomb was opened
                    if([[self.mines objectAtIndex:surroundingLocation] isEqual:@"bomb"]) {
                        // If the current location contained a bomb, the game has been lost
                        [self stopTimer];
                        [self.gameEnded setText:@"You have lost!"];
                        self.gameEnded.textColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
                        self.gameEnded.hidden = NO;
                        self.gameOver = YES;
                        [self uncoverBombs];
                    }
                    
                    // If it is, open it and set the image to open_x.png where x is the number of mines around
                    NSString *image = [NSString stringWithFormat:@"open_%@.png",[self.mines objectAtIndex:surroundingLocation]];
                    NSUInteger indexArray[] = {surroundingLocation/8, surroundingLocation%8};
                    NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:indexArray length:2];
                    
                    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
                    
                    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];;
                    cellImageView.image = [UIImage imageNamed:image];
                    
                    // Set the location in the currentBoard array to open
                    [self.currentBoard replaceObjectAtIndex:surroundingLocation withObject:@"open"];
                    self.openCount++;
                }
            }
        }
    }
    
    // If the openCount gets to 88 minus the total bombs, then the game has been won
    if(self.openCount >= 88-[[mines_settings sharedSettings] numberOfBombs]) {
        [self stopTimer];
        [self gameWon];
        [self.gameEnded setText:@"Congratulations! You won!"];
        self.gameEnded.textColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
        self.gameEnded.hidden = NO;
        self.gameOver = YES;
    }
}

// Uncover whitespace - recursively called function which uncovers all whitespace (tiles with no bombs
// around) surrounding a location
- (void) uncoverWhitespace:(unsigned long) location {
    
    // Set the constraints that we will loop through - this makes sure we don't try to open
    // cells that do not exist in the collection view (e.g. (-1, 0) or (12,9))
    int i_min = -1;
    int i_max = 2;
    int j_min = -1;
    int j_max = 2;
    
    // If we are on the top row, do not try to go to the previous row
    if(location%8 == 0)
        j_min = 0;
    // If we are on the bottom row, do not try to go to the next row
    else if(location%8 == 7)
        j_max = 1;
    
    // If we are on the left column, do not try to go to the previous column
    if(location/8 == 0)
        i_min = 0;
    // If we are on the right column, do not try to go to the next column
    else if(location/8 == 10)
        i_max = 1;
    
    // Iterate through all the surrounding locations
    for(int i = i_min; i < i_max; i++) {
        for(int j = j_min; j < j_max; j++) {
            unsigned long surroundingLocation = location + (i*8) + j;
            
            // Check to see that the currently selected surrounding location is closed
            if([self.currentBoard[surroundingLocation] isEqual:@"closed"]) {
                // If it is, open it and set the image to open_x.png where x is the number of mines around
                NSString *image = [NSString stringWithFormat:@"open_%@.png",[self.mines objectAtIndex:surroundingLocation]];
                NSUInteger indexArray[] = {surroundingLocation/8, surroundingLocation%8};
                NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:indexArray length:2];
                
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
                
                UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];;
                cellImageView.image = [UIImage imageNamed:image];
                
                // Set the location in the currentBoard array to open
                [self.currentBoard replaceObjectAtIndex:surroundingLocation withObject:@"open"];
                self.openCount++;
                
                // If the currently selected location has no mines around it, then call this method on
                // that location as well
                if([[self.mines objectAtIndex:surroundingLocation] isEqual:@"0"])
                    [self uncoverWhitespace:surroundingLocation];
            }
        }
    }
    
    // If the openCount gets to 78, then the game has been won
    if(self.openCount >= 88-[[mines_settings sharedSettings] numberOfBombs]) {
        [self stopTimer];
        [self gameWon];
        [self.gameEnded setText:@"Congratulations! You won!"];
        self.gameEnded.textColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
        self.gameEnded.hidden = NO;
        self.gameOver = YES;
    }
}

// Initialize the playing board by randomly generating locations for mines
- (void)setupBoard
{
    int count = 0;
    int rand = 0;
    int mineClose = 0;
    self.mines = [[NSMutableArray alloc] init];
    self.currentBoard = [[NSMutableArray alloc] init];
    
    // Initialize the mines and currentBoard arrays
    for (int i = 0; i < 88; i++) {
        [self.mines addObject:@"safe"];
        [self.currentBoard addObject:@"closed"];
    }
    
    // Generate 10 random numbers between 0 and 87 and set those locations in the mines array
    // to "bomb". These are the locations that will contain bombs in the game
    while (count < [[mines_settings sharedSettings] numberOfBombs]) {
        rand = arc4random_uniform(88);
        if ([[self.mines objectAtIndex:rand] isEqual:@"bomb"]) {
        } else {
            [self.mines replaceObjectAtIndex:rand withObject:@"bomb"];
            count++;
        }
    }
    
    // Go through all the locations that are not on the edges, and determine how many mines are near them
    // Then set their value in the mines array to this number
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
    
    // Go through all the locations that are on the top row, and determine how many mines are near them
    // Then set their value in the mines array to this number
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
    
    // Go through all the locations that are on the bottom row, and determine how many mines are near them
    // Then set their value in the mines array to this number
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
    
    // Go through all the locations that are on the left edge, and determine how many mines are near them
    // Then set their value in the mines array to this number
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
    
    // Go through all the locations that are on the right edge, and determine how many mines are near them
    // Then set their value in the mines array to this number
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
    
    // Go through all the locations that are on the corners, and determine how many mines are near them
    // Then set their value in the mines array to this number. This happens four times - one for each corner
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

// If the game has been won, log the current time and save the logList to HighScores.plist
- (void)gameWon
{
    // Get the current timer value
    self.timeVal = [self getTimerValue];

    // Show an alert that llows the user to input their name for high score purposes
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations! You won!" message:@"Please enter your name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [alert addButtonWithTitle:@"Go"];
    [alert show];
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // When the alert view is dismissed
    if (alertView.tag == 1) {
        if(buttonIndex == 1) {
            // Get the name
            UITextField *textfield = [alertView textFieldAtIndex:0];
            self.name = textfield.text;

            // Populate the loglist with relevant info
            [(NSMutableArray *)self.logList addObject:[[NSArray alloc] initWithObjects:self.timeVal, [self getDate], self.name, nil]];
            
            // Save the loglist
            [self saveChecklistItems];
        }
    }
}

@end
