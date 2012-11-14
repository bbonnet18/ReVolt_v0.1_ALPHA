//
//  TextAndImageMO.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BuildItem.h"


@interface TextAndImageMO : BuildItem

@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * screenText;

@end
