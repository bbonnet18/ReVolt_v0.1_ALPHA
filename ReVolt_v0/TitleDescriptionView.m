//
//  TitleDescriptionView.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TitleDescriptionView.h"
#import "BuildMainEditScreen.h"


@implementation TitleDescriptionView
@synthesize scrollView = _scrollView;
@synthesize titleTxt = _titleTxt;
@synthesize descriptionTxt = _descriptionTxt;
@synthesize contextTxt = _contextTxt;
@synthesize didMakeChanges = _didMakeChanges;
@synthesize context = _context;
@synthesize thisGroup = _thisGroup;
@synthesize thisPost = _thisPost;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.didMakeChanges = NO;
        self->descriptionFirstEdit = YES;
        self->contextFirstEdit = YES;
        self.title = @"Info";
    }
    NSLog(@"loaded nib");
    

    return self;
}


- (void)next:(id)sender{

        
        NSArray *keys = [NSArray arrayWithObjects:@"title", @"post_description", nil];
        NSArray *objs = [NSArray arrayWithObjects:self.titleTxt.text, self.descriptionTxt.text, nil];
        
        NSDictionary *changesDictionary = [[NSDictionary alloc] initWithObjects:objs forKeys:keys];
        
        // if the save was successful, create the build
        if([self savePost:changesDictionary]){
            
            // create the new Build 
            
            if([self.thisPost valueForKey:@"build"] == nil){
                Build *newBuild = (Build*) [NSEntityDescription insertNewObjectForEntityForName:@"Build" inManagedObjectContext:self.context];
                
                NSDate *today = [NSDate date];
                newBuild.creationDate = today;
                newBuild.status = @"edit";
                newBuild.buildID = [self thisPost].id;// set to same as parent - Post
                [newBuild setPost:[self thisPost]];
                [[self thisPost] setBuild:newBuild];
                
            }
            
            NSError *error;
            // if the save of the build was successful, then go to the editor
            if([self.context save:&error]){
            
                BuildMainEditScreen *buildMainEdit = [[BuildMainEditScreen alloc] initWithNibName:@"BuildMainEditScreen" bundle:[NSBundle mainBundle]];
                buildMainEdit.context = self.context;
                
                buildMainEdit.thisPost = self.thisPost;
                buildMainEdit.title = @"Post Builder";
                [self.navigationController pushViewController:buildMainEdit animated:YES];

             }
            
        }

    
}

- (void)cancel:(id)sender{
    
    // this will send it to the root view controller, changes will not be saved
    [self.navigationController popViewControllerAnimated:YES];
    
  
}

- (void) save:(id)sender{
    
    if(self.didMakeChanges){
        NSMutableDictionary *changes = [[NSMutableDictionary alloc] init];
        [changes setValue:self.titleTxt.text forKey:@"title"];
        [changes setValue:self.descriptionTxt.text forKey:@"post_description"];
        
        [self savePost:changes];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
    NSLog(@"loaded the view");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    
    // if the post was provided by the previous controller, then we're in edit mode, not create mode, so load the data from this one to the template
    if(self.thisPost != nil){
        self.titleTxt.text = [self.thisPost valueForKey:@"title"];
        self.descriptionTxt.text = [self.thisPost valueForKey:@"post_description"];
    }
    
}

- (void) viewWillAppear:(BOOL)animated{
    [self setupToolBar];
}

- (void) viewWillDisappear:(BOOL)animated{
    
}

- (void)viewDidUnload
{
    [self setTitleTxt:nil];
    [self setDescriptionTxt:nil];
    [self setContextTxt:nil];
    [self setScrollView:nil];
     [self setThisGroup:nil];
    [self setThisPost:nil];
    // unregister the keyboard notification
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


-(void) viewWillUnload{
    NSString *st = @"testing";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||  UIInterfaceOrientationIsLandscape(interfaceOrientation));
}
// 

#pragma mark - textField delegate methods
-(void) textFieldDidEndEditing:(UITextField *)textField{
    if(textField == self.titleTxt){
        [textField resignFirstResponder];
    }
}

-(void) textFieldDidBeginEditing:(UITextField *)textField{
    self.didMakeChanges = YES;
    activeField = textField;// assign p[rivate variable the value of the textField
   
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    self.didMakeChanges = YES;
    if(textField == self.titleTxt)
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - textView delegate methods

-(void) textViewDidBeginEditing:(UITextView *)textView{
    
    self.didMakeChanges = YES;
    
    activeView = textView;
   
    [self setupDoneBtn];
    
}

-(void) textViewDidEndEditing:(UITextView *)textView{
     [textView resignFirstResponder];
  
}


- (void) setupDoneBtn{
    UIBarButtonItem* doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditingAction:)];
	self.navigationItem.rightBarButtonItem = doneItem;
}

