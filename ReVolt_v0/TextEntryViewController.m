//
//  TextEntryViewController.m
//  ReVolt_v0
//
//  Created by Ben Bonnet on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextEntryViewController.h"

@interface TextEntryViewController ()

@end


#define int heightLimit = 50;
@implementation TextEntryViewController
@synthesize mainTextView;
@synthesize scrollerView = _scrollerView;
@synthesize delegate = _delegate;
@synthesize saveBtn;
@synthesize textToEdit = _textToEdit;
@synthesize lineLimit = _lineLimit;
@synthesize charactersLimit = _charactersLimit;
@synthesize totalLines = _totalLines;
@synthesize charLimit = _charLimit;
@synthesize linesLimit = _linesLimit;
@synthesize oldHeight = _oldHeight;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.delegate setDidFinishEditing:NO];
        self.lineLimit = 2; 
        self.charactersLimit = 140;
        self.oldHeight = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFrame:) name:UITextViewTextDidChangeNotification object:nil];
    self.mainTextView.text = self.textToEdit;
    self.totalLines = 0;

    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setMainTextView:nil];
    [self setCharLimit:nil];
    [self setLinesLimit:nil];
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];  
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return (UIInterfaceOrientationIsPortrait(interfaceOrientation) || UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

- (void) showTextToEdit:(NSString *)editText{
    self.textToEdit = editText;
}

-(void) textViewDidBeginEditing:(UITextView *)textView{
    
}


-(void) textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    
    
}

// receive this delegate method when the user enters text

-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    BOOL underCharLimit = NO;// set boolean to check when finished with other checks
    
    // set a variable equal to the current text plus new text - the range, the range
    // will be 0 if the user is typing and 1 if delete is pressed
    NSInteger newLength = [textView.text length] + [text length] - range.length;
    
    NSInteger remainingChar = self.charactersLimit - newLength;// the available length remaining
    
    self.charLimit.text = [NSString stringWithFormat:@"%@",[[NSNumber numberWithInt:remainingChar] stringValue]];
    
    if(newLength < 140){
        underCharLimit = YES;
    }
    
    // Check to see if we're at the line limit and under the character limit
    if([self checkLines:text textInRange:range] == YES && underCharLimit == YES){
        [self.mainTextView setBackgroundColor:[UIColor whiteColor]];
        return YES;
    }else{
        [self.mainTextView setBackgroundColor:[UIColor redColor]];
        return NO;
    }
        
}

- (BOOL) checkLines:(NSString *)textToAdd textInRange:(NSRange)range{
    /* until we can get this all worked out, then we are going to simply use the text count*/
//    CGSize sz = CGSizeMake(self.mainTextView.frame.size.width, self.mainTextView.frame.size.height);
//    // create a temporary view with the new measurements to see if it will work
//    UITextView *temp = [[UITextView alloc] initWithFrame:CGRectMake(self.mainTextView.frame.origin.x, self.mainTextView.frame.origin.y, self.mainTextView.frame.size.width, self.mainTextView.frame.size.height)];
//    
//    temp.text = self.mainTextView.text;
//    [temp sizeToFit];
//    
//    CGFloat height = temp.contentSize.height;// contentSize is the content size in the TextView, which is a subclass of scrollview, so it's the size of the actual content, not the bounding box
//    
//    // if the height changes, then change the total lines, then check against the line limit
//        
//    
//    BOOL isDelete = NO;
//    if(textToAdd.length == 0 && range.length == 1)
//        isDelete = YES;
//    if(height < 50 || isDelete == YES){
//        
//        self.linesLimit.text = @"";
//        self.linesLimit.textColor = [UIColor clearColor];
//        return YES;
//        // this may be a performance problem though, so should look for 
//        // a way to check if it's currently equal to it. 
//    }else {
//        self.linesLimit.text = @"Line limit";
//        self.linesLimit.textColor = [UIColor redColor];
//        return NO;
//    }
    return YES;
    
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
        [self.mainTextView resignFirstResponder];
    
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{

        [self.mainTextView becomeFirstResponder];

}

- (void)showKeyboard:(NSNotification*)aNotification
{
    [self showKeyboardInView:aNotification];
    
}
// this method is responsible for actually sizing the scroll view when the keyboard is present
- (void) showKeyboardInView:(NSNotification *)aNotification{
    NSDictionary* info = [aNotification userInfo];
    CGSize sz = CGSizeMake(480.0, 216.0);
    self->_keyboardSize = sz;//[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self->_oldInsets = self.scrollerView.contentInset;
    self->_oldScrollIndicatorInsets = self.scrollerView.scrollIndicatorInsets;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self->_keyboardSize.height, 0.0);
    self.scrollerView.contentInset = contentInsets;// set content inset so the content window area is inset and allows us to scroll to the right place. 
    self.scrollerView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGFloat padding = 10.0;
    
    
    CGRect f = self.mainTextView.frame;// get the frame of the textView, it may change as we edit it and we'll have to update that ---!!!!
    CGRect r = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    r = [self.view convertRect:r fromView:nil];
    self->_currentKeyboard = r;
    
    CGRect aRect = self.view.frame;// the frame's view rect for the entire view
    aRect.size.height -= self->_keyboardSize.height;// shorten this now because the keyboard is on it
    NSLog(@"minY: %f",CGRectGetMaxY(f));
    NSLog(@"frame.size: %f and contentSize: %f",f.size.height, self.mainTextView.contentSize.height);
    CGPoint scroller = CGPointMake(0.0, CGRectGetMinY(f) + f.size.height);
    
    if (!CGRectContainsPoint(aRect, scroller) ) {// check to see if the rect we create contains the text view
        CGFloat yVal = scroller.y;
        CGFloat newY = yVal -self->_currentKeyboard.size.height + padding;
        CGPoint scrollPoint = CGPointMake(0.0, newY);// calculating the difference here tells us that the content should move up only the distance between the y location of the textview and height of the keyboard size. Think about it like where it was before, minus the keyboard height that's now taking up space on the screen.;
        [self.scrollerView setContentOffset:scrollPoint animated:YES];
    }
    
}


