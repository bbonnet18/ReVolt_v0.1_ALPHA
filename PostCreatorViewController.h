//
//  PostCreatorViewController.h
//  ReVolt_v0
//
//  Created by Ben Bonnet on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@protocol PostCreatorProtocol 



@end

@interface PostCreatorViewController : UIViewController

{
        BOOL _didMakeChanges;
    id <PostCreatorProtocol> _delegate; // delegate will accept the post we create
    Post *_myPost; // this is the post that we will create and send back to the delegate


}

@property BOOL didMakeChanges;// this BOOL changes to YES anytime the user changes any of the text, graphics or video associated with the editor
//@property (strong, nonatomic) BuildItem *buildItem;

@property id <PostCreatorProtocol> delegate;
@property (nonatomic,strong) Post *myPost;


@end
