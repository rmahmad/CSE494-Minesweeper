//
//  mines_SettingsViewController.h
//  Minesweeper
//
//  Created by spluta on 4/21/14.
//  Copyright (c) 2014 Bay Trailers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mines_SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
