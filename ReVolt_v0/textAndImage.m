
//
//  textAndImage.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "textAndImage.h"
#import "audioOnly.h"
#import "textAndVideo.h"
#import "textOnlyEditor.h"
#import "videoOnly.h"
#import "TemplateLoader.h"
#import "TextAndImageMO.h"
#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)// reference to the bgQueue

@implementation textAndImage
@synthesize fromCameraBtn;
@synthesize fromPhotosBtn;
@synthesize imageView = _imageView;
@synthesize lib = _lib;
@synthesize buildItem = _buildItem;
@synthesize screenText;
@synthesize indicator = _indicator;
@synthesize rotateBtn;
@synthesize editBtn;



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
  
    self.buildItem = (TextAndImageMO*)[self.delegate loadBuildItem];
    NSLog(@"*****ID: %@", self.buildItem.imagePath);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedWritingImage:) name:@"ImageSaved" object:nil];
    self->_didFinishEditing = YES;
    [self populateItems];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    

    [self setFromCameraBtn:nil];
    [self setFromPhotosBtn:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
}

#pragma mark ScreenTextEditor protocol methods

- (void) didFinishEditingText:(NSString*) editedText{
    
    self.screenText.text = editedText;
    [self dismissModalViewControllerAnimated:YES];
    self->_didFinishEditing = YES;
}

#pragma mark textView methods


-(void) setDidFinishEditing:(BOOL) isFinished{
    self->_didFinishEditing = isFinished;
}


#pragma mark - camera functions

-(void)useCamera{
    // check to see if the camera is on the devie
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        
        // create the UIImagePickerController and set this ViewController as it's delegate, then declare the source types, media types and editing preferences
        newMedia = YES;
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil];// including <MobileCoreServices/MobileCoreServices.h> with the header file is what allows us to use kUTTypeImage
        imagePicker.allowsEditing = YES;
        [self presentModalViewController:imagePicker animated:YES];
        
        
        
        
    }
}

-(void)usePhotos{
    // check to see if the camera roll is available on this device
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
        // just like the previous, create the imagePicker, set this as it's delegate and set the sourceType to the camera roll, then allow images as the media type and specify no for editing, and present the new view controller modally
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
        newMedia = NO;
        
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if(self.indicator == nil){
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.indicator setCenter:self.view.center];
        [self.view addSubview:self.indicator];
        [self.indicator startAnimating];
        
    }
    
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        
        UIImage *imgToUse = [info objectForKey:UIImagePickerControllerEditedImage];
        if(imgToUse == NULL){
            imgToUse = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
       // self.imageView.image = imgToUse; // set the image view to this image
        
        if(picker.sourceType != UIImagePickerControllerSourceTypePhotoLibrary){// if it's from the camera, write it to the saved photos album
            
            [self.lib writeImageToSavedPhotosAlbum:[imgToUse CGImage] orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
                
                
                
                if(!error){
                    //self.buildItem.imagePath = [assetURL absoluteString];
                    [self performSelectorOnMainThread:@selector(saveThumb:) withObject:assetURL waitUntilDone:NO];
                }else{
                    NSLog(@"error: %@",error);
                }
                
            }];
        }else{// if it's the camera
            NSURL *assetURL = [info valueForKey:UIImagePickerControllerReferenceURL];
            
//            self.buildItem.imagePath = [assetURL absoluteString];
//            NSLog(@"videoPath: %@",self.buildItem.imagePath);
            [self performSelectorOnMainThread:@selector(saveThumb:) withObject:assetURL waitUntilDone:NO];
        }
                
        [self dismissModalViewControllerAnimated:YES];
            
    }
}

// this method conforms to the method specified by the completion selector argument of the UIImageWriteToSavedPhotosAlbum method above - that method is part of UIKit functions and named in the UIImage class
        
        
// final delegate method for cancellation by user
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}

// this method should save the downscaled thumbnail into the Documents directory
-(void) saveThumb:(NSURL *)assetURL{
   [self.lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
       //UIImage *thumb = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];//
       
       // downscale this image and make it's orientation up
       UIImage *preview = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage] scale:0.5 orientation:UIImageOrientationUp];
                                                     
            [self performSelectorOnMainThread:@selector(saveNewImage:) withObject:preview waitUntilDone:NO];
           [self performSelectorOnMainThread:@selector(showImageInThumb:) withObject:preview waitUntilDone:NO];

       
   } failureBlock:^(NSError *error) {
       NSLog(@"Error on save: %@", [error localizedDescription]);
   }];
   
}

-(Boolean)saveNewImage:(UIImage*)img{
    // don't delete here, just delete in the rotate
//    if(self.buildItem.imagePath != @""){//check to see if we already stored an earlier image, if so, delete that one because we're going to save a new one
//        NSError *error;
//        NSFileManager *mgr = [NSFileManager defaultManager];
//        NSString* str = self.buildItem.imagePath;
//        if ([mgr removeItemAtPath:self.buildItem.imagePath error:&error] != YES)
//            NSLog(@"Unable to delete file: %@ : %@ : %@ : %@", [error localizedDescription],[error localizedFailureReason], [error localizedRecoverySuggestion],  [error localizedRecoveryOptions]);
//    }
    
    // create the filename and save the image to the documents directory
    NSString *imageName = [NSString stringWithFormat:@"image_%@",  [self GetUUID]];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpg",imageName]];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSLog(@"build image name: %@",imageName);
    
    [UIImageJPEGRepresentation(img, 0.75f) writeToURL:url atomically:YES];
    self.buildItem.imagePath = path;
        
    NSLog(@"videoPath: %@",self.buildItem.imagePath);
    
    return YES;
    
   // NSLog(@"THERE WAS A PROBLEM SAVING THE IMAGE");
    // return NO;
}

