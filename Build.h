//
//  Build.h
//  ReVolt_v0
//
//  Created by Ben Bonnet on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BuildItem, Post, Response;

@interface Build : NSManagedObject

@property (nonatomic, retain) NSNumber * buildID;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSSet *buildItems;
@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) Response *response;
@end

@interface Build (CoreDataGeneratedAccessors)

- (void)addBuildItemsObject:(BuildItem *)value;
- (void)removeBuildItemsObject:(BuildItem *)value;
- (void)addBuildItems:(NSSet *)values;
- (void)removeBuildItems:(NSSet *)values;

@end
