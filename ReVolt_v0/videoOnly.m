//
//  videoOnly.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "videoOnly.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)// reference to the bgQueue

@implementation videoOnly
@synthesize buildItem = _buildItem;
@synthesize lib = _lib;
@synthesize fromPhotosBtn;
@synthesize fromCameraBtn;
@synthesize thumbButton = _thumbButton;
@synthesize indicator = _indicator;
@synthesize vidAssetURL = _vidAssetURL;

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
    self.buildItem = (VideoOnlyMO*)[self.delegate loadBuildItem];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"*****ID: %@", self.buildItem.videoPath);
    
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.mp];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedWritingImage:) name:@"VideoSaved" object:nil];
    
    [self populateItems];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
   return (UIInterfaceOrientationIsPortrait(interfaceOrientation) ||  UIInterfaceOrientationIsLandscape(interfaceOrientation));
}


#pragma mark - camera functions

-(void)useCamera{
    // check to see if the camera is on the devie
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        
        // create the UIImagePickerController and set this ViewController as it's delegate, then declare the source types, media types and editing preferences
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.videoMaximumDuration = 60.0;
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];// including <MobileCoreServices/MobileCoreServices.h> with the header file is what allows us to use kUTTypeImage
        [self presentModalViewController:imagePicker animated:YES];
        newMedia = YES;
        
        
        
    }
}

-(void)usePhotos{
    // check to see if the camera roll is available on this device
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
        // just like the previous, create the imagePicker, set this as it's delegate and set the sourceType to the camera roll, then allow images as the media type and specify no for editing, and present the new view controller modally
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
        newMedia = NO;
        
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // setup the activity indicator
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // dismiss the modal picker snatcher view
    // check to see if the media is an image
    
    if(self.indicator == nil){
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicator.frame=CGRectMake(145, 160, 200, 200);
        [self.indicator setCenter:self.view.center];
        [self.view addSubview:self.indicator];
        [self.indicator startAnimating];
        
    }
    
    if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL]path];
        if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)){
            NSURL *u = [info objectForKey:UIImagePickerControllerMediaURL];
            
            
            
            if(picker.sourceType != UIImagePickerControllerSourceTypePhotoLibrary){
                [self.lib writeVideoAtPathToSavedPhotosAlbum:u completionBlock:^(NSURL *assetURL, NSError *error) {
                    NSLog(@"url from lib: %@", assetURL);
                    if(error == nil){
                        self.vidAssetURL = assetURL;
                        self.buildItem.videoPath = [assetURL absoluteString];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoSaved" object:self userInfo:nil];
                    }else{
                        NSLog(@"there was an error: %@",[error localizedDescription]);
                        [self.indicator removeFromSuperview];
                        self.indicator = nil;
                    }
                    
                }];
                
            }else{
                
                
                NSURL *assetURL = [info valueForKey:UIImagePickerControllerReferenceURL];
                self.vidAssetURL = assetURL;
                self.buildItem.videoPath = [assetURL absoluteString];
                NSLog(@"videoPath: %@",self.buildItem.videoPath);
                //                if([[NSThread currentThread] isMainThread]){
                //                    [self performSelector:@selector(buildThumb:) withObject:assetURL];
                //                }else{
                //                    [self performSelectorOnMainThread:@selector(buildThumb:) withObject:assetURL waitUntilDone:YES];
                //                }
                [self buildThumb:assetURL];
            }
            
        }
    }
    [self dismissModalViewControllerAnimated:YES];
    
}// this method conforms to the method specified by the completion selector argument of the UIImageWriteToSavedPhotosAlbum method above - that method is part of UIKit functions and named in the UIImage class
-(void) image:(UIImage *)image finishedSavingWithError:(NSError *) error contextInfo:(void *)contextInfo{
    if(image){
        
    }
    if(error){// if there was an error, show an alert message and allow the user to cancel that
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Failed" message:@"Failed to save image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}
// final delegate method for cancellation by user
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}
- (void) finishedWritingImage:(NSNotification*)notification{
    
    AVURLAsset *assetToUse = [[AVURLAsset alloc] initWithURL:self.vidAssetURL options:nil];
    NSArray *keys = [NSArray arrayWithObject:@"duration"];
    [assetToUse loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        
        
        NSError *error  = nil;
        AVKeyValueStatus trackStatus = [assetToUse statusOfValueForKey:@"duration" error:&error];
        if(error != nil){
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error obtaining duration" message:@"Error obtaining the duration of the video" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [errorAlert show];
        }else{
            AVURLAsset *newAsset = [[AVURLAsset alloc] initWithURL:self.vidAssetURL options:nil];
            NSURL *assetURL = [newAsset URL];
            switch (trackStatus) {
                case AVKeyValueStatusLoaded:
                    
                    NSLog(@"loaded the duration");
                    if([[NSThread currentThread] isMainThread]){
                        [self performSelector:@selector(buildThumb:) withObject:assetURL];
                    }else{
                        [self performSelectorOnMainThread:@selector(buildThumb:) withObject:assetURL waitUntilDone:YES];
                    }
                    
                    
                    break;
                case AVKeyValueStatusFailed:
                    NSLog(@"failed to save");
                    break;
                case AVKeyValueStatusLoading:
                    NSLog(@"still loading...");
                case AVKeyValueStatusCancelled:
                    NSLog(@"the duration operation was cancelled");
                default:
                    break;
            }
            
        }
    }];
}



