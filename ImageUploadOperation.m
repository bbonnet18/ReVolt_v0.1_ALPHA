//
//  ImageUploadOperation.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
// Taken from Erica Sudan - iOS 5 Development Cookbook

#import "ImageUploadOperation.h"

#define NOTIFY_AND_LEAVE(MESSAGE) {[self cleanup:MESSAGE]; return;}
// this returns a string object from the data that's provided in a formatString
#define DATA(STRING)	[STRING dataUsingEncoding:NSUTF8StringEncoding]
#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)

#define HOST    @"twitpic.com"

// Posting constants
#define IMAGE_CONTENT @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
#define STRING_CONTENT @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"

@implementation ImageUploadOperation

@synthesize imageData, delegate;
@synthesize imageID = _imageID;

- (void) cleanup: (NSString *) output
{
	self.imageData = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    SAFE_PERFORM_WITH_ARG(delegate, @selector(doneUploading:), self.imageID); //output);
    NSLog(@"completed");
}


// this method creates NSData and returns it to the main method
- (NSData*)generateFormDataFromPostDictionary:(NSDictionary*)dict
{
    id boundary = @"------------0x0x0x0x0x0x0x0x";
    NSArray* keys = [dict allKeys];// keys for all the values received from the dictionary
    NSMutableData* result = [NSMutableData data];// the return object for this method
	// roll through all the keys in the dictionary and use the defines stated at the top
    // create the data object returned from this method
    for (int i = 0; i < [keys count]; i++) 
    {
        id value = [dict valueForKey: [keys objectAtIndex:i]];
        // start by adding the boundry to the result data variable 
        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]                             dataUsingEncoding:NSUTF8StringEncoding]];
		
		if ([value isKindOfClass:[NSData class]]) // use isKindOfClass to check the kind of the class to see if it's data
		{
			// handle image data
			NSString *formstring = [NSString stringWithFormat:IMAGE_CONTENT, [keys objectAtIndex:i]];
            // create the data from the string object and append it to the form, 
            // the encoding for the data is NSUTF8StringEncoding
			[result appendData: DATA(formstring)];
			[result appendData:value];// this is where the actual image data is added to the form for upload
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

- (void) main// the main method is the method that has to execute in every operation, must have this method for it to work
{
	if (!self.imageData)
		NOTIFY_AND_LEAVE(@"ERROR: Please set image before uploading.");
    
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
	[post_dict setObject:@"New Post to ben" forKey:@"message"];
	[post_dict setObject:self.imageData forKey:@"media"];
	
	// Create the post data from the post dictionary
	NSData *postData = [self generateFormDataFromPostDictionary:post_dict];
    
	
	// Establish the API request. Use upload vs uploadAndPost for skip tweet
    NSLog(@"Here's the post data: %@",postData);
    NSString *baseurl = @"http://localhost:80/Revolt/index.php";
    
    //@"http://localhost:80/Revolt/index.php"; 
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) NOTIFY_AND_LEAVE(@"ERROR: Error creating the URL Request");
	
    [urlRequest setHTTPMethod: @"POST"];
	[urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:postData];
	
	// Submit & retrieve results
    NSError *error;
    NSURLResponse *response;
	NSLog(@"Contacting TwitPic....");
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

+ (id) operationWithDelegate: (id) delegate andPath: (NSString *) path andItemID:(NSString *)itemID
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return nil;
    
    ImageUploadOperation *op = [[ImageUploadOperation alloc] init];// don't confuse the alloc/init with this operationWithDelegate, which is simply a method on the object that instantiates it by calling alloc/init and returning the object
    op.delegate = delegate;
    op.imageData = data;
    op.imageID = itemID;
    
    
    return op;// returning the op will allow the queue to start once this returned object is added to the queue 

}


@end
