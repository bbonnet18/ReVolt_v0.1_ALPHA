//
//  Group.h
//  ReVolt_v0
//
//  Created by Ben Bonnet on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * active;
@property (nonatomic, retain) NSNumber * category_id;
@property (nonatomic, retain) NSDate * date_created;
@property (nonatomic, retain) NSString * group_description;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * leader;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSSet *posts;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addPostsObject:(Post *)value;
- (void)removePostsObject:(Post *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
