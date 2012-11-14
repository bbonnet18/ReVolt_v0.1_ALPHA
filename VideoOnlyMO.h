//
//  VideoOnlyMO.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BuildItem.h"


@interface VideoOnlyMO : BuildItem

@property (nonatomic, retain) NSString * videoPath;
@property (nonatomic, retain) NSString * thumbnailImage;

@end