- (void) setupToolBar{
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] ;
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    UIBarButtonItem *nextBtn = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(next:)];
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] ;
//    UIBarButtonItem *showDeleteMessage = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteItemMsg:)];
    
    NSArray *toolBarItemArray = [NSArray arrayWithObjects:saveBtn,leftSpace,cancelBtn,nextBtn,rightSpace, nil];
    
    [self setToolbarItems:toolBarItemArray];
    [self.navigationController setToolbarHidden:NO];
    
}

- (void)doneEditingAction:(id)sender
{
	// finish typing text/dismiss the keyboard by removing it as the first responder
    [activeView resignFirstResponder];
	self.navigationItem.rightBarButtonItem = nil;
}
 
- (void)deleteItemMsg:(id)sender{
    
    UIAlertView *alertMsg = [[UIAlertView alloc] initWithTitle:@"Delete Post?" message:@"Are you sure you want to delete this post before you publish it? You will not be able to access this post after you delete it" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    [alertMsg show];
    
     
}



- (void)showKeyboard:(NSNotification*)note
{
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeView.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeView.frame.origin.y-kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)hideKeyboard:(NSNotification*)note
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


#pragma mark - alertview delegate methods
// this will handle the cancel event for the alertview
//- (void) alertViewCancel:(UIAlertView *)alertView{
//    
//}
//// this will handle the event if the user taps the 'delete' btn, therefore deleting the item
//- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
//    // if they choose to delete
//    if(buttonIndex != 0){
////        NSUInteger currentBuildIndex = [self.delegate getCurrentBuildIndex];
////        [self.delegate deleteBuildAtIndex:currentBuildIndex];
//        if([self deletePost]){
//             [self.navigationController popViewControllerAnimated:YES];
//            NSLog(@"SUCCESS DELETING");
//        }else{
//            
//            NSLog(@"FAULT in DELETING");
//        }
//        
//       
//    }
//}

//-(Boolean)deletePost{
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Build" inManagedObjectContext:self.context];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setEntity:entityDescription];
//    
//    NSString *predString = [NSString stringWithFormat:@"buildID == %@",[self.delegate getCurrentBuildID]];
//    NSLog(@"%@",predString);
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"buildID == %@",[self.delegate getCurrentBuildID]];
//    [request setPredicate:predicate];
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
//    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//    
//    NSError *error = nil;
//    NSArray *results = [self.context executeFetchRequest:request error:&error];
//    Build *b = [results objectAtIndex:0];
    
    
//    [self.thisBuild removeBuildItems:self.thisBuild.buildItems];
//    
//    [self.context deleteObject:self.thisBuild];
//    NSError *nError;
//    return [self.context save:&nError];
 //   return YES;
//}

// creates a post and a build and connects them
-(Boolean)savePost:(NSDictionary*)updates{
    
    
   
    // create the new post 
    
    if(self.thisPost == nil){// if it doesn't exist, then we create it
        // get the old number from the userDefaults and change it for the new number, then
        // replace that number in userDefaults        
        NSNumber *oldID = [[NSUserDefaults standardUserDefaults] valueForKey:@"buildID"];
        NSInteger oldInt = [oldID intValue];
        NSInteger newInt = oldInt +1;
        
        NSNumber* newID = [NSNumber numberWithInt:newInt];
        [[NSUserDefaults standardUserDefaults] setValue:newID forKey:@"buildID"]; 
        self.thisPost = (Post*) [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.context];
        self.thisPost.date_created = [NSDate dateWithTimeIntervalSinceNow:0];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
        
        NSString *formattedDateString = [dateFormatter stringFromDate:self.thisPost.date_created];
        
        self.thisPost.status = @"edit";
        self.thisPost.id = newID;
        [self.thisPost setGroup:[self thisGroup]];// set the post's group to the group that was passed
    }
    
    [self.thisPost setValuesForKeysWithDictionary:updates];
    
    NSError *error;
    NSLog(@"error: %@",[error localizedDescription]);
    
    if([self.context save:&error]){
        return YES;
    }else{
        return NO; 
    }
     
}


@end
