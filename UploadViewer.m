//
//  UploadViewer.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define DATA(STRING)	[STRING dataUsingEncoding:NSUTF8StringEncoding]

#define HOST    @"twitpic.com"

#define VIDEO_CONTENT @"Content-Disposition: form-data; name=\"%@\"; filename=\"video.mov\"\r\nContent-Type: video/quicktime\r\n\r\n"
#define IMAGE_CONTENT @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
#define STRING_CONTENT @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"


#import "UploadViewer.h"
#import "TextAndImageMO.h"
#import "TextAndVideoMO.h"
#import "VideoOnlyMO.h"
#import "TextOnlyMO.h"

@implementation UploadViewer
@synthesize uploadBtn = _uploadBtn;

@synthesize isUploading = _isUploading;
@synthesize buildTitle = _buildTitle;
@synthesize progView = _progView;
@synthesize currentUpload = _currentUpload;
@synthesize issues = _issues;
@synthesize mediaItems = _mediaItems;
//@synthesize delegate = _delegate;
@synthesize build = _build; 
@synthesize updateTimer = _updateTimer;
@synthesize context = _context;
@synthesize lib = _lib;
@synthesize mediaQueue = _mediaQueue; 
@synthesize mediaData = _mediaData;
@synthesize export = _export;
@synthesize mediaPathString = _mediaPathString;
@synthesize errors = _errors;
@synthesize mainConn = _mainConn;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.lib = [[ALAssetsLibrary alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAndCleanup) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartUploads) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAndCleanup) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartUploads) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.progView setProgress:0.0];
    Post *p = [self.build post];
    [p setStatus:@"uploading"];// if it's here then it's uploading, 
    NSError *e;
    if([self.context save:&e]){
        [self setupUploads];
    }else{
        NSLog(@"error uploading the build: %@ | %@  | %@",[e localizedDescription], [e localizedFailureReason], [e localizedRecoverySuggestion]);
    }
    
    
}



-(void) showMessage{
    // check to see if the export object is currently exporting
    if([self.export status] == AVAssetExportSessionStatusExporting){
        NSLog(@" STATUS: exporting");
    }
    if([self.export status] == AVAssetExportSessionStatusFailed){
        // add the error to the error array
        [self.errors addObject:[NSString stringWithFormat:@"Error exporting video - %@",[self.export.error localizedDescription]]];
        NSLog(@" STATUS: Failed - error: %@ - %@ - %@ ", [self.export.error localizedDescription], [self.export.error localizedRecoverySuggestion], [self.export.error localizedFailureReason]);
    }
    if([self.export status] == AVAssetExportSessionStatusWaiting){
        NSLog(@" STATUS: Waiting");
    }
    if([self.export status] == AVAssetExportSessionStatusCompleted){
        NSLog(@" STATUS: completed");
    }
    if([self.export status] == AVAssetExportSessionStatusUnknown){
        NSLog(@" STATUS: UNKNOWN");
    }
    if([self.export status] == AVAssetExportSessionStatusCancelled){
        NSLog(@" STATUS: CANCELLED");
    }
}

