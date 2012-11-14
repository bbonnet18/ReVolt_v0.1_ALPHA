//
//  Post.h
//  ReVolt_v0
//
//  Created by Ben Bonnet on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Build, Group, Response;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSNumber * author_id;
@property (nonatomic, retain) NSDate * date_created;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * media_url;
@property (nonatomic, retain) NSString * post_description;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Build *build;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) NSSet *responses;
@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addResponsesObject:(Response *)value;
- (void)removeResponsesObject:(Response *)value;
- (void)addResponses:(NSSet *)values;
- (void)removeResponses:(NSSet *)values;

@end
