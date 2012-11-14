//
//  ResponseCreatorViewController.m
//  ReVolt_v0
//
//  Created by Ben Bonnet on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResponseCreatorViewController.h"

@interface ResponseCreatorViewController ()

@end

@implementation ResponseCreatorViewController
@synthesize titleTxt;
@synthesize responseBtn;
@synthesize cancelBtn; 
@synthesize thisPost = _thisPost;
@synthesize thisResponse = _thisResponse; 
@synthesize thisBuild = _thisBuild;
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
    if(self.thisResponse != nil){
        self.titleTxt.text = [self.thisResponse valueForKey:@"title"];
    }

}

- (void)viewDidUnload
{
    [self setTitleTxt:nil];
    [self setResponseBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)buildResponse:(id)sender {
    
    if(![self.titleTxt.text isEqualToString:@""]){
        
        if([self saveResponse]){
        
        
            Build *newBuild = (Build*) [NSEntityDescription insertNewObjectForEntityForName:@"Build" inManagedObjectContext:self.context];
            
            NSDate *today = [NSDate date];
            newBuild.creationDate = today;
            newBuild.status = @"edit";
            newBuild.buildID = [self thisResponse].id;// set to same as parent - Post
            [newBuild setResponse:self.thisResponse];
            [[self thisResponse] setBuild:newBuild];
            
        
        
        NSError *error;
        // if the save of the build was successful, then go to the editor
        if([self.context save:&error]){
            
            BuildMainEditScreen *buildMainEdit = [[BuildMainEditScreen alloc] initWithNibName:@"BuildMainEditScreen" bundle:[NSBundle mainBundle]];
            buildMainEdit.context = self.context;
            
            buildMainEdit.thisResponse = self.thisResponse;
            buildMainEdit.title = @"Post Builder";
            [self.navigationController pushViewController:buildMainEdit animated:YES];
            
        }
            
        }
    }
    
}

- (IBAction)cancel:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (Boolean) saveResponse{
    if(self.thisResponse == nil){// if it doesn't exist, then we create it
                
        
        self.thisResponse = (Response*) [NSEntityDescription insertNewObjectForEntityForName:@"Response" inManagedObjectContext:self.context];
        
        self.thisResponse.date_created = [NSDate dateWithTimeIntervalSinceNow:0];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
        
        self.thisResponse.title = @"";
        self.thisResponse.tags = @"";
        self.thisResponse.author_id = [NSNumber numberWithInt:5]; // this is test data
        self.thisResponse.status = @"edit";
        self.thisResponse.id = self.thisPost.id;
        [self.thisResponse setPost:[self thisPost]];// set the responses post to the post that was passed
        
    }
    
    [self.thisResponse setTitle:self.titleTxt.text];
    
    NSError *error;
   
    
    if([self.context save:&error]){
        return YES;
    }else{
         NSLog(@"error: %@ %@",[error localizedFailureReason],[error localizedDescription]);
        return NO; 
    }


    
}

#pragma mark - textField delegate methods
-(void) textFieldDidEndEditing:(UITextField *)textField{
  
        [textField resignFirstResponder];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
   
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
        [textField resignFirstResponder];
    
    return YES;
}


@end
