//
//  mines_ViewController.m
//  Minesweeper
//
//  Created by Rizwan Ahmad and Stephen Pluta on 3/20/14.
//  Copyright (c) 2014 Bay Trailers. All rights reserved.
//

#import "mines_ViewController.h"

@interface mines_ViewController ()

@end

@implementation mines_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Add our super cool minesweeper picture
    [self.mineImage addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VTN_Mine_Sweeper.jpg"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
