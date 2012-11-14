//
//  Requests.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Requests.h"

@implementation Requests


#pragma mark - Request methods
// this method creates and returns the request and accepts the video path as an arg
- (NSURLRequest*) createRequestWithVideoPath:(NSString *)pathString{
    // create the background queue
    
    
    // get the data from the file that sits in the local application directory
    NSData *vidData = [NSData dataWithContentsOfFile:pathString];
    // of the data from the video file
    NSLog(@"get and set the data");
    if (!vidData) return nil;// return nil if it wasn't able to create the data object
    // create the URL
    NSURL *mainURL = [NSURL URLWithString:@"http://localhost:80/Revolt/upload_media.php"];
    
    
    // create the request object, must be mutable so we can set the post variables
    // to the proper post vars for a file upload, setting the timeout interval to 
    // ... many days and hours worth of time
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:mainURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100000000000];
    
    [request setHTTPMethod:@"POST"];
    NSString *boundary = [NSString stringWithString:@"---------------------------gc0p4Jq0M2Yt08j34c0p"];// the boundary is a necessary part of a multipart data
    // post because it tells the server to know where the data parts stop 
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];// multipart means that it will have multiple pieces to it
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data]; // create the data property to be submitted as part of the form
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];// create spaces and a boundary in the form
    NSString *postName = [[NSString alloc] initWithString:@"Content-Disposition: form-data; name=\"userVideoFile\"; filename=\"vid.mov\"\r\n"];// suggests a filename for the server to use for this file
    [body appendData:[[NSString stringWithString:postName] dataUsingEncoding:NSUTF8StringEncoding]];// append the post name to the body data object
    [body appendData:[[NSString stringWithString:@"Content-Type: video/quicktime\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];// set the content type to the 
    // type of file that we are uploading
    [body appendData:[NSData dataWithData:vidData]];// add the actual data
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];// create another boundary 
    [request setHTTPBody:body];// set the body of the request so we can finally send it
    
    /* basic working connection routine*/
    
    return (NSURLRequest*)request;
    
    vidData = nil;
    
    
    NSLog(@"main connection started");
    
    
}

- (NSURLRequest*) createRequestWithImagePath:(NSString *)pathString{
    // create the background queue
    
    
    // get the data from the file that sits in the local application directory
    NSData *imgData = [NSData dataWithContentsOfFile:pathString];
    // of the data from the video file
    NSLog(@"get and set the data");
    if (!imgData) return nil;// return nil if it wasn't able to create the data object
    // create the URL
    NSURL *mainURL = [NSURL URLWithString:@"http://localhost:80/Revolt/upload_media.php"];
    
    
    // create the request object, must be mutable so we can set the post variables
    // to the proper post vars for a file upload, setting the timeout interval to 
    // ... many days and hours worth of time
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:mainURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100000000000];
    
    [request setHTTPMethod:@"POST"];
    NSString *boundary = [NSString stringWithString:@"---------------------------gc0p4Jq0M2Yt08j34c0p"];// the boundary is a necessary part of a multipart data
    // post because it tells the server to know where the data parts stop 
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];// multipart means that it will have multiple pieces to it
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data]; // create the data property to be submitted as part of the form
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];// create spaces and a boundary in the form
    NSString *postName = [[NSString alloc] initWithString:@"Content-Disposition: form-data; name=\"userImageFile\"; filename=\"image.jpg\"\r\n"];// suggests a filename for the server to use for this file
    [body appendData:[[NSString stringWithString:postName] dataUsingEncoding:NSUTF8StringEncoding]];// append the post name to the body data object
    [body appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];// set the content type to the 
    // type of file that we are uploading
    [body appendData:[NSData dataWithData:imgData]];// add the actual data
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];// create another boundary 
    [request setHTTPBody:body];// set the body of the request so we can finally send it
    
    /* basic working connection routine*/
    
    return (NSURLRequest*)request;
    
    imgData = nil;
    
    
    NSLog(@"main connection started");
    
    
}


@end
