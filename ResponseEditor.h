//
//  ResponseEditor.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Build.h"

@protocol ResponseEditor <NSObject>
@required

// returns the response for the responseID
-(Response*) getResponseByID:(int) responseID;

// adds the response to the post named in the postID
-(void) addResponseToPost:(int) postID response:(Response*) responseToAdd;

// returns an array of all the responses for a specific post
-(NSArray*) getResponsesForPost: (int) postID;


@end
