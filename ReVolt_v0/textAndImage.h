//
//  textAndImage.h
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
#import "TextAndImageMO.h"
#import "TextEntryViewController.h"


@interface textAndImage : ItemEditor <UIImagePickerControllerDelegate, UINavigationControllerDelegate, ScreenTextEditor>
{
    
    // private variables
    UIActivityIndicatorView *_indicator;
    UIImageView *_imageView;
    BOOL newMedia;
    ALAssetsLibrary *_lib;
    TextAndImageMO *_buildItem;
    UIImageOrientation _orient;
    BOOL _didFinishEditing;

    

}
@property (strong, nonatomic) IBOutlet UIButton *fromCameraBtn;
@property (strong, nonatomic) IBOutlet UIButton *fromPhotosBtn;
@property (strong, nonatomic) IBOutlet UIButton *rotateBtn;
@property (strong, nonatomic) IBOutlet UITextView *screenText;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;// to show the indicator while the thumb is being created
@property (nonatomic,strong) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) ALAssetsLibrary *lib; 
@property (strong, nonatomic) TextAndImageMO *buildItem;
@property (strong, nonatomic) IBOutlet UIButton *editBtn;

-(IBAction)useCamera;
-(IBAction)usePhotos;
-(void)saveThumb:(NSURL*) assetURL;// this will show the thumbnail
-(void)showImageInThumb:(UIImage*) img;
-(UIImage*)rotateIMG:(UIImage*)src;
-(IBAction)rotateIt:(id)sender;
@end
