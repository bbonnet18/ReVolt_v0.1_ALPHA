//
//  TitleDescriptionView.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Build.h"
#import "Post.h"
#import "Group.h"

@interface TitleDescriptionView : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate>
{
    UITextField *_titleTxt;
    UITextView *_descriptionTxt;
    UITextView *_contextTxt;
    UIScrollView *_scrollView;
    BOOL _didMakeChanges;
    UITextField *activeField;
    UITextView *activeView; 
    Post *_thisPost;// the post that we'll create with this controller
    Group *_thisGroup;// the passed in group that we'll use to create the post
    BOOL descriptionFirstEdit;
    BOOL contextFirstEdit; 
    NSManagedObjectContext *_context;
}

//@property (strong, nonatomic) id <BuildEditor> delegate;
@property (strong, nonatomic) IBOutlet UITextField *titleTxt;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTxt;
@property (strong, nonatomic) IBOutlet UITextView *contextTxt;
@property (strong, nonatomic) Group *thisGroup;
@property (strong, nonatomic) Post *thisPost;
@property BOOL didMakeChanges;
- (void)next:(id)sender;
- (void)cancel:(id)sender;
- (void) showKeyboard: (NSNotification *) note;
- (void) hideKeyboard: (NSNotification *) note;
- (void) setupDoneBtn;
- (Boolean) savePost:(NSDictionary*) updates;// saves all the current information in the build
- (void) save:(id)sender;// calls the save process
- (void) setupToolBar;// this will setup the toolbar so it's able to take action

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSManagedObjectContext* context;// reference to the moc

@end
