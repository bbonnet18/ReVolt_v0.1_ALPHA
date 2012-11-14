//
//  TemplatePicker.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TemplatePickerDelegate

- (void) didChooseTemplate: (NSString*) templateType;
- (void) userDidCancel;

@end

@interface TemplatePicker : UIViewController{
    
    UIButton *_textAndImageBtn;
    UIButton *_textAndVideoBtn;
    UIButton *_textAndAudioBtn;
    UIButton *_videoOnlyBtn;
    UIButton *_cancelBtn;
    id <TemplatePickerDelegate> _delegate;

}
@property (strong, nonatomic) IBOutlet UIButton *textAndImageBtn;
@property (strong, nonatomic) IBOutlet UIButton *textAndVideoBtn;
@property (strong, nonatomic) IBOutlet UIButton *textAndAudioBtn;
@property (strong, nonatomic) IBOutlet UIButton *videoOnlyBtn;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) id <TemplatePickerDelegate> delegate;

- (IBAction)selectTemplate:(id)sender;// this will take the button and select the proper editor
- (IBAction)cancel:(id)sender;// cancels and pops the view controller

@end