- (void) buildThumb:(NSURL*) assetURL{
    
    AVURLAsset *assetToUse = [[AVURLAsset alloc] initWithURL:assetURL options:nil];
    
    
    Float64 durationSeconds = CMTimeGetSeconds([assetToUse duration]);
    CMTime startPoint = CMTimeMake(durationSeconds/2.0,600);
    CMTime actualTime;
    NSError *error = nil;
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:assetToUse];
    
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:startPoint actualTime:&actualTime error:&error];
    
    if(halfWayImage != NULL){
        NSString *actualTimeString = (__bridge NSString*)CMTimeCopyDescription(NULL, actualTime);
        NSString *requestedTimeString = (__bridge NSString*)CMTimeCopyDescription(NULL, startPoint);
        NSLog(@"requested time %@, actual time%@", requestedTimeString, actualTimeString);
        UIImage* imageToUse = [UIImage imageWithCGImage:halfWayImage];
        
        UIImageOrientation imageOrientation = [imageToUse imageOrientation];
        NSLog(@"image width: %f - image height: %f",imageToUse.size.width, imageToUse.size.height);
        
        
        //CGAffineTransform rotate = CGAffineTransformMakeRotation(1.0/180.0 *3.14);
        
        [self.thumbButton setImage:imageToUse forState:UIControlStateNormal];
        //[self.thumbButton setTransform:rotate];
        [self.thumbButton addTarget:self action:@selector(showVideo:)  forControlEvents:UIControlEventTouchUpInside];
        [self.indicator removeFromSuperview];
        self.indicator = nil;
        
        
        NSString* UUID = [self GetUUID];
        
        dispatch_async(kBgQueue, ^{
            
            if(self.buildItem.thumbnailImage != @""){//this one has a thumbnail already, so delete it
                NSError *error;
                NSFileManager *mgr = [NSFileManager defaultManager];
                if ([mgr removeItemAtPath:self.buildItem.thumbnailImage error:&error] != YES)
                    NSLog(@"Unable to delete file: %@", [error localizedDescription]);
            }
            
            
            NSString *imageName = [NSString stringWithFormat:@"vidImg_thumb_%@",UUID];
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpg",imageName]];
            NSURL *url = [NSURL fileURLWithPath:path];
            self.buildItem.thumbnailImage = path;
            [UIImageJPEGRepresentation(imageToUse, 0.75f) writeToURL:url atomically:YES];
            
            
        });
        
        
        
        
    }else{
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error creating thumbnail" message:@"error creating a thumbnail for your video." delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil];
        [errorAlert show];
        
    }
    
}

