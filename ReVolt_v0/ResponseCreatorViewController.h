//
//  ResponseCreatorViewController.h
//  ReVolt_v0
//
//  Created by Ben Bonnet on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Response.h"
#import "Post.h"
#import "Build.h"
#import "BuildMainEditScreen.h"

@interface ResponseCreatorViewController : UIViewController <UITextInputDelegate> {
    Post * _thisPost;// the post that we will link to this response if the user chooses to save it or continue to build it
    Response * _thisResponse; // the response object that we will save if the user chooses to continue
    Build * _thisBuild;// the build that we will create and send to the Build Editor if they save
    NSManagedObjectContext * _context; // context so we can save the managed objects

}

@property (strong, nonatomic) IBOutlet UITextField *titleTxt;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *responseBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (strong, nonatomic) Post * thisPost;// the post passed in to this viewer
@property (strong, nonatomic) Response * thisResponse;// the response that we will create and attach to this post
@property (strong, nonatomic) Build *thisBuild;


@property (strong, nonatomic) NSManagedObjectContext* context;// reference to the moc

- (IBAction)buildResponse:(id)sender;// will save the response to the post
- (IBAction)cancel:(id)sender; // will return to the post viewer
- (Boolean) saveResponse;// saves the response and creates it if necessary

@end
