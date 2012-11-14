//
//  TextAndAudioMO.h
//  ReVolt_v0
//
//  Created by Ben Bonnet on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BuildItem.h"


@interface TextAndAudioMO : BuildItem

@property (nonatomic, retain) NSString * audioPath;
@property (nonatomic, retain) NSString * screenText;

@end
