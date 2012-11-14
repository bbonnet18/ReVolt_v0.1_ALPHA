//
//  UploadViewer.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Build.h"
#import "BuildItem.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Build.h"
#import "Post.h"

@interface UploadViewer : UIViewController <NSURLConnectionDelegate>
{
    // private
    BOOL _isUploading;// this flag will indicate whether the build is uploading or whether it's stopped, used to set it to stop when the network is unavailable or whether it will enter the background
    UILabel *_buildTitle;
    UIProgressView *_progView;
    UITextView *_currentUpload;
    UITextView *_issues;
    NSArray *_mediaItems;// array of the items needing upload
    //id <BuildEditor> _delegate;
    Build *_build;
    NSTimer *_updateTimer;
    NSManagedObjectContext *_context;
    NSOperationQueue *_mediaQueue;// will hold all the upload operations
    BOOL networkAvailable;
    NSInteger currentItemUploadIndex;// the index within the mediaItems array for the lastUploaded item
    NSData *_mediaData;
    ALAssetsLibrary *_lib;
    AVAssetExportSession *_export;
    NSString * _mediaPathString;// path to the current media objecta
    NSMutableArray *_errors;// holds an array of errors, we will show these to the user if we encounter any errors
    NSURLConnection *_mainConn;// the main url connection object to handle the uploads and downloads
    NSData *_jsonData;// a reference to the JSON data provided during init
    
}

// setup UI elements hold a reference to the build that's associated with this upload
@property (assign, nonatomic) BOOL isUploading;
@property (strong, nonatomic) IBOutlet UILabel *buildTitle;
@property (strong, nonatomic) IBOutlet UIProgressView *progView;
@property (strong, nonatomic) IBOutlet UITextView *currentUpload;
@property (strong, nonatomic) IBOutlet UITextView *issues;
@property (strong, nonatomic) NSOperationQueue *mediaQueue;
@property (strong, nonatomic) NSArray *mediaItems;
//@property (strong, nonatomic) id <BuildEditor> delegate;
@property (strong, nonatomic) Build *build;// this is a reference to the build that's passed in
@property (strong, nonatomic) NSTimer *updateTimer;// this timer will update the display every few seconds, querying the main application to see how many items in this build are already uploaded
@property (strong, nonatomic) NSManagedObjectContext* context;// reference to the moc
@property (strong, nonatomic) NSData* mediaData;
@property (strong, nonatomic) ALAssetsLibrary *lib;
@property (strong, nonatomic) AVAssetExportSession *export;//this is the export session that we''l use to export each media item so we can get it's data and upload it
@property (strong, nonatomic) NSString *mediaPathString;// this will be the currently uploading media item's string
@property (strong, nonatomic) NSMutableArray *errors;
@property (strong, nonatomic) NSURLConnection *mainConn;//
@property (strong, nonatomic) IBOutlet UIButton *uploadBtn;


-(void) setupUploads;
- (void) updateProgress;
-(void) showMessage;
- (BOOL) checkReachability;// check's the delegate's reachability to see if there's a connection to use for the uploads
- (void) beginUploads;// gets the first item to upload and initializes other variables
- (void) doneUploading:(NSString*)message;// called by the returning operation and sent a message from the operation about it's success or failure
- (BOOL) checkMediaComplete;// checks to see if all items have uploaded from the mediaQueue, if so, calls the final methods to get and load the JSON data
- (void) createMediaRequestFromBuildItem;// creates an NSURLRequest for a media object
- (void) createJSONDataRequest; // creates the JSON data request from the actual text provided for each template, this is the last part of the upload process for a build
- (IBAction)allUploads:(id)sender;// returns to the all uploads screen

@end
