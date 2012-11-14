//
//  videoOnly.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemEditor.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoOnlyMO.h"


@interface videoOnly : ItemEditor  <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    
    BOOL newMedia;
    ALAssetsLibrary *_lib;
    VideoOnlyMO *_buildItem;
    NSURL *_vidAssetURL;
    UIButton *_thumbButton;
    UIActivityIndicatorView *_indicator;


}


@property (strong, nonatomic) IBOutlet UIButton *fromCameraBtn;
@property (strong, nonatomic) IBOutlet UIButton *fromPhotosBtn;
@property (strong, nonatomic) ALAssetsLibrary *lib; 
@property (strong, nonatomic) VideoOnlyMO *buildItem;
@property (nonatomic, strong) IBOutlet UIButton *thumbButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;// to show the indicator while the thumb is being created
@property (strong, nonatomic) NSURL *vidAssetURL;// holds the url to the video for this item
-(IBAction)useCamera;
-(IBAction)usePhotos;

- (void) buildThumb:(NSURL*) assetURL;
- (IBAction)showVideo:(id)sender;// when the user taps the image, show the video

@end
