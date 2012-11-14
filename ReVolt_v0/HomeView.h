//
//  HomeView.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BuildObjects;

@interface HomeView : UIViewController{
    IBOutlet UIButton  *buildBtnOutlet;
    IBOutlet UIImageView *networkIndicator; 
    NSMutableString *log;
    BOOL networkAvailable;// no star because this is not a pointer, it's a primitive
    IBOutlet UILabel *lbl;
    IBOutlet UIButton *uploadBtnOutlet;
    IBOutlet UIButton *videoBtn;
    NSOperationQueue *mediaQueue;
   
    IBOutlet UIButton *buildVCBtn;
}

-(void) loadData;
-(void) downloadedData:(NSData*)data;
- (void) createWithColor: (UIColor *) aColor;

- (IBAction)launchCamera:(id)sender;
- (IBAction)testAction:(id)sender;
- (IBAction)testMovie:(id)sender;

-(IBAction)launchLearn:(id)sender;
-(IBAction)launchBuildVC:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *buildBtnOutlet;
@property (strong, nonatomic) IBOutlet UIButton *uploadBtnOutlet;
@property (strong, nonatomic) IBOutlet UIButton *videoBtn;

@property (strong, nonatomic) IBOutlet UIImageView *networkIndicator;
@property (strong, nonatomic) IBOutlet UILabel *lbl;
@property (strong, nonatomic) IBOutlet UIButton *cameraBtn;
@property (nonatomic,assign) BOOL networkAvailable;
@property (strong,nonatomic) NSOperationQueue *mediaQueue;
@property (strong, nonatomic) IBOutlet UIButton *buildVCBtn;




@end
