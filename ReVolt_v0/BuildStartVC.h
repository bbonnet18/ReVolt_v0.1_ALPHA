//
//  BuildStartVC.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface BuildStartVC : UIViewController{
    UIButton *_myBuildsBtn;
    //id <BuildEditor> _delegate;
    NSManagedObjectContext *_context;
}
- (IBAction)goToMyBuilds:(id)sender;
- (IBAction)goToGroups:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *myBuildsBtn;
@property (strong, nonatomic) IBOutlet UIButton *groupsBtn;
//@property (strong, nonatomic) id <BuildEditor> delegate;
@property (strong, nonatomic) NSManagedObjectContext *context;
@end
