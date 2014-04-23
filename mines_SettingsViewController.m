//
//  mines_SettingsViewController.m
//  Minesweeper
//
//  Created by Rizwan Ahmad and Stephen Pluta on 4/21/14.
//  Copyright (c) 2014 Bay Trailers. All rights reserved.
//

#import "mines_SettingsViewController.h"

@interface mines_SettingsViewController ()

@end

@implementation mines_SettingsViewController


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
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BasicCell"];
    }
    
    // Make an array with three different difficulties
    NSArray *options = [NSArray arrayWithObjects:@"Easy", @"Medium", @"Hard", nil];
    
    // Set the cells to the corresponding difficulties
    cell.textLabel.text = [options objectAtIndex:indexPath.row];
    
    // Sets the checkmark for the selected cell
    if ([indexPath compare:self.lastIndexPath] == NSOrderedSame)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set the difficulty to the cell that was selected
    self.lastIndexPath = indexPath;
    [[mines_settings sharedSettings] setDifficulty: (int)indexPath.row];
    
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
