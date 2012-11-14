//
//  ConnectionHandler.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConnectionHandler.h"

@implementation ConnectionHandler

@synthesize delegate = _delegate;
@synthesize bgQueue = _bgQueue;
@synthesize mainConnection = _mainConnection;

- (id)initWithDelegate:(id)del{
    
    self.delegate = del;
    self.bgQueue = [[NSOperationQueue alloc] init];
    
        
    return self;
}



#pragma mark - go Asynch (block-based) and start upload

- (void) startUpload:(NSURLRequest *)req{
    
    self.mainConnection = nil;
    
    self.mainConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    if(self.mainConnection == nil){// check to see if the connection was made, if not, report that there was an error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Unavalailable" message:@"Not able to establish a connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void) goAsynch:(NSURLRequest *)req{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:req queue:self.bgQueue completionHandler:^(NSURLResponse *r, NSData *d, NSError *e){
        NSString *str = [[NSString alloc] initWithData: d encoding:NSUTF8StringEncoding];
        
        NSLog(@"ALL DONE, response: %@",str);
        // we were either successful or unsuccessful, in either event, we need to shut the 
        // set the network activity indicator to off
        dispatch_async(dispatch_get_main_queue(), ^{// call this on the main queue, 
            // which is in charge of the interface
            
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    }];
    
}


#pragma mark - connection delegate methods


- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    return request;
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
   NSString *str = @"hello";

}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.delegate doneLoading:@"There was an error"];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    
}

//- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request{
//    
//}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    
    NSString *str = @"test";
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [self.delegate doneLoading:@"it finished"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL{
    [self.delegate doneLoading:@"it finished"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}



-(void)sendAsynchronousRequest:(NSURLRequest *)request
                         queue:(NSOperationQueue*) queue
             completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*)) handler  {
    
}



@end
