//
//  textOnlyEditor.m
//  ReVolt_v0
//
//  Created by Ben Bonnet on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "textOnlyEditor.h"

@interface textOnlyEditor ()

@end

#import "textOnlyEditor.h"
#import "textAndImage.h"
#import "textAndVideo.h"
#import "videoOnly.h"
#import "TemplateLoader.h"


@implementation textOnlyEditor

@synthesize buildItem = _buildItem;
@synthesize screenText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.buildItem = (TextOnlyMO*)[self.delegate loadBuildItem];
    NSLog(@"*****ID: %@", self.buildItem.screenTitle);
    [self populateItems];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.screenText = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (UIInterfaceOrientationIsPortrait(interfaceOrientation) ||  UIInterfaceOrientationIsLandscape(interfaceOrientation));
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
    self.buildItem = (TextOnlyMO*)self.buildItem;
    
    self.titleTxt.text = self.buildItem.screenTitle;
    self.screenText.text = self.buildItem.screenText;
    
}



@end
