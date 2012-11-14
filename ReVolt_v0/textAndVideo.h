//
//  textAndVideo.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemEditor.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "TextEntryViewController.h"

@interface textAndVideo : ItemEditor  <UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAsynchronousKeyValueLoading, UIAlertViewDelegate, ScreenTextEditor>{
    UIActivityIndicatorView *_indicator;
    BOOL newMedia;
    ALAssetsLibrary *_lib;
    TextAndVideoMO *_buildItem;
   // MPMoviePlayerController *_mp;
    NSURL *_vidAssetURL;
    UIButton *_thumbButton;
    BOOL _didFinishEditing;

}
@property (strong, nonatomic) IBOutlet UIButton *fromCameraBtn;
@property (strong, nonatomic) IBOutlet UIButton *fromPhotosBtn;
@property (strong, nonatomic) IBOutlet UITextView *screenText;
@property (nonatomic, strong) IBOutlet UIButton *thumbButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;// to show the indicator while the thumb is being created
@property (strong, nonatomic) ALAssetsLibrary *lib; 
@property (strong, nonatomic) TextAndVideoMO *buildItem;

//@property (strong, nonatomic) MPMoviePlayerController *mp;// to control the movie that's added after captures
@property (strong, nonatomic) NSURL *vidAssetURL;// holds the url to the video for this item
@property (strong, nonatomic) IBOutlet UIButton *editBtn;

- (void) buildThumb:(NSURL*) assetURL;
-(IBAction)useCamera;
-(IBAction)usePhotos;
- (IBAction)showVideo:(id)sender;// when the user taps the image, show the video
@end
