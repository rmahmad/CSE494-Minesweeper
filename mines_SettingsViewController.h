//
//  mines_SettingsViewController.h
//  Minesweeper
//
//  Created by Rizwan Ahmad and Stephen Pluta on 4/21/14.
//  Copyright (c) 2014 Bay Trailers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mines_settings.h"

@interface mines_SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSIndexPath *lastIndexPath;

@end
