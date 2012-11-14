//
//  ConnectionHandler.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ConnectionResponse
@required
- (void) doneLoading:(NSString*) response;

@end

@interface ConnectionHandler : NSObject <NSURLConnectionDelegate, NSURLConnectionDownloadDelegate, NSURLConnectionDataDelegate>{
    
    id <ConnectionResponse> _delegate;
    NSOperationQueue *_bgQueue;
    NSURLConnection *_mainConnection;// the connection object
    
}

@property (nonatomic, strong) id delegate;
@property (strong,nonatomic) NSOperationQueue *bgQueue;
@property (strong,nonatomic) NSURLConnection *mainConnection;
- (id) initWithDelegate: (id) del;// initiates the class with the delegate, this delegate will most likely be the appdelegate

- (void) startUpload:(NSURLRequest*)req;// starts the upload process and handles all returns until it recieves a message that the item has been uploaded successfully or has received an error, it then calls a method on the appDelegate named doneLoading

- (void) goAsynch:(NSURLRequest *)req;// this method uses an operation queue to run the upload operation
@end