- (void)viewDidUnload// nilify iVars
{
    [self setBuildTitle:nil];
    [self setProgView:nil];
    [self setCurrentUpload:nil];
    [self setIssues:nil];
    [self setMediaItems:nil];
    [self setUpdateTimer:nil];
    [self setMediaData:nil];
    [self setMediaQueue:nil];
    [self setMediaPathString:nil];
    self.isUploading = NO;
    self.export = nil;
    self.mainConn = nil;
    
    // remove the notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
    [self setUploadBtn:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) stopAndCleanup{
    // set the indicator to off
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
    self.isUploading = NO;
    [self.mediaQueue cancelAllOperations];
    self.mediaPathString = nil;
    self.mediaData = nil;
}

- (void) restartUploads{
    if(self.isUploading != YES){
        self.isUploading = YES;// set this to YES so the method knows not to call all of these multiple times
        if(![self.build.status isEqualToString:@"uploaded"]){
            
            if([self checkMediaComplete]!= YES){
                // get the percentage of the media items count
                //self->currentItemUploadIndex ++;
                [self buildRequestAndUpload];// takes the next one and starts the   upload process
            }// called each time to check to see if the media has all been uploaded
            else{// the JSON data has not been uploaded, so upload it
                [self createJSONDataRequest];
            }
        }else{
            
            UIAlertView *uploadedAlert = [[UIAlertView alloc] initWithTitle:@"Already Uploaded" message:@"This Build was already uploaded to the server" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [uploadedAlert show];
        }

        
    }
}

//-(void) saveState{
//    // save the current uploadIndex
//    // set mediaData to nil
//    // set mediaPathString to nil
//    // set isUploading to NO
//    // stop the networkActivityIndicator
//    // set the export.status variable
//    // set the timer to off
//    // account for the mediaQueue and currentUpload
//    [self.updateTimer invalidate];// stop the timer
//    
//}


//-(void) restoreAtState{
//    // redo everything the from the save state
//    
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - setup upload screen elements

- (void) setupUploads{
    

    self.title = @"Uploading";
    

    if([self.build.status isEqualToString:@"uploaded"])
    {
        UIAlertView *uploadedAlert = [[UIAlertView alloc] initWithTitle:@"Already Uploaded" message:@"This Build was already uploaded to the server" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [uploadedAlert show];
    }else{
        // get the BuildItems in ascending order
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BuildItem" inManagedObjectContext:self.context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"build == %@",self.build];
        [request setPredicate:predicate];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"screenID" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        NSError *error = nil;
        
        //NSArray *results = [self.context executeFetchRequest:request error:&error];
        
        // each of these is actually a buildItem rather than a media item, but the media items are part of each BuildItem so they can be brought in
        self.mediaItems = [NSMutableArray arrayWithArray:[self.context executeFetchRequest:request error:&error]];//[NSMutableArray arrayWithArray:[[self.currentBuild buildItems] allObjects]];
        
        
        
        if(error){
            // handle the error 
            [self.errors addObject:[NSString stringWithFormat:@"error getting items from build:", [error localizedDescription]]];
        }else{
            self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showMessage) userInfo:nil repeats:YES];
            
            
            [self beginUploads];
        }

    }
    
}

- (void) beginUploads{// initialize the queue and currentItemUploadIndex
    self.isUploading = YES;// set the uploads to yes so if we check, we know the upload process is happening
    self.mediaQueue = [[NSOperationQueue alloc] init];
    self->currentItemUploadIndex = 0;
    

   
    //load the first builditem
    
    [self buildRequestAndUpload];// start by uploading the first item
    
}


// kicks off the process to build the upload request for video, image and audio data by checking each media type and calling the createMediaDataFromPath method
-  (void) buildRequestAndUpload{
    
    BuildItem *itemToUpload = [self.mediaItems objectAtIndex:self->currentItemUploadIndex];
    
    NSString *typeForMedia = nil;
    NSLog(@"type is: %@",itemToUpload.type);
    if([itemToUpload.type isEqualToString: @"TextAndImageMO"]){
        TextAndImageMO *t = (TextAndImageMO*)itemToUpload;//cast each one to the correct BuildItem type
        typeForMedia = @"image";
        [self createImageDataFromPath:t.imagePath];
    }else if([itemToUpload.type isEqualToString: @"TextAndVideoMO"]){
        TextAndVideoMO *t = (TextAndVideoMO*)itemToUpload;
        typeForMedia = @"video";
        [self createVideoDataFromPath:t.videoPath];
    }else if([itemToUpload.type isEqualToString: @"VideoOnlyMO"]){
        VideoOnlyMO *t = (VideoOnlyMO*)itemToUpload;
        typeForMedia = @"video";
        [self createVideoDataFromPath:t.videoPath];
    }else if([itemToUpload.type isEqualToString: @"TextOnlyMO"]){
        TextOnlyMO *t = (TextOnlyMO*)itemToUpload;
        typeForMedia = @"text";
    }
}
// creates a dictionary and adds an array of items to the dictionary to create the JSON data
- (NSData*) generateJSONFromBuild{
    // get the date
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    NSString *creationDateString = [formatter stringFromDate:self.build.creationDate];
    // this builds a hierarchy with the main node being the build and the items string data making up the rest 
    NSDictionary *metaDataDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:creationDateString, @"buildCreationDate",nil];
    
    // initialize the dictionary that we'll use to add the items to
    NSMutableDictionary *buildDictionary = [[NSMutableDictionary alloc] initWithDictionary:metaDataDictionary];
    // create an array to store the items 
    NSMutableArray * itemArray = [[NSMutableArray alloc] init];
    // roll through the items and extract what's needed and add each to the array
    for (BuildItem * b in self.mediaItems) {
        NSString * screenTitle = b.screenTitle;
        NSString * screenID = [b.screenID stringValue];
        NSString * itemType = b.type;
        NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:screenTitle,@"screenTitle",screenID,@"screenID",itemType,@"itemType", nil];
        
        NSString * screenText = nil;
        if([itemType isEqualToString: @"TextAndImageMO"]){
            TextAndImageMO *t = (TextAndImageMO*)b;
            screenText = t.screenText;
        }else if([itemType isEqualToString: @"TextAndVideoMO"]){
            TextAndVideoMO * t = (TextAndVideoMO*)b;
            screenText = t.screenText;
        }else if([itemType isEqualToString: @"TextOnlyMO"]){
            TextOnlyMO *t = (TextOnlyMO*)b;
            screenText = t.screenText;
        }
        
        if(screenText != nil){
            [itemDictionary setValue:screenText forKey:@"screenText"];
        }
        [itemArray addObject:itemDictionary];
        
    }
    // add the item array to the buildDictionary
    [buildDictionary setObject:itemArray forKey:@"buildItems"];
    NSError *error;
    // create json data
    NSData *buildData = [NSJSONSerialization dataWithJSONObject:buildDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *stringData = [[NSString alloc] initWithData:buildData encoding:NSUTF8StringEncoding];
    
    if(!error){
        NSLog(@"jsonData: %@",stringData );
        return buildData;
    }else {
        return nil;
    }
   
}

