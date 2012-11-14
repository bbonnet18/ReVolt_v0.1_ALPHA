//
//  PostEditor.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

@protocol PostEditor <NSObject>
@required

// returns a post object based on the postID provided. This should
// query all post objects in CoreData and retrieve the one that matches
// up with the postID provided
-(Post*) getPostByID:(int)postID;

// takes a post object as an argument and adds that post object to the group identified in the groupID
-(void) addPostToGroup:(int) groupID post:(Post*)postToAdd;

// returns an array of all the posts for a group based on the groupID
-(NSArray*) getPostsForGroup:(int) groupID;

@optional

// queries the main application for next postID, will need a post id generator scheme to do that
-(int) getNewPostID;
@end
