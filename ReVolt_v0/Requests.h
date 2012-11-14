//
//  Requests.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Requests : NSObject{

}
// create and return url requests
- (NSURLRequest*) createRequestWithVideoPath:(NSString *)pathString;

- (NSURLRequest*) createRequestWithImagePath:(NSString *)pathString;

@end
