//
//  TemplatePicker.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TemplatePicker.h"


@implementation TemplatePicker
@synthesize cancelBtn = _cancelBtn;
@synthesize textAndImageBtn = _textAndImageBtn;
@synthesize textAndVideoBtn = _textAndVideoBtn;
@synthesize textAndAudioBtn = _textAndAudioBtn;
@synthesize videoOnlyBtn =  _videoOnlyBtn;
@synthesize delegate = _delegate;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setTextAndImageBtn:nil];
    [self setTextAndVideoBtn:nil];
    [self setTextAndAudioBtn:nil];
    [self setVideoOnlyBtn:nil];
    [self setCancelBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)selectTemplate:(id)sender{
    
    NSString *title =  [sender currentTitle];
        // this is not evaluating!!
    [self.delegate didChooseTemplate:title];
   
}

- (IBAction)cancel:(id)sender{
    [self.delegate userDidCancel];
}

@end
