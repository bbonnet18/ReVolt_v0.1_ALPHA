//
//  PictureTaker.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface PictureTaker : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>// must impliment both protocols
{
    
    // private variables
    
    UIImageView *imageView;
    BOOL newMedia;
}

@property (nonatomic,strong) IBOutlet UIImageView *imageView;
-(IBAction)useCamera;
-(IBAction)useCameraRoll;
-(IBAction)goHome:(id)sender;
@end
