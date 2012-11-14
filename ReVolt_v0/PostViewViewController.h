//
//  PostViewViewController.h
//  ReVolt_v0
//
//  Created by Ben Bonnet on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResponseCreatorViewController.h"
#import "Post.h"
#import "Response.h"

@interface PostViewViewController : UIViewController
{
    Post *_thisPost;// the post provided to this controller, will be used to retrieve the responses if there are any
    NSManagedObjectContext *_context;
    
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *respondBtn;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *viewPostsBtn;
@property (strong, nonatomic) Post *thisPost;
@property (strong, nonatomic) NSManagedObjectContext *context;
// will launch the response creator
- (IBAction)respondToPost:(id)sender;

// will go back to the posts manager controller
- (IBAction)viewPosts:(id)sender;
@end