// starts the export session, which will export the media 
- (void) createVideoDataFromPath:(NSString*) path{
    
    // get the asset at the path
//    BuildItem *b = [self.mediaItems objectAtIndex:self->currentItemUploadIndex];
//    
//    NSString *screenID = [b.screenID stringValue];
    
    // intiialize the asset to get a reference to it
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:path]];
    // these path components can be tricky and you need to store the file in the right place. The place below works better than all others to store larger files temporarily. 
    //setup all the file path components
    NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/temp"];
    NSString *filePath = [basePath stringByAppendingString:@"tempMov"];
    NSString *fullPath = [filePath stringByAppendingPathExtension:@"mov"];
    self.mediaPathString = fullPath;
    
    // remove the file if for some reason it's in the directory already 
    if([[NSFileManager defaultManager] fileExistsAtPath:self.mediaPathString]){
        BOOL removeIfFileExists = [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:self.mediaPathString] error:nil];
    }
    // used to set up presets if there are many to choose from 
    //NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    
   // NSString const *preset = AVAssetExportPresetMediumQuality;
    
    
    // set up the export session with the preset for medium quality videos
    self.export = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    // set up the export url to export the video to the temporary directory
    self.export.outputURL = [NSURL fileURLWithPath:self.mediaPathString];
    self.export.shouldOptimizeForNetworkUse = YES;// optimize for the networks
