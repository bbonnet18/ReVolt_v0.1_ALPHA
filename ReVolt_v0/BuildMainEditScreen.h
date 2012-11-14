//
//  BuildMainEditScreen.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TemplatePicker.h"
#import "Build.h"
#import "BuildItem.h"
#import "UploadViewer.h"
#import "ItemEditor.h"
#import "Response.h"
#import "Post.h"

@class TemplateLoader;

@protocol ItemEditor
@optional

- (void) updateBuildItem: (BuildItem*) updatedItem;// updates the build with the buildItem provided
- (void) updateBuildItemIDs;// updates the item ids to the order they occupy in the array
- (void) deleteBuildItem: (BuildItem*) buildToDelete;// sends back the build to delete to the delegate so the delegate can perform the work of deleting

- (BuildItem*) loadBuildItem;// this will get the BuildItem, this is called on the BuildMainEditScreen 

- (void) setCurrentItemTypeString: (NSString*) itemType;// this is used when a template item is chosen, it sets the currentBuildItemType on the main edit screen
- (BOOL) buildItemIsNew; // called to tell the target that the buildItem assigned to it, is a new one. Mostly for deleting a new buildItem if it's never been updated and saved
- (void) userDidCancelFromEditor:(BuildItem*) newItemToRemove;// new items are created when the user chooses to add a new BuildItem. This will be called when a user changes his/her mind and chooses not to create a new item 

@end


@interface BuildMainEditScreen : UIViewController <TemplatePickerDelegate, UIAlertViewDelegate, NSFetchedResultsControllerDelegate, ItemEditor, UIScrollViewDelegate, UIPageViewControllerDelegate>
{

    //id <BuildEditor> _delegate;
    NSMutableArray *_currentBuildItems;
    NSInteger _buildItemIndex;
    NSInteger _tempNewIndex;
    TemplateLoader *_tempLoader;
    NSMutableArray *_pageButtons;
    NSManagedObjectContext *_context;
    Post *_thisPost;
    Response *_thisResponse;
    Build *_currentBuild;
    NSString *_currentBuildItemType;
    BOOL _isNewItem;
    BOOL _didMakeChanges;
    BOOL _isPost;
    
    
}
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UIButton *publishBtn;
@property (strong, nonatomic) IBOutlet UIScrollView *scroller;
@property (strong, nonatomic) IBOutlet UIButton *afterBtn;
@property (strong, nonatomic) IBOutlet UIButton *beforeBtn;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIButton *rightBtn;
@property (strong, nonatomic) IBOutlet UIButton *leftBtn;

@property (strong, nonatomic) IBOutlet UILabel *indexLabel;

//@property (strong, nonatomic) id <BuildEditor> delegate;
@property (strong, nonatomic) TemplateLoader *tempLoader;
@property (strong, nonatomic) NSMutableArray *currentBuildItems;// holds all the NSMutableDictionary items that make up the builds items
@property (nonatomic, assign) NSInteger  buildItemIndex;// holds a reference to the number of the current build item so it can be manipulated
@property (nonatomic, assign) NSInteger tempNewIndex;// holds an index selected and this number is assigned to the real buildItemIndex if the user chooses a template, if not, the buildItemIndex stays the same. 
@property (strong, nonatomic) NSManagedObjectContext* context;// reference to the moc
@property (strong, nonatomic) Build *currentBuild;// holds a reference to this build
@property (strong, nonatomic) Response *thisResponse;// the response relative to the post
@property (strong, nonatomic) Post *thisPost;// the post that was provided
@property (strong, nonatomic) NSString *currentBuildItemType;// sets the item type so we can load the proper one

@property (strong, nonatomic) NSMutableArray *pageButtons;// holds a reference to buttons that will hold the images as they are loaded
@property (nonatomic, assign) BOOL isNewItem;// this is used to flag whether the user is creating a new item or if it's one that already exists
@property (nonatomic, assign) BOOL didMakeChanges;// flag to let us know whether any changes were made to the BuildItems
@property (nonatomic, assign) BOOL isPost;// is used to determine if this is a post creation process or a response creation process

- (IBAction)addAfter:(id)sender;// calls addNew and inserts after
- (IBAction)addBefore:(id)sender;// calls addNew and inserts before
- (IBAction)goLeft:(id)sender;
- (IBAction)goRight:(id)sender;
- (IBAction)addInitialItem:(id)sender;// triggered by the first button to add the first item
- (void) loadBuild;//  used to load all the items from the build if the build currently has any, 
- (void) setBuildItems;// sets the the build items in the scrollview, will need to be called on refresh

- (IBAction)handleButtonTapped:(id)sender;// handles when the user taps one of the items in the edit bar
- (NSString*) templateTypeToItemType: (NSString*) templateType;// returns a string with the BuildItem type based on the template type - just a convenience method to account for the fact that those are different by related 
- (BuildItem*) buildItemFromType:(NSString*) itemType;// returns a build item when provided with an item type string, another convenience method
- (NSString*) buildTypeToEditorType:(NSString*) buildType;// returns the editor type from the build type so it can be loaded
- (void) loadInitialItem;// loads the first item as a placeholder if there are no current items
- (void) loadVisiblePages;  // loads the pages that are visible at the moment
- (void) loadPage:(NSInteger)page;// loads a specific page 
- (void) purgePage:(NSInteger)page;// deletes a page from the array 
- (void) changePageScrollSize;// page scroll size changes 
- (void) handleItemChanges:(NSNotification*) notification;// this is the gandler for items changed
- (void)addNew:(NSInteger)page;// adds a new buildItem to currentBuildItems 
- (IBAction) chooseItem:(id)sender;// launches the item editor for the item chosen
- (void)updateIndex; // simply updates the index label

- (IBAction) publishBuild:(id) sender;// will commence publishing of the build
@end
