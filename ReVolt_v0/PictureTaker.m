//
//  PictureTaker.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PictureTaker.h"
#import "AppDelegate.h"
@implementation PictureTaker
@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - camera functions

-(void)useCamera{
    // check to see if the camera is on the devie
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        
        // create the UIImagePickerController and set this ViewController as it's delegate, then declare the source types, media types and editing preferences
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil];// including <MobileCoreServices/MobileCoreServices.h> with the header file is what allows us to use kUTTypeImage
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
        newMedia = YES;
        
        
        
    }
}

-(void)useCameraRoll{
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
    [self dismissModalViewControllerAnimated:YES];// dismiss the modal picker snatcher view
    // check to see if the media is an image
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage]; // this will get the original image
        imageView.image = image; // set the image view to this image
        
        if(newMedia)
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:finishedSavingWithError: contextInfo:),nil);
        
    }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        // this is for the video if it's a video, would need to mimic the same kind of save procedure as above, but for video, which uses a path rather than a direct object -  so you would have to query the dictionary object (info) for the path of the video, then bring up a video player
        
        
    }
}
// this method conforms to the method specified by the completion selector argument of the UIImageWriteToSavedPhotosAlbum method above - that method is part of UIKit functions and named in the UIImage class
-(void) image:(UIImage *)image finishedSavingWithError:(NSError *) error contextInfo:(void *)contextInfo{
    
    if(error){// if there was an error, show an alert message and allow the user to cancel that
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Failed" message:@"Failed to save image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}
// final delegate method for cancellation by user
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)goHome:(id) sender{

    AppDelegate *ad =  (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [ad home];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.imageView = nil;// release this 
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
