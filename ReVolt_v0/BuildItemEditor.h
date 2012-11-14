//
//  BuildItemEditor.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuildMainEditScreen.h"
@class TemplatePicker;
@class TemplateLoader;

@interface BuildItemEditor : UITableViewController <UITextFieldDelegate, TemplatePickerDelegate>{
    BOOL _didMakeChanges;// flag to allow us to know if something was changed. If something was changed, then we update the build when returning, otherwise we simply pop to the previous BuildMainEditScreen view controller
    UITextField *activeField;// allows us to track whether the title or another textfield has been tapped so we can provide the necessary keyboard adjustments
    id <ItemEditor> _delegate;// the item editor delegate will allow the class to communicate with BuildMainEditScreen's protocol methods
    // interface elements and buttons common to all editors
    UITextField *_titleTxt;
    UIBarButtonItem *_saveBtn;
    UIBarButtonItem *_cancelBtn;
    UIBarButtonItem *_swapTemplateBtn;
}


@property (strong, nonatomic) id <ItemEditor> delegate;
@property (strong, nonatomic) IBOutlet UITextField *titleTxt;// the title, all editors must have a title
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBtn;// saveBtn is used on all editors to allow the user to save changes and return to the main edit screen
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;// cancelBtn, cancels changes and returns to the main edit screen
@property (strong, nonatomic) IBOutlet UIBarButtonItem *swapTemplateBtn;// swapTemplateBtn will bring up the templatepicker so the user can choose a new template. If they choose a new one, the changes from the old one will be lost and a new template will be added to the viewstack of the navigationcontroller in place of the old one
@property BOOL didMakeChanges;// this BOOL changes to YES anytime the user changes any of the text, graphics or video associated with the editor


- (void) setupDoneBtn;// this method will create a done button in the navigationbar at the top of the view so the user can dismiss the keyboard when done editing a textView
-(IBAction)swapTemplate:(id)sender;// swapTemplate method calls the templatepicker modally so the user can choose to swap the template. The user will lose the data on this view and this buildItem if the choose to switch the templates
- (IBAction)save:(id)sender;// called when the user chooses to save, this will interface with the delegate's ItemEditor protocol methods

- (IBAction)cancel:(id)sender;// this is called if the user doesn't want to make any changes to the item, it will pop back to the BuildMainEditScreen view controller

- (UIImage*) takeScreenShot;// this is responsible for taking a screenshot of this screen and returning that image. That image will then be used as the preview image on the BuildMainEditScreen

@end