//    NSArray *supportedFileTypes = [self.export supportedFileTypes];
//    
//    for (int i = 0; i<[supportedFileTypes count]; i++) {
//        NSLog(@"supported file: %@",[supportedFileTypes objectAtIndex:i]);
//        
//    }
    //
    // export the movie as a quicktime video
    self.export.outputFileType = AVFileTypeQuickTimeMovie;//@"com.apple.quicktime-movie"; also works
    // start the export and respond when the export completes, regardless of the completion type (i.e. completed, failure, etc.)
    [self.export exportAsynchronouslyWithCompletionHandler:^{
        // check the status report problems or start a media request with the newly exported movie
        switch ([self.export status]) {
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"Export session completed");
                [self performSelectorOnMainThread:@selector(createMediaRequestFromBuildItem) withObject:nil waitUntilDone:YES];
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"failed with error: %@",self.export.error);
            default:
                NSLog(@"Default ---------- ");
                break;
        }
    }];
    
}


//- (void) createImageDataFromPath:(NSString*) path{
//    // get the asset at the path and do all the manipulation in the result block
//    [self.lib assetForURL:[NSURL URLWithString:path] resultBlock:^(ALAsset *asset) {
//        // create a temporary directory
//        NSString *basePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/temp"];
//        NSString *filePath = [basePath stringByAppendingString:@"tempImg"];
//        NSString *fullPath = [filePath stringByAppendingPathExtension:@"jpg"];
//        self.mediaPathString = fullPath;
//        // get the default representation of the image 
//        ALAssetRepresentation *rep = [asset defaultRepresentation];
//        // turn the asset rep into an image reference
//        CGImageRef ref = [rep CGImageWithOptions:nil];
//        // create the image from the reference
//        UIImage *assetImage = [UIImage imageWithCGImage:ref];
//        // get the data from the image
//        NSData *jpgData = UIImageJPEGRepresentation(assetImage, 1.0);
//        // remove the file if somehow it already exists from a suspended upload or something else
//        if([[NSFileManager defaultManager] fileExistsAtPath:self.mediaPathString]){
//            BOOL removeIfFileExists = [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:self.mediaPathString] error:nil];
//        }// write the image to the temp file path
//        BOOL didWriteToFile = [jpgData writeToFile:fullPath atomically:NO];
//        if(didWriteToFile){// set the media data to the jpg data
//            //self.mediaData = jpgData;
//            [self performSelectorOnMainThread:@selector(createMediaRequestFromBuildItem) withObject:nil waitUntilDone:YES];
//        }else{
//            NSLog(@"error - WRITING TO THE FILE!!!! -----------------");
//        }
//        
//    } failureBlock:^(NSError *error){
//        // log errors
//        NSLog(@"an error occurred: %@",[error localizedDescription]);
//        // add error to errors
//    }];
//    
//}

- (void) createImageDataFromPath:(NSString*) path{
    
    //UIImage *assetImage = [UIImage imageWithContentsOfFile:path];
    //NSData *jpgData = UIImageJPEGRepresentation(assetImage, 1.0);
    
    // the path string 
    
    self.mediaPathString = path;
    [self createMediaRequestFromBuildItem];
}


//takes the request created in buildRequestAndUpload, and places it into the NSURLConnection so it can post
-(void) postRequest: (NSURLRequest*)request{
    
//    self.mainConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [NSURLConnection sendAsynchronousRequest:request queue:self.mediaQueue completionHandler:^(NSURLResponse *r, NSData *d, NSError *e){
        NSString *str = [[NSString alloc] initWithData: d encoding:NSUTF8StringEncoding];// make sure the response returned by the server is 
        // going to contain the id number of the screen that was uploaded, so we can check it off
        
        NSLog(@"ALL DONE, response");
        // we were either successful or unsuccessful, in either event, we need to  
        // set the network activity indicator to off
        NSString *result = [NSString stringWithFormat:@"%@",d];
        if(![result isEqualToString:@"error"]){
            [self performSelectorOnMainThread:@selector(doneUploading:) withObject:str waitUntilDone:NO];
        }else{
            NSString *errorStr = [NSString stringWithFormat:@"error from server"];
            [self.errors addObject:errorStr];// add the error to the errors array
        }
        
    }];
    
    
    

}
  

#pragma mark - set timer to update this view
                  
