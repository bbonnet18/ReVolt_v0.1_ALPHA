//
//  GroupDetailViewController.m
//  ReVolt_v0
//
//  Created by Ben Bonnet on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GroupDetailViewController.h"

@interface GroupDetailViewController ()

@end

@implementation GroupDetailViewController
@synthesize groupNameLabel = _groupNameLabel;
@synthesize groupTagsLabel = _groupTagsLabel;
@synthesize okBtn = _okBtn;
@synthesize groupDescriptionText = _groupDescriptionText;
@synthesize delegate = _delegate;
@synthesize myGroup = _myGroup;
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
    [self loadGroupInfo:self.myGroup];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setGroupNameLabel:nil];
    [self setGroupTagsLabel:nil];
    [self setOkBtn:nil];
    [self setGroupDescriptionText:nil];
    [self setContext:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - loadGroupInfo method

// load the data into the fields
- (void) loadGroupInfo:(Group*) group{
    self.groupNameLabel.text = group.name;
    self.groupDescriptionText.text = group.group_description;
    self.groupTagsLabel.text = group.tags;
    // check to see if user is the group leader, if so, give them the activate/deactivate option
    NSNumber *n = group.leader;// group leader
    NSNumber *i = [[NSUserDefaults standardUserDefaults] valueForKey:@"userID"];// user id
    if([i isEqualToNumber:n]){
        
        [self buildDeactivateBtn];
        
    }

}

- (void) showDeactivateMsg:(id)sender{
    UIAlertView *alertMsg = [[UIAlertView alloc] initWithTitle:@"Deactivate?" message:@"Deactivating a group results in an unuasable group. No one will be able to post or respond with this group. Do you want to continue." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    [alertMsg show];
 
}

- (void) buildDeactivateBtn{
    UIButton *deactivateBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deactivateBtn setFrame:CGRectMake(200.0, self.okBtn.frame.origin.y, 100.0, 25.0)];
    
    NSString *btnTitle = @"Deactivate";
    CGFloat f = 1.0;
    if([self.myGroup.active isEqualToString:@"false"]){// if it's already inactive, set it's state poperly
        btnTitle = @"inactive";
        f = 0.5;
        deactivateBtn.enabled = NO;
    }
   
    deactivateBtn.tag = 1000;// set's a tag number so it can be retrieved 
    [deactivateBtn setTitle:btnTitle forState:UIControlStateNormal];
    [deactivateBtn sizeToFit];
    [deactivateBtn setAlpha:f];
    
    [deactivateBtn addTarget:self action:@selector(showDeactivateMsg:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:deactivateBtn];
}

// calls the delegate method to dismiss this viewer
- (IBAction)returnToGroupsViewer:(id)sender {
    
    [self.delegate didDismissGroupDetailView];
}

// save the group as inactive and return to the groups manager
-(void) deactivateAndDismiss{
    NSError *error;
    
    self.myGroup.active = @"false";
    
    if(![self.context save:&error]){
        NSLog(@"%@", [error localizedFailureReason]);
    }
    
    [self.delegate didDismissGroupDetailView];
}

#pragma mark UIAlertViewProtocol methods

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    // if user said it was ok to deactivate it, deactivate it and set the button's states to the proper values
    if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]){
        UIButton *deactivateBtn = (UIButton*)[self.view viewWithTag:1000];
        [deactivateBtn setTitle:@"inactive" forState:UIControlStateNormal];
        [deactivateBtn setAlpha:0.5];
        [self deactivateAndDismiss];
    }
    
    
}

-(void)alertViewCancel:(UIAlertView *)alertView{
    [self dismissModalViewControllerAnimated:YES];
}
@end
