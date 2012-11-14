//
//  FirstLearnViewController.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface FirstLearnViewController : UIViewController
{
    IBOutlet UIButton *twoBtn;
    id <NavDelegate> delegate;
}

@property (strong,nonatomic) IBOutlet UIButton *twoBtn;

@property (strong, nonatomic) id <NavDelegate> delegate;

-(IBAction)switchViews:(id)sender;

@end