- (void) updateProgress{
    // check to see if the network is available
    self->networkAvailable = YES;//   //[self.delegate networkIsReachable];
    if(self->networkAvailable == YES){//if yes, make sure the mediaQueue is running
        if (self.mediaQueue.isSuspended) {
            [self.mediaQueue setSuspended:NO];
        }
    }else{// if the network is not available, make sure the mediaQueue is not running
        // check to see if the network is available, if not, show a message and do nothing further
        if(self.mediaQueue.isSuspended == NO){
            [self.mediaQueue setSuspended:YES];
        }
    
    }
    // query the main application to see if the items have been uploaded to the server. You can access the "uploaded" key/value for each media item
}

// called when the item is done uploading, set's the currently uploading item's uploaded property to YES
- (void) doneUploading:(NSString*)message{

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    BuildItem *b = [self.mediaItems objectAtIndex:self->currentItemUploadIndex];
    b.uploaded = YES;
    self.mediaData = nil;// release the data now that the upload has taken place
    // remove temporary file if it exists
    if([[NSFileManager defaultManager] fileExistsAtPath:self.mediaPathString]){
         BOOL removeIfFileExists = [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:self.mediaPathString] error:nil];
        self.mediaPathString = nil;
    }
    if([self checkMediaComplete]!= YES){
        self->currentItemUploadIndex ++; 
        [self buildRequestAndUpload];// takes the next one and starts the upload process
    }// called each time to check to see if the media has all been uploaded
    else{
        // they have all been uploaded
        // close out the item uploading process
        // create an uploading post request for the json data
        if([message isEqualToString:@"JSON uploaded"]){
            self.build.status = @"uploaded";// set the status property of the build to uploaded
            Post *p = (Post*) [self.build valueForKey:@"post"];
            p.status = @"view";
            [self.progView setProgress:1.0 animated:YES];// set  progress indicator to completed state
            [self.currentUpload setText:@"This build has been uploaded to the server"];
            [self.currentUpload setTextColor:[UIColor redColor]];// set it to red if uploaded
            self.title = @"Uploaded";
            NSError *error;
            if(![self.context save:&error]){
                NSLog(@"%@", [error localizedFailureReason]);
                [self.issues setText:[error localizedDescription]];
            }
        }else{// the JSON data has not been uploaded, so upload it
            [self createJSONDataRequest];  
        }      
        
    }
    
}
// check to see if all the media is uploaded, if so, upload the text content as JSON
- (BOOL) checkMediaComplete{
    // check to see if each one of the BuildItems in self.mediaItems has it's uploaded property set to true or YES
    float i = 0.0;
    BOOL allUploaded = YES;
        // the count to advance to get the ultimate number of completed uploads
    for(BuildItem *b in self.mediaItems){
        if(b.uploaded != YES){
            allUploaded = NO;
            break;
        }else{
            i++;
        }
    }
    // 
    float totalItems = [self.mediaItems count];
    
    float prog = i/totalItems; 
    float mediaPercentage = prog * 0.9;
    // set the progress view to reflect the number of items that have been completed
    [self.progView setProgress:mediaPercentage animated:YES];
    if(allUploaded){
        return YES;
    }else {
        return NO;
    }
    
}
// gets the JSON data and creates a request, appending the data to the request and uploading it
- (void) createJSONDataRequest{
    NSData *buildData = [self generateJSONFromBuild];
    
    
   
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
     
     NSString *baseurl =  @"http://192.168.1.2/Revolt/upload_media.php";
     NSURL *url = [NSURL URLWithString:baseurl];
     NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
     if (!urlRequest) {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     
     }
    //-- probably need to change the content type and/or the encoding of the data, most likely the content type to reflect JSON string data
     [urlRequest setHTTPMethod: @"POST"];
     [urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
     [urlRequest setHTTPBody:buildData];
     // post the request to the server
     [self postRequest:urlRequest];
    

}

- (void) createMediaRequestFromBuildItem{
    // data from the file in the directory 
    
    BuildItem *b = [self.mediaItems objectAtIndex:self->currentItemUploadIndex];
    NSLog(@"mediaPathString: %@",self.mediaPathString);
    self.mediaData = [NSData dataWithContentsOfFile:self.mediaPathString];
    
       
    
    // removing all the credential stuff for demo 
    // create the dictionary 
//    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:HOST port:0 protocol:@"http" realm:nil authenticationMethod:nil];
//    
//    NSURLCredential *credential = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:protectionSpace];
//    if (!credential){
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;        
//        
//    }
//    NSString *uname = credential.user;
//    NSString *pword = credential.password;
//    
//	if (!uname || !pword || (!uname.length) || (!pword.length)){
//		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    }
	NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];
//	[post_dict setObject:uname forKey:@"username"];
//	[post_dict setObject:pword forKey:@"password"];
	[post_dict setObject:@"Posted to localhost" forKey:@"message"];
	[post_dict setObject:self.mediaData forKey:@"media"];
    
    
	NSData *postData = [self generateFormDataFromPostDictionary:post_dict withType:b.type];
    
    
	NSString *baseurl =  @"http://192.168.1.2/Revolt/upload_media.php";
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) {
       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	   
    }
    [urlRequest setHTTPMethod: @"POST"];
	[urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:postData];
    
    [self postRequest:urlRequest];

}