- (void)doneEditingAction:(id)sender
{
	// finish typing text/dismiss the keyboard by removing it as the first responder
    [self.mainTextView resignFirstResponder];
	self.navigationItem.rightBarButtonItem = nil;
    [self.navigationController setNavigationBarHidden:YES];
}

// handles changing the frame so the text can work in either orientation

-(void) changeFrame:(NSNotification *)note{
    
    
    
    CGRect frame = self.mainTextView.frame;
    UIScrollView *sv = (UIScrollView*)self.mainTextView;
    frame.size.height = sv.contentSize.height + 20.0;
    sv.frame = frame;
    
    if(sv.contentSize.height != self->_oldFrame.size.height){
        CGFloat sizeDiff = sv.contentSize.height - self->_oldFrame.size.height;
        [self updateFrame:sizeDiff];//self.mainTextView.contentSize.height];
    }
    
    self->_oldFrame = sv.frame;
    
}

- (void) updateFrame: (CGFloat) newHeight{
    CGFloat padding = 10.0;
    CGSize newSize = CGSizeMake(self.scrollerView.contentSize.width, self.scrollerView.contentSize.height + newHeight + padding);
    self.scrollerView.contentSize = newSize;// set the content size appropriately
    
    CGRect aRect = self.view.frame;// the frame's view rect for the entire view
    aRect.size.height -= self->_currentKeyboard.size.height;//this shrinks the box so we know if the new point is within it
    
    CGPoint scroller = CGPointMake(0.0, self.mainTextView.frame.origin.y + self.mainTextView.frame.size.height+5.0);
    
    if (!CGRectContainsPoint(aRect, scroller) ) {// check to see if the rect we create contains the text view
        CGFloat yVal = scroller.y;
        CGFloat newY = yVal-self->_currentKeyboard.size.height + padding;
        CGPoint scrollPoint = CGPointMake(0.0, newY);// calculating the difference here tells us that the content should move up only the distance between the y location of the textview and height of the keyboard size. Think about it like where it was before, minus the keyboard height that's now taking up space on the screen.;
        [self.scrollerView setContentOffset:scrollPoint animated:YES];
    }
    
}

- (void)hideKeyboard:(NSNotification*)aNotification
{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollerView.contentInset = contentInsets;
    self.scrollerView.scrollIndicatorInsets = contentInsets;
}


- (IBAction)save:(id)sender {
    [self.mainTextView resignFirstResponder];
    [self.delegate didFinishEditingText:self.mainTextView.text];
}
@end
