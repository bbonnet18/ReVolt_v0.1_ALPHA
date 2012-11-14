//
//  textAndImage.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ItemEditor.h"
#import "TextAndAudioMO.h"
#import "TextEntryViewController.h"
@interface textAndAudio : ItemEditor <ScreenTextEditor>
{
    TextAndAudioMO *_buildItem;
    BOOL _didFinishEditing;
}


@property (strong, nonatomic) IBOutlet UIButton* addAudioBtn;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextView *screenText;
@property (strong, nonatomic) IBOutlet UIButton *editBtn;
@property (strong, nonatomic) TextAndAudioMO *buildItem;
- (IBAction)editText:(id)sender;
- (IBAction)addAudio:(id)sender;
@end
