//
//  Response.h
//  ReVolt_v0
//
//  Created by Ben Bonnet on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Build, Comment, Post;

@interface Response : NSManagedObject

@property (nonatomic, retain) NSNumber * author_id;
@property (nonatomic, retain) NSDate * date_created;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Build *build;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) Post *post;
@end

@interface Response (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