-(void)showImageInThumb:(UIImage *)img{
    
    self.imageView.image = img;
    [self.indicator removeFromSuperview];
    [self.indicator stopAnimating];
    self.indicator = nil;
    
    //    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 100), NO, 0.0);
//    CGContextRef con = UIGraphicsGetCurrentContext();
//    UIImage * test = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    con = UIGraphicsGetCurrentContext();
//    
//    
//    [test drawAtPoint:CGPointMake(0, 0)];
//    CGContextTranslateCTM(con, 20, 100);
//    CGContextRotateCTM(con, 30 * M_PI/180.0);// this is the radians calculation
//    CGContextTranslateCTM(con, -20, -100);
//    [test drawAtPoint:CGPointMake(0,0)];
    
}
-(IBAction)rotateIt:(id)sender{
    UIImage* img = [self rotateIMG:self.imageView.image];
    self.imageView.image = img;
}

-(UIImage*)rotateIMG:(UIImage*)src{
//    UIImage * LandscapeImage = src;
//    UIImage * PortraitImage = [[UIImage alloc] initWithCGImage: LandscapeImage.CGImage
//                                                         scale: 1.0
//                                                   orientation: UIImageOrientationLeft];
    
    UIImageOrientation orient = src.imageOrientation;
    CGImageRef ref = src.CGImage;
    UIImage *newImage; 
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            NSLog(@"image orientation: UP");
            newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationRight];
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
                  NSLog(@"image orientation: UP mirrored");
            newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationRight];
            break;
            
        case UIImageOrientationDown: //EXIF = 3
                 NSLog(@"image orientation: Down");
            newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationLeft];
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationLeft];
              NSLog(@"image orientation: UP");
            break;
            
        case UIImageOrientationLeft: //EXIF = 5
             NSLog(@"image orientation: Left mirrored");
            newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationUp];
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 6
             NSLog(@"image orientation: Left");
            newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationUp];
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
             NSLog(@"image orientation: Right mirrored");
            newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationDown];
            break;
            
        case UIImageOrientationRight: //EXIF = 8
             NSLog(@"image orientation: Right");
            newImage = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationDown];
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
//    if(self.buildItem.imagePath != @""){//check to see if we already stored an earlier image, if so, delete that one because we're going to save a new one
//        NSError *error;
//        NSFileManager *mgr = [NSFileManager defaultManager];
//        NSString* str = self.buildItem.imagePath;
//        if ([mgr removeItemAtPath:self.buildItem.imagePath error:&error] != YES)
//            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
//    }
//    
//    // create the filename and save the image to the documents directory
//    NSString *imageName = [NSString stringWithFormat:@"screen_%@",self.buildItem.screenID];
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.jpg",imageName]];
//    NSURL *url = [NSURL fileURLWithPath:path];
//    if([UIImageJPEGRepresentation(newImage, 0.75f) writeToURL:url atomically:YES]){
//        self.buildItem.imagePath = path;
//        
//        NSLog(@"imagePath: %@",self.buildItem.imagePath);
//        
//    }
    
    if([self saveNewImage:newImage]){
        return newImage;
    }
    
    return nil;
}

- (NSString*)takeScreenShot{
    
    if(self.buildItem.thumbnailPath != @""){//this one has a thumbnail already, so delete it
        NSError *error;
        NSFileManager *mgr = [NSFileManager defaultManager];
        NSString* str = self.buildItem.thumbnailPath;
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

- (IBAction)save:(id)sender{
    
    self.buildItem.screenTitle = self.titleTxt.text;
    self.buildItem.screenText = self.screenText.text;
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
    self.buildItem = (TextAndImageMO*)self.buildItem;
    
    if(self.buildItem.imagePath == NULL){
        NSString *iconPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/placeholder1.jpg"];
        UIImage *icon = [[UIImage alloc] initWithContentsOfFile:iconPath];
        self.imageView.image = icon;
    }else{
        //NSURL *imgURL = [NSURL URLWithString:self.buildItem.imagePath];
//        if(self.indicator == nil){
//                self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//                self.indicator.frame=CGRectMake(145, 160, 200, 200);
//                [self.indicator setCenter:self.view.center];
//                [self.view addSubview:self.indicator];
//                [self.indicator startAnimating];
//        }
//        [self.lib assetForURL:imgURL resultBlock:^(ALAsset *asset) {
//            UIImage *test = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
//            
//            if([[NSThread currentThread] isMainThread]){
//                [self showImageInThumb:test];
//            }else{
//                [self performSelectorOnMainThread:@selector(showImageInThumb:) withObject:test waitUntilDone:YES];
//            }
//            
//            
//        } failureBlock:^(NSError *error) {
//            NSLog(@"Error on save: %@", [error localizedDescription]);
//        }];
        
        
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicator.frame=CGRectMake(145, 160, 200, 200);
        [self.indicator setCenter:self.view.center];
        [self.view addSubview:self.indicator];
        [self.indicator startAnimating];

        
        UIImage *returnImage = [UIImage imageWithContentsOfFile:self.buildItem.imagePath];
        [self showImageInThumb:returnImage];
    }
   
    self.titleTxt.text = self.buildItem.screenTitle;
    self.screenText.text = self.buildItem.screenText;
        
}


- (IBAction)editText:(id)sender {
    if(self->_didFinishEditing){
        TextEntryViewController *te = [[TextEntryViewController alloc] initWithNibName:@"TextEntryViewController" bundle:[NSBundle mainBundle]];
        te.delegate = self;
        [te showTextToEdit:self.screenText.text];
        [self presentModalViewController:te animated:YES];
    }
    
}


@end



