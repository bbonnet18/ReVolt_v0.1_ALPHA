//
//  PostViewViewController.m
//  ReVolt_v0
//
//  Created by Ben Bonnet on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PostViewViewController.h"

@interface PostViewViewController ()

@end

@implementation PostViewViewController
@synthesize respondBtn;
@synthesize viewPostsBtn;
@synthesize thisPost = _thisPost;
@synthesize context = _context;

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
  
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setRespondBtn:nil];
    [self setViewPostsBtn:nil];
    [self setRespondBtn:nil];
    [self setViewPostsBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)viewWillAppear:(BOOL)animated{
     [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)respondToPost:(id)sender {
    ResponseCreatorViewController * responseCreator = [[ResponseCreatorViewController alloc] initWithNibName:@"ResponseCreatorViewController" bundle:[NSBundle mainBundle]];
    // add the post to the controller
    
    responseCreator.thisPost = self.thisPost;
    responseCreator.context = self.context;
    
    [self.navigationController pushViewController:responseCreator animated:YES];
    
}

- (IBAction)viewPosts:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
