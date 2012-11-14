//
//  ImageUploadOperation.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>



@interface ImageUploadOperation : NSOperation{
    NSString *_imageID;
}

@property (strong) NSData *imageData;
@property (strong, nonatomic) NSString *imageID;  // the id of the item 
@property (weak) id delegate;
+ (id) operationWithDelegate: (id) delegate andPath: (NSString *) path andItemID: (NSString*)mediaID;
@end
