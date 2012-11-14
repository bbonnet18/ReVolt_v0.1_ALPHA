//
//  BuildStartVC.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BuildStartVC.h"
#import "UploadsViewController.h"
#import "UploadViewer.h"
#import "GroupsManagerViewController.h"

@implementation BuildStartVC
@synthesize myBuildsBtn = _myBuildsBtn;
@synthesize groupsBtn = _groupsBtn;
//@synthesize delegate = _delegate;
@synthesize context = _context;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - goToMyBuilds

-(IBAction)goToMyBuilds:(id)sender{
    
    UploadsViewController *uv = [[UploadsViewController alloc] initWithStyle:UITableViewStylePlain];
    
    
    //uv.delegate = [self delegate];
    uv.context = self.context;
    [self.navigationController pushViewController:uv animated:YES];
   
}

-(IBAction)goToGroups:(id)sender{
    GroupsManagerViewController *gv = [[GroupsManagerViewController alloc] initWithNibName:@"GroupsManagerViewController" bundle:[NSBundle mainBundle]];
    
    gv.context = [self context];
   
    [self.navigationController pushViewController:gv animated:YES];
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setMyBuildsBtn:nil];
    [self setContext:nil];
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
