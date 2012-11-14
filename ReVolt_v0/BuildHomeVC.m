//
//  BuildHomeVC.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BuildHomeVC.h"
#define HOME_DIR @"/Documents/";// the home documents directory



@implementation BuildHomeVC
@synthesize files = _files;// synthesize files and make equal to the private iVar
@synthesize image1 = _image1;
@synthesize scroller = _scroller;

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
    // Do any additional setup after loading the view from its nib.
    
    
    NSString *val1; 
    val1 = [NSHomeDirectory() stringByAppendingString:@"/Documents/crystal.png"];
    UIImage *firstImage  = [[UIImage alloc] initWithContentsOfFile:val1];
    [self.image1 setImage:firstImage];
    
    
    CGFloat y = 10; // float is a core object, so it doesen't need a pointer, assuming
    
    
    for(int i=0; i<30; i++){
        
        UIImage *secondImage  = [[UIImage alloc] initWithContentsOfFile:val1];
        [self.image1 setImage:firstImage];
        
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(5, y, 90, 90)];
        [img setImage:secondImage];
        
        [self.scroller addSubview:img];
        
        y += img.bounds.size.height + 10;
        
    }
    
    CGSize sz = self.scroller.bounds.size;//scroller.bounds.size;
    sz.width = 100;
    sz.height = y;
    
    self.scroller.contentSize = sz;
    
   
//    CGFloat y = 10;
//    for (int i=0; i<30; i++) {
//        UILabel* lab = [[UILabel alloc] init];
//        lab.text = [NSString stringWithFormat:@"This is label %i", i+1];
//        [lab sizeToFit];
//        CGRect f = lab.frame;
//        f.origin = CGPointMake(10,y);
//        lab.frame = f;
//        [self.scroller addSubview:lab];
//        y += lab.bounds.size.height + 10;
//        
//                lab.backgroundColor = [UIColor redColor]; // make label bounds visible
//                lab.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//                
//        
//    }
//    CGSize sz = self.scroller.bounds.size;
//    sz.height = y;
//    self.scroller.contentSize = sz; // This is the crucial line
    
//    NSString* hello = @"hello";
    
    
}

- (void)viewDidUnload
{
    [self setImage1:nil];
    [self setScroller:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
