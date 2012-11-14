//
//  BuildHomeVC.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuildHomeVC : UIViewController
{
    
    NSMutableArray *_files;//array of files needed for the images
    IBOutlet UIScrollView *scroller;
}

@property (strong, nonatomic) NSMutableArray* files;

@property (strong, nonatomic) IBOutlet UIImageView *image1;
@property (strong, nonatomic) IBOutlet UIScrollView *scroller;


@end