- (NSString*)takeScreenShot{
    
    if(self.buildItem.thumbnailPath != @""){//this one has a thumbnail already, so delete it
        NSError *error;
        NSFileManager *mgr = [NSFileManager defaultManager];
        if ([mgr removeItemAtPath:self.buildItem.thumbnailPath error:&error] != YES)
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    }
    
    NSString* UUID = [self GetUUID];
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.5);
    //else
    //   UIGraphicsBeginImageContext(self.view.bounds.size);
    
    //UIGraphicsBeginImageContext(self.view.bounds.size);    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSString *imageName = [NSString stringWithFormat:@"screen_%@",UUID];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpg",imageName]];
    NSURL *url = [NSURL fileURLWithPath:path];
    [UIImageJPEGRepresentation(viewImage, 0.75f) writeToURL:url atomically:YES];
    return path;
}

- (IBAction)showVideo:(id)sender{
    NSLog(@"buildItem.videoPath: %@", self.buildItem.videoPath);
    if(self.buildItem.videoPath != NULL && self.buildItem.videoPath != @""){
        
        //        CGRect btnArea = CGRectMake(150.0f, 5.0f, 100.0f, 30.0f);
        //        
        //        UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //        [returnBtn setFrame:btnArea];
        //        [returnBtn setTitle:@"Return" forState:UIControlStateNormal];
        //        [returnBtn sizeToFit];
        //        [returnBtn addTarget:self action:@selector(returnFromVideo:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        
        // stub for the full method to show the video using the mpmovieplayer
        NSURL *vidURL = [NSURL URLWithString:self.buildItem.videoPath];
        MPMoviePlayerViewController *mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:vidURL];
        [mpvc shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientationPortrait == UIInterfaceOrientationLandscapeLeft)];
        
        [self presentMoviePlayerViewControllerAnimated:mpvc];
        
        //            self.mp  = [[MPMoviePlayerController alloc] initWithContentURL:vidURL];
        //            self.mp.shouldAutoplay = YES;
        //            self.mp.controlStyle = MPMovieControlStyleDefault;
        //            self.mp.movieSourceType = MPMovieSourceTypeFile;
        //            [self.mp prepareToPlay];
        //            [self.mp.view setFrame:self.view.bounds];
        //        [self.mp.view addSubview:returnBtn];
        //            [self.view addSubview:self.mp.view];
        //            [self.mp play];
        //            [self.mp setFullscreen:YES animated:YES];
        
        
        
    }
    
}


- (IBAction)save:(id)sender{
    
    self.buildItem.screenTitle = self.titleTxt.text;
    self.buildItem.thumbnailPath = [self takeScreenShot];
    [self.delegate updateBuildItem:self.buildItem];// call to the delegate to tell the delegate to update the buildItem  with the properties the user created here
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)cancel:(id)sender{
    [self.delegate userDidCancelFromEditor:self.buildItem];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)deleteBuildItem:(id)sender{
    [self.delegate deleteBuildItem:self.buildItem];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) populateItems{
    self.buildItem = (VideoOnlyMO*)self.buildItem;
    
    if(self.buildItem.thumbnailImage == NULL){
        NSString *iconPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/placeholder1.jpg"];
        UIImage *icon = [[UIImage alloc] initWithContentsOfFile:iconPath];
        [self.thumbButton setImage:icon forState:UIControlStateNormal];
    }else{
        NSURL *imgURL = [NSURL URLWithString:self.buildItem.thumbnailImage];
        UIImage *myImage = [UIImage imageWithContentsOfFile:[imgURL path]];
        [self.thumbButton setImage:myImage forState:UIControlStateNormal];
        [self.thumbButton addTarget:self action:@selector(showVideo:)  forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.titleTxt.text = self.buildItem.screenTitle;
}



@end
