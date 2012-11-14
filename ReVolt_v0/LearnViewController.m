//
//  LearnViewController.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LearnViewController.h"
#import "FirstLearnViewController.h"
#import "SecondLearnViewController.h" 

@implementation LearnViewController
@synthesize navController; 
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - NavDelegate methods



#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
 
    UIView *mView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];// initiate the view with the screen
    
    mView.backgroundColor = [UIColor blueColor];
    UILabel *mainLabel = [[UILabel alloc] init];
    mainLabel.text = @"Main View Controller";
    
    [mView addSubview:mainLabel];
    self.view = mView;
    
//    FirstLearnViewController *fl = [[FirstLearnViewController alloc] initWithNibName:@"FirstLearnViewController" bundle:[NSBundle mainBundle]];
//    
//    //fl.navdelegate = self;
//    
//    self.navController = [[UINavigationController alloc] initWithRootViewController:fl];
//    
//    
//    
//    self.view = self.navController.view;
    

}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
