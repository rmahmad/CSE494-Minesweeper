//
//  mines_HighScoresViewController.m
//  Minesweeper
//
//  Created by Rizwan Ahmad and Stephen Pluta on 3/20/14.
//  Copyright (c) 2014 Bay Trailers. All rights reserved.
//

#import "mines_HighScoresViewController.h"

@interface mines_HighScoresViewController ()

@property (strong, nonatomic) NSArray *logList;
@property (strong, nonatomic) NSArray *sortedList;

@end

@implementation mines_HighScoresViewController

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
    // Initialize all the Parse objects here
    self.parseQuery = [PFQuery queryWithClassName:@"highscores"];
    self.parseObject = [self.parseQuery getFirstObject];
    
    // Load scores from Parse
    self.logList = [[NSMutableArray alloc] init];
    [self loadChecklistItems];

    // Sort the array from lowest time to highest
    NSArray *sortedArray = [self.logList sortedArrayUsingComparator:^(id a, id b) {
        return [a[0] compare:b[0]];
    }];
    self.logList = sortedArray;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)documentsDirectory
{
    return [@"~/Documents" stringByExpandingTildeInPath];
}

- (NSString *)dataFilePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"HighScores.plist"];
}

- (void)loadChecklistItems
{
    // Retrieve the high scores and store them in loglist
    if(self.parseObject)
    {
        self.logList = [NSKeyedUnarchiver unarchiveObjectWithData:[self.parseObject objectForKey:@"highscores"]];
    }
}

- (void)saveChecklistItems
{
    // If the object already exists then save it
    if(self.parseObject)
    {
        [self.parseObject setObject:[NSKeyedArchiver archivedDataWithRootObject:self.logList] forKey:@"highscores"];
        [self.parseObject save];
    }
    // If the object doesn't exists yet then create it before saving
    else
    {
        self.parseObject = [PFObject objectWithClassName:@"highscores"];
        [self.parseObject setObject:[NSKeyedArchiver archivedDataWithRootObject:self.logList] forKey:@"highscores"];
        [self.parseObject save];
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.logList.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BasicCell"];
    }
    
    // Only the top 10 highest scores should be shown
    if (indexPath.row < 10) {
        // Set the data for this cell to be from the logList
        cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [[self.logList objectAtIndex:indexPath.row] objectAtIndex:0], [[self.logList objectAtIndex:indexPath.row] objectAtIndex:2]];
        cell.detailTextLabel.text = [[self.logList objectAtIndex:indexPath.row] objectAtIndex:1];
        
        // Use the index number for the image
        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", indexPath.row + 1];
        cell.imageView.image = [UIImage imageNamed:imageName];
    }
    
    return cell;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    // Set keys for what to decode
    if ((self = [super init])){
        self.logList = [aDecoder decodeObjectForKey:@"logList"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    // Set keys for what to encode
    [aCoder encodeObject:self.logList forKey:@"logList"];
}

@end
