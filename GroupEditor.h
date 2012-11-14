//
//  GroupEditor.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"

@protocol GroupEditor <NSObject>
@required

// Gets the group identified with the groupID and returns that group object
-(Group*)getGroupByGroupID:(int) groupID;

// Takes a new Group as an argument and adds that to the groups array in the main application
-(void) addGroupToGroups:(Group*) newGroup;


// deactivates the group, makes it so no additional posts, responses, comments etc. can be added
// this can only be done by a group leader or by administrators
-(void) deactivateGroup:(int)groupID;

- (NSManagedObjectContext*)getMOC;

@end
