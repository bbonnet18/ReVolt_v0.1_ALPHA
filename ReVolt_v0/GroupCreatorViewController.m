//
//  GroupCreatorViewController.m
//  ReVolt_v0
//
//  Created by Ben Bonnet on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GroupCreatorViewController.h"

@interface GroupCreatorViewController ()

@end

@implementation GroupCreatorViewController

@synthesize opsQueue = _opsQueue;
@synthesize tags = _tags;
@synthesize context = _context;
@synthesize delegate = _delegate;
@synthesize groupName = _groupName;
@synthesize groupDescription = _groupDescription;
@synthesize cancelBtn = _cancelBtn;
@synthesize saveBtn = _saveBtn;
@synthesize group = _group;
@synthesize didMakeChanges = _didMakeChanges;
@synthesize editTextBtn = _editTextBtn;
@synthesize activeTextField = _activeTextField;
@synthesize msgLabel = _msgLabel;

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
    
    self.opsQueue = [[NSOperationQueue alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    self->groupIDNumber = nil;// set the groupIDNumber to nil so it can't return without getting one
    self->_didFinishEditing = YES;// set didFinishEditing to YES so the keyboard can be opened and closed
    self.didMakeChanges = NO;// set didMakeChanges to NO so we know when we've made changes
    [self requestNewGroupID];// attempt to get the newGroupID from the web service
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setSaveBtn:nil];
    [self setCancelBtn:nil];
    [self setGroupName:nil];
    [self setEditTextBtn:nil];
    [self setGroupDescription:nil];
    [self setTags:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];  
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)cancel:(id)sender{
    [self.delegate didCancelGroupCreation]; 
}

- (IBAction)saveGroup:(id)sender {
    // make sure there's something there
    if((![self.groupName.text length]) || (![self.groupDescription.text length])|| (![self.tags.text length])){// make sure text has been entered into the fields
        self.msgLabel.text = @"Fill in all fields";
        self.msgLabel.textColor = [UIColor redColor];
    }else {
        /* this needs to be modified in the delegate and on the protocol to provide back an object with just the text and then initiate the Group with all the default properties - see BuildMainEditScreen for how to create an MO */
        if(self->groupIDNumber != nil){// we have the unique id, now we need to create the group
            Group *g = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.context];
            g.name = self.groupName.text;// text user entered
            g.group_description = self.groupDescription.text;// text user entered
            g.leader = [[NSUserDefaults standardUserDefaults] valueForKey:@"userID"];// set the leader to the user since the user created the group
            g.date_created = [NSDate date];// today's date
            g.category_id = [NSNumber numberWithInt:999];// test category
            g.tags = self.tags.text;
            g.active = @"true";// 1 = active, 0 = inactive
            g.id = self->groupIDNumber;
            NSError *error;
            
            if(![self.context save:&error]){
                NSLog(@"%@", [error localizedFailureReason]);
            }
            
            
            [self.delegate didSaveGroup:g];
            
    
    }
    }
    
        
}

#pragma mark - Validate fields functions

-(BOOL) validateGroupData{// cycles through the user-entered data and returns true if the screen data is all correct
    
    return YES;
}

#pragma mark - Group creation methods

- (void) requestNewGroupID{// consolidated method launched on load view, this will start the process of getting the id
    
    NSURLRequest *req = [self getURLRequestForGroup];
    if(req!=nil){
        [self sendRequestForGroupID:req];
    }else {
        // launch alert view to tell the user that you can't contact the web service right now
        [self showErrorToUser];
    }
}

- (NSURLRequest*) getURLRequestForGroup;// queries the webservice to get the newest id from the service 
{
    // turn on the network indicator so the user knows that it's going out to the web 
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;// 
    
    NSString *baseURL = @"http://192.168.1.4/Revolt/returnUUID.php";// the url to reach out to get the UUID
    NSURL *url = [NSURL URLWithString:baseURL]; // create a URL object
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];// create a URLRequest Object
    if(!urlRequest){// if the creation process fails, set the indicator to not be visible and return nil
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        return  nil; 
    }
    return urlRequest;
}


-(void) sendRequestForGroupID:(NSURLRequest*) req// takes the url request as the argument makes a network call to return the UniqueID for the group
{
    [NSURLConnection sendAsynchronousRequest:req queue:self.opsQueue completionHandler:^(NSURLResponse *r, NSData *d, NSError *e){
        NSString *idstr = [[NSString alloc] initWithData: d encoding:NSUTF8StringEncoding];// make sure the response returned by the server is 
        // going to contain the id number         // we were either successful or unsuccessful, in either event, we need to  
        // set the network activity indicator to off
        
        
        idstr = [idstr substringFromIndex:5];
        
        
        if(!e){// if no errors, set the id for the group
            [self performSelectorOnMainThread:@selector(setIDForGroup:) withObject:idstr waitUntilDone:YES];
        }else{
            NSLog(@"error is: %@  ---- %@", [e localizedFailureReason], [e localizedDescription]);
            [self performSelectorOnMainThread:@selector(failedNetworkAttempt) withObject:nil waitUntilDone:YES];
        }
        
    }];

        
    }


- (void) setIDForGroup:(NSString*)idStr{// sets the private instance variable groupIDNumber so it can be used to set the group ID
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self->groupIDNumber = idStr;
}

- (void) failedNetworkAttempt{// alert the user that there is a problem creating the Group
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self showErrorToUser];
    
}

- (void) showErrorToUser{// launches an alert view, the entire process of creating a group will be aborted because the group can't be created without a successful call to the web service that provides the id
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error creating Object. Make sure you have a network connection and try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [av show];
    
}
#pragma mark - textField delegate methods

-(void) textFieldDidEndEditing:(UITextField *)textField{
    if(textField == self.groupName || textField == self.tags){
        [textField resignFirstResponder];
    }
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    self.activeTextField = textField;// assign private variable the value of the textField
    self.didMakeChanges = YES;// set the boolean to make sure we know things changed and can save before returning 
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if(textField == self.groupName || textField == self.tags)
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}



#pragma mark - keyboard methods
- (void)showKeyboard:(NSNotification*)aNotification
{

}
// this method is responsible for actually sizing the scroll view when the keyboard is present

- (void)hideKeyboard:(NSNotification*)aNotification
{
    
    
}
- (IBAction)editText:(id)sender {
    if(self->_didFinishEditing){
        TextEntryViewController *te = [[TextEntryViewController alloc] initWithNibName:@"TextEntryViewController" bundle:[NSBundle mainBundle]];
        te.delegate = self;
        [te showTextToEdit:self.groupDescription.text];
        [self presentModalViewController:te animated:YES];
    }
    
}

#pragma mark ScreenTextEditor protocol methods

- (void) didFinishEditingText:(NSString*) editedText{
    
    self.groupDescription.text = editedText;
    [self dismissModalViewControllerAnimated:YES];
    self->_didFinishEditing = YES;
}

#pragma mark textView methods


-(void) setDidFinishEditing:(BOOL) isFinished{
    self->_didFinishEditing = isFinished;
}

#pragma  mark AlertViewDelegate Methods
// close the alert view
- (void) alertViewCancel:(UIAlertView *)alertView{
    [self cleanup];
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate didCancelGroupCreation];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self cleanup];
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate didCancelGroupCreation];

    
}

#pragma mark - Cleanup method
- (void) cleanup{// clean up objects
    self->groupIDNumber = nil;
    [self.opsQueue cancelAllOperations];
    
}

@end
