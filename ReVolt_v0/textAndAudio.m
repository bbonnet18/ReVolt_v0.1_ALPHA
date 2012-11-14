//
//  textAndAudio.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "textAndAudio.h"
#import "audioOnly.h"
#import "textAndImage.h"
#import "textAndVideo.h"
#import "textOnlyEditor.h"
#import "videoOnly.h"
#import "TemplateLoader.h"

@implementation textAndAudio
@synthesize addAudioBtn;
@synthesize scrollView;
@synthesize screenText;
@synthesize editBtn;
@synthesize buildItem = _buildItem;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self->_didFinishEditing = YES;
    self.buildItem = (TextAndAudioMO*)[self.delegate loadBuildItem];
    NSLog(@"*****ID: %@", self.buildItem.audioPath);
    [self populateItems];


}



- (void)viewDidUnload
{
  
    [self setEditBtn:nil];
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

#pragma mark add audio



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

- (IBAction)save:(id)sender{
    
    self.buildItem.screenTitle = self.titleTxt.text;
    self.buildItem.thumbnailPath = [self takeScreenShot];
    self.buildItem.screenText = self.screenText.text;
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

- (IBAction)editText:(id)sender {
    if(self->_didFinishEditing){
        TextEntryViewController *te = [[TextEntryViewController alloc] initWithNibName:@"TextEntryViewController" bundle:[NSBundle mainBundle]];
        te.delegate = self;
        [te showTextToEdit:self.screenText.text];
        [self presentModalViewController:te animated:YES];
    }

}

- (IBAction)addAudio:(id)sender{
    UIButton *btn = sender;
    btn.titleLabel.text = @"Added";
    self.buildItem.screenTitle = self.titleTxt.text; 
    

}

- (void) populateItems{

    self.titleTxt.text = self.buildItem.screenTitle;
    self.screenText.text = self.buildItem.screenText;
   
}






@end
