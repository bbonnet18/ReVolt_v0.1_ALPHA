//
//  BuildItem.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Build;

@interface BuildItem : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * screenID;
@property (nonatomic, retain) NSString * screenTitle;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, assign) Boolean uploaded;
@property (nonatomic, retain) NSString * thumbnailPath;
@property (nonatomic, retain) Build *build;

@end
