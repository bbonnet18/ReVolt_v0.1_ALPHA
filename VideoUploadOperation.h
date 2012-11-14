//
//  VideoUploadOperation.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VideoUploadOperation : NSOperation
{
    NSString *_videoID;
}

@property (strong) NSData *movieData;
@property (strong,nonatomic) NSString *videoID;  // the id of the item 
@property (weak) id delegate;
+ (id) operationWithDelegate: (id) delegate andPath: (NSString *) path andItemID: (NSString*)mediaID;

@end