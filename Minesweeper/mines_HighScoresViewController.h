//
//  mines_HighScoresViewController.h
//  Minesweeper
//
//  Created by Rizwan Ahmad and Stephen Pluta on 3/20/14.
//  Copyright (c) 2014 Bay Trailers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface mines_HighScoresViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PFQuery *parseQuery;
@property (strong, nonatomic) PFObject *parseObject;

@end