// generatePostData

- (NSData*)generateFormDataFromPostDictionary:(NSDictionary*)dict withType:(NSString*) type
{
    id boundary = @"------------0x0x0x0x0x0x0x0x";// set the boundry
    NSArray* keys = [dict allKeys];// get the keys 
    NSMutableData* result = [NSMutableData data];// initialize the data object
	
    NSString *mediaType = [self getMediaTypeFromBuildItemType:type];// get the media type
    
    for (int i = 0; i < [keys count]; i++) 
    {
        id value = [dict valueForKey: [keys objectAtIndex:i]];
        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
		if ([value isKindOfClass:[NSData class]]) 
		{
			// handle video data
            NSString* formstring = nil;
            if(mediaType == @"video"){
               formstring = [NSString stringWithFormat:VIDEO_CONTENT, [keys objectAtIndex:i]];
            }else{
                formstring = [NSString stringWithFormat:IMAGE_CONTENT, [keys objectAtIndex:i]];
            }
			
			[result appendData: DATA(formstring)];
			[result appendData:value];// appends the data itself
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
// returns the proper media type from the BuildItem type
- (NSString*) getMediaTypeFromBuildItemType:(NSString*)type{
    if([type isEqualToString: @"TextAndImageMO"]){
        return @"image";
    }else if([type isEqualToString: @"TextAndVideoMO"]){
        return @"video";
    }else if([type isEqualToString: @"VideoOnlyMO"]){
        return @"video";
    }else if([type isEqualToString: @"TextOnlyMO"]){
       return @"text";
    }
    return @"unknown";
}

- (IBAction)allUploads:(id)sender{
    // tell the navigation controller to pop to the uploadsviewcontroller, which is the second one in the stack
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
}
//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
//    NSString *test = @"";
//}
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
//    NSString *test = @"";
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
//    NSString *test = @"";
//}
//
//- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request{
//    NSString *test = @"";
//}
//- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
// totalBytesWritten:(NSInteger)totalBytesWritten
//totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
//    NSString *test = @"";
//}
//
//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
//    NSString *test = @"";
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    NSString *resp = @"it did finish";
//    [self performSelectorOnMainThread:@selector(doneUploading:) withObject:resp waitUntilDone:NO];
//}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Error : %@ - %@",[error localizedDescription], [error localizedRecoverySuggestion]);
    [self.errors addObject:[NSString stringWithFormat:@"Error with connection: ",[error localizedDescription]]];
}
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection{
    return NO;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    NSString *s = @"";
}


// Deprecated authentication delegates.
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
    
    return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    NSString *s = @"";
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    NSString *s = @"";
}



@end
