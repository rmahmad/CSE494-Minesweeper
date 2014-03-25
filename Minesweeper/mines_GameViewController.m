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
    
    //[self setupBoard];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
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
    
//    cell.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    
    return cell;
}

- (void)startTimer {
    self.timerStart = [NSDate date];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
}

- (IBAction)newGame:(id)sender {
    [self viewDidLoad];
    [(NSMutableArray *)self.logList addObject:[[NSArray alloc] initWithObjects:[self getTimerValue], @"helleo mat!", nil]];
    [self saveChecklistItems];
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

- (void)boardTapped:(UIGestureRecognizer *)tap {
    NSLog(@"Tapped");
    NSIndexPath *temp = [self.cells objectAtIndex:tap.view.tag];
    NSUInteger indexes[2];
    [temp getIndexes:indexes];
    for(int i = 0; i < 2; i++) {
        NSLog(@"%lu",indexes[i]);
    }
    if(self.timer == nil)
        [self startTimer];
}

- (void)boardHeld:(UIGestureRecognizer *)hold {
    if(hold.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Held");
        NSIndexPath *temp = [self.cells objectAtIndex:hold.view.tag];
        NSUInteger indexes[2];
        [temp getIndexes:indexes];
        for(int i = 0; i < 2; i++) {
            NSLog(@"%lu",indexes[i]);
        }
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

- (void)setupBoard
{
    int count = 0;
    int rand = 0;
    
    while (count < 10) {
        rand = arc4random_uniform(88);
        if (![[self.cells objectAtIndex:rand] isEqual: @"bomb"]) {
            [[self.cells objectAtIndex:rand] addObject:@"bomb"];
            count++;
        }
    }
    
    for (int i = 0; i < 88; i++) {
        if (![[self.cells objectAtIndex:i] isEqual: @"bomb"]) {
            [[self.cells objectAtIndex:i] addObject:@"safe"];
        }
        NSLog(@"%@",[self.cells objectAtIndex:i]);
    }
    
}

@end
