//
//  mines_SettingsViewController.m
//  Minesweeper
//
//  Created by spluta on 4/21/14.
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
	// Do any additional setup after loading the view.
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    
    self.tableView = tableView;
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
    
    // Only the top 10 highest scores should be shown
    /*if (indexPath.row < 10) {
        // Set the data for this cell to be from the logList
        cell.textLabel.text = [[self.logList objectAtIndex:indexPath.row] objectAtIndex:0];
        cell.detailTextLabel.text = [[self.logList objectAtIndex:indexPath.row] objectAtIndex:1];
        
        // Use the index number for the image
        NSString *imageName = [NSString stringWithFormat:@"%ld.jpg", indexPath.row + 1];
        cell.imageView.image = [UIImage imageNamed:imageName];
    }*/
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
