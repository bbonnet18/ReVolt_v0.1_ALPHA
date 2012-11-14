//
//  VideoUploadOperation.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoUploadOperation.h"


#define NOTIFY_AND_LEAVE(MESSAGE) {[self cleanup:MESSAGE]; return;}
// this returns a string object from the data that's provided in a formatString
#define DATA(STRING)	[STRING dataUsingEncoding:NSUTF8StringEncoding]
#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)

#define HOST    @"twitpic.com"


//

// Posting constants
#define VIDEO_CONTENT @"Content-Disposition: form-data; name=\"%@\"; filename=\"video.mov\"\r\nContent-Type: video/quicktime\r\n\r\n"

#define STRING_CONTENT @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"




@implementation VideoUploadOperation

@synthesize movieData, delegate;
@synthesize videoID = _videoID;

- (void) cleanup: (NSString *) output
{
	self.movieData = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    SAFE_PERFORM_WITH_ARG(delegate, @selector(doneUploading:), self.videoID);//output);
}

- (NSData*)generateFormDataFromPostDictionary:(NSDictionary*)dict
{
    id boundary = @"------------0x0x0x0x0x0x0x0x";
    NSArray* keys = [dict allKeys];
    NSMutableData* result = [NSMutableData data];
	
    for (int i = 0; i < [keys count]; i++) 
    {
        id value = [dict valueForKey: [keys objectAtIndex:i]];
        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
		if ([value isKindOfClass:[NSData class]]) 
		{
			// handle video data
			NSString *formstring = [NSString stringWithFormat:VIDEO_CONTENT, [keys objectAtIndex:i]];
			[result appendData: DATA(formstring)];
			[result appendData:value];
		}
		else 
		{
			// all non-image fields assumed to be strings
			NSString *formstring = [NSString stringWithFormat:STRING_CONTENT, [keys objectAtIndex:i]];
			[result appendData: DATA(formstring)];
			[result appendData:DATA(value)];
		}
		
		NSString *formstring = @"\r\n";
        [result appendData:DATA(formstring)];
    }
	
	NSString *formstring =[NSString stringWithFormat:@"--%@--\r\n", boundary];
    [result appendData:DATA(formstring)];
    
        
    return result;
}

- (void) main
{
	if (!self.movieData)
		NOTIFY_AND_LEAVE(@"ERROR: Please set Video before uploading.");
    
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:HOST port:0 protocol:@"http" realm:nil authenticationMethod:nil];
    
    NSURLCredential *credential = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:protectionSpace];
    if (!credential)
        NOTIFY_AND_LEAVE(@"ERROR: Credentials not set.")
        
        NSString *uname = credential.user;
    NSString *pword = credential.password;
    
	if (!uname || !pword || (!uname.length) || (!pword.length))
		NOTIFY_AND_LEAVE(@"ERROR: Please enter your account credentials in the settings before tweeting.");
	
	NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];
	[post_dict setObject:uname forKey:@"username"];
	[post_dict setObject:pword forKey:@"password"];
	[post_dict setObject:@"Posted to localhost" forKey:@"message"];
	[post_dict setObject:self.movieData forKey:@"media"];
	
	// Create the post data from the post dictionary
	NSData *postData = [self generateFormDataFromPostDictionary:post_dict];
	
	// Establish the API request. Use upload vs uploadAndPost for skip tweet
    
    NSLog(@"Here's ----------------------|||||||||||||||| the post data: %@",postData);
    
    
    NSString *baseurl =  @"http://localhost:80/Revolt/index.php";
    
    //@"http://localhost:80/Revolt/index.php"; 
    
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) 
        NOTIFY_AND_LEAVE(@"ERROR: Error creating the URL Request");
	
    [urlRequest setHTTPMethod: @"POST"];
	[urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:postData];
	
	// Submit & retrieve results
    NSError *error;
    NSURLResponse *response;
	NSLog(@"Uploading the content....");
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if (!result)
	{
		[self cleanup:[NSString stringWithFormat:@"Submission error: %@", [error localizedFailureReason]]];
		return;
	}
	
	// Return results
    NSString *outstring = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	[self cleanup: outstring];
    
}

+ (id) operationWithDelegate: (id) delegate andPath: (NSString *) path andItemID:(NSString *)mediaID
{
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return nil;
    
    VideoUploadOperation *op = [[VideoUploadOperation alloc] init];
    op.delegate = delegate;
    op.movieData = data;
    op.videoID = mediaID;
    
    return op;
}


@end
