///
//  BuildMainEditScreen.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
// 
/*  
 
 this and all other editor classes will follow the same pattern. Each uses the item editor delegate to pass BuildItems to the delegate and receive them from the delegate when the editor loads. Each editor provides the ability for the the user to choose a different editor to replace this one. If the user chooses a new editor, the BuildItem for this editor is never saved and is actually deleted from the BuildItems set and a new BuildItem is added for the new editor. 
 
 */

#import "BuildMainEditScreen.h"
#import "textAndImage.h"
#import "textAndVideo.h"
#import "textOnlyEditor.h"
#import "videoOnly.h"
#import "TemplateLoader.h"
#import "TextAndImageMO.h"
#import "TextAndVideoMO.h"
#import "VideoOnlyMO.h"


@implementation BuildMainEditScreen


@synthesize saveBtn;
@synthesize publishBtn;
@synthesize scroller;
@synthesize afterBtn;
@synthesize beforeBtn;
@synthesize pageControl = _pageControl;
//@synthesize delegate = _delegate;
@synthesize currentBuildItems = _currentBuildItems;
@synthesize buildItemIndex = _buildItemIndex;
@synthesize tempNewIndex = _tempNewIndex;
@synthesize tempLoader = _tempLoader;
@synthesize context = _context;
@synthesize currentBuild = _currentBuild;
@synthesize thisPost = _thisPost;
@synthesize thisResponse = _thisResponse;
@synthesize currentBuildItemType = _currentBuildItemType;
@synthesize pageButtons = _pageButtons;
@synthesize isNewItem = _isNewItem;
@synthesize didMakeChanges = _didMakeChanges;
@synthesize isPost = _isPost;
@synthesize leftBtn;
@synthesize indexLabel = _indexLabel;
@synthesize rightBtn;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleItemChanges:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.context];
        self.didMakeChanges = YES;
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)updateIndex{
    self.indexLabel.text = [NSString stringWithFormat:@"%d",self.buildItemIndex];

}

#pragma mark - handleItemChanges

- (void) handleItemChanges:(NSNotification*)notification{
    
    //triggered anytime data is updated on the object or any of the subobjects, even on the items passed to the ItemEditors

    NSSet* insertedObjects = [[notification userInfo]
                                objectForKey:NSInsertedObjectsKey] ;
    NSSet* deletedObjects = [[notification userInfo]
                               objectForKey:NSDeletedObjectsKey] ;
    NSSet* updatedObjects = [[notification userInfo]
                               objectForKey:NSUpdatedObjectsKey] ;
    
    if([updatedObjects count] > 0){
        // there are items to be updated. 
        NSArray *objs = [updatedObjects allObjects];
        for (int i=0; i< [objs count ]; i++){
            if([[objs objectAtIndex:i] isKindOfClass:[BuildItem class]]){
                
                Class c = [[objs objectAtIndex:i] class];
                NSString* className = NSStringFromClass(c);
                NSLog(@"CHANGES INCLUDE: %@",className);
            }
           /*this will return a BuildItem and a Build if both are updated*/ 
        }
    }

}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tempLoader = [[TemplateLoader alloc] init];
    self.tempLoader.templateType = @"template";
    self.pageButtons = [[NSMutableArray alloc] init];
    self.buildItemIndex = 0;
    [self updateIndex];
    self.isPost = NO;// set initially to NO so we don't mistake it for a post creation
    if(self.thisPost != nil){// if the post was provided then it's a post creation process not a response creation process
        self.isPost = YES;
    }
    
    [self loadBuild];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setSaveBtn:nil];
    [self setPublishBtn:nil];
    [self setScroller:nil];
    [self setAfterBtn:nil];
    [self setBeforeBtn:nil];
    
    [self setPageControl:nil];
    [self setIndexLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    if(self.didMakeChanges)
        [self setBuildItems];
    self.didMakeChanges = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


// adding new items to currentBuildItems and choosing by selecting a buildItem

- (IBAction)addBefore:(id)sender{
   // if(self.buildItemIndex > 0){
    NSLog(@"currentID: %d",self.buildItemIndex);
        NSInteger page = self.buildItemIndex;
        [self addNew:page];
   // }
        
    
}

- (IBAction)addAfter:(id)sender{
    
    //if(self.buildItemIndex < self.currentBuildItems.count - 1){
        NSLog(@"currentID: %d",self.buildItemIndex);
        NSInteger page = self.buildItemIndex+1;
        [self addNew:page];
    //}
    
}

/* need to make sure that the buildItemIndexes are being set correctly based on the scrolled to places, etc.
 
 */

-(IBAction)addInitialItem:(id)sender{
  
    self.buildItemIndex = 0;
    [self updateIndex];
    [self addNew:self.buildItemIndex];
}
- (void)addNew:(NSInteger)page{
    self.isNewItem = YES;// this is always set when choosing to add a new item. The changes are committed when the user follows through, or deleted when the user cancels the process
    if(page > 0)
        self.tempNewIndex = page;
    else
        self.tempNewIndex = 0;// this will hold the value, if the user chooses to go through with the template choice, this value will be assigned to buildItemIndex
    TemplatePicker *template = [[TemplatePicker alloc] initWithNibName:@"TemplatePicker" bundle:[NSBundle mainBundle]];
    template.delegate = self;        
    
    [self presentViewController:template animated:YES completion:^(void){
        // add in some post view showing stuff here, executes when the view is loaded and animated in
        
    }];

    
}


- (IBAction)chooseItem:(id)sender{
    UIButton* b = (UIButton*)sender;// get the button that was tapped
    self.buildItemIndex = b.tag;
    [self updateIndex];
    BuildItem *item = [self.currentBuildItems objectAtIndex:b.tag];
    // get the proper type
    
    NSString *buildType = item.type;
    self.currentBuildItemType = buildType;
    ItemEditor *vc = [self.tempLoader loadEditor:[self buildTypeToEditorType:buildType] withDelegate:self];
    [self.navigationController pushViewController:vc animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void) loadBuild{
    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Build" inManagedObjectContext:self.context];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setEntity:entityDescription];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"buildID == %@",[self.delegate getCurrentBuildID]];
//    [request setPredicate:predicate];
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
//    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//    
//    NSError *error = nil;
//    
//    NSArray *results = [self.context executeFetchRequest:request error:&error];
    // this is done so we can use this for both posts and responses
    if(self.isPost){
        self.currentBuild = [self.thisPost valueForKey:@"build"];
    }else{
        self.currentBuild = [self.thisResponse valueForKey:@"build"];
    }
    
    
}
// This method needs to account for the id's of the items as they are added and subtracted. 
- (void) setBuildItems{

    // remove all the items on the scroller
    if([[self.scroller subviews] count] > 0){
        [[self.scroller subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
    }

    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BuildItem" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"build == %@",self.currentBuild];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"screenID" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    
    //NSArray *results = [self.context executeFetchRequest:request error:&error];
    
    self.currentBuildItems = [NSMutableArray arrayWithArray:[self.context executeFetchRequest:request error:&error]];//[NSMutableArray arrayWithArray:[[self.currentBuild buildItems] allObjects]];
    
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = self.currentBuildItems.count;
    
    [self.pageButtons removeAllObjects];
    
    if(self.currentBuildItems.count >0){// if there are any items in the array, set them all to null 
        for(int i=0; i<[self.currentBuildItems count]; i++){
            
            BuildItem* bi = [self.currentBuildItems objectAtIndex:i];
            NSNumber *bID = [NSNumber numberWithInt:i];
            bi.screenID = bID;// set the BuildItem's screenID property to the sequence within the build's order
            
            [self.pageButtons addObject:[NSNull null]];// used as a placeholder for lazy loading purposes
            
        }

    }else{// we don't have any items so place an empty one on the screen
        //create the button and add it to the pageViews array
        CGRect frame = self.scroller.bounds;
        frame.origin.x = 0.0f;// set it to the first item
        frame.origin.y = 0.0f;
        
        UIButton *newPageButton = [[UIButton alloc] initWithFrame:frame];// set the frame size of the button to the frame size of the screen, but offset to account for the page we're on 
        newPageButton.contentMode = UIViewContentModeCenter;//UIViewContentModeScaleAspectFit;
        
        UIImage *icon = [UIImage imageNamed:@"placeholder1.jpg"];
        [newPageButton setImage:icon forState:UIControlStateNormal];
        [newPageButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [newPageButton addTarget:self action:@selector(addInitialItem:) forControlEvents:UIControlEventTouchUpInside];
        newPageButton.tag = 0;// set the tag of the button to the page that was selected (i.e. 1 of 5) 
        
        [self.scroller addSubview:newPageButton];
    }
    
            
    CGSize pagesScrollSize = self.scroller.frame.size;
    self.scroller.contentSize = CGSizeMake(pagesScrollSize.width * self.currentBuildItems.count, pagesScrollSize.height);
       
    CGRect scrollTo = self.scroller.bounds;
    
    scrollTo.origin.x = scrollTo.size.width * self.buildItemIndex;
    scrollTo.origin.y = 0.0f;
    
    
    [self.scroller scrollRectToVisible:scrollTo animated:YES];
    [self loadVisiblePages];
}


- (void) loadVisiblePages{
    CGFloat pageWidth = self.scroller.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scroller.contentOffset.x * 2.0f + pageWidth)/(pageWidth * 2.0f));
    //update the page control
    self.pageControl.currentPage = page;
    self.buildItemIndex = page;
    // work out which pages to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    for(NSInteger i = 0; i <firstPage; i++){
        [self purgePage:i];// get rid of those that aren't before the first
    }
    
    for(NSInteger i=firstPage; i<= lastPage; i++){
        [self loadPage:i];// load the visible pages
    }
    
    for(NSInteger i=lastPage +1; i<self.pageButtons.count; i++){
        [self purgePage:i];// get rid of those that are after the last page
    }
    
}


- (void) loadPage:(NSInteger)page{
    if(page < 0 || page >= self.pageButtons.count){
        return;
    }
    
    
    
    UIButton *pageButton = [self.pageButtons objectAtIndex:page];
    if((NSNull*) pageButton == [NSNull null]){// if it's null, then initialize and create the button and add it to the pageViews array
        CGRect frame = self.scroller.bounds;
        frame.origin.x = frame.size.width * page;// set the starting x point to the location on the scroller view, where it will reside
        frame.origin.y = 0.0f;
        
        UIButton *newPageButton = [[UIButton alloc] initWithFrame:frame];// set the frame size of the button to the frame size of the screen, but offset to account for the page we're on 
        newPageButton.contentMode = UIViewContentModeCenter;//UIViewContentModeScaleAspectFit;
        
        BuildItem *bi = [self.currentBuildItems objectAtIndex:page];
        
        NSString *iconPath = bi.thumbnailPath;// get the path to the thumbnail
        UIImage *icon = [[UIImage alloc] initWithContentsOfFile:iconPath];
        [newPageButton setImage:icon forState:UIControlStateNormal];
        [newPageButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [newPageButton addTarget:self action:@selector(chooseItem:) forControlEvents:UIControlEventTouchUpInside];
        newPageButton.tag = page;// set the tag of the button to the page that was selected (i.e. 1 of 5) 

        
        
        [self.scroller addSubview:newPageButton];
        [self.pageButtons replaceObjectAtIndex:page withObject:newPageButton];
    }
    
}

- (void) purgePage:(NSInteger)page{// remove by replacing it with a null value
    if(page <0 || page >= self.pageButtons.count){
        return;
        
    }
    
    UIButton *newPageButton = [self.pageButtons objectAtIndex:page];
    if((NSNull *) newPageButton != [NSNull null]){
        [newPageButton removeFromSuperview];
        [self.pageButtons replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}


#pragma mark - scrollview delegate methods

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self loadVisiblePages];// on scroll load visible images
}

- (void) pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    
}

#pragma mark - nav items - take out after testing

//- (IBAction)goLeft:(id)sender{
//    if(self.buildItemIndex > 0){
//        self.buildItemIndex = self.buildItemIndex -1;
//    }
//    [self updateIndex];
//    CGRect scrollTo = self.scroller.bounds;
//    
//    scrollTo.origin.x = scrollTo.size.width * self.buildItemIndex;
//    scrollTo.origin.y = 0.0f;
//    
//    
//    [self.scroller scrollRectToVisible:scrollTo animated:YES];
//    [self loadVisiblePages];
//}
//
//- (IBAction)goRight:(id)sender{
//    if(self.buildItemIndex < self.currentBuildItems.count - 1){
//        self.buildItemIndex = self.buildItemIndex +1;
//    }
//    [self updateIndex];
//    CGRect scrollTo = self.scroller.bounds;
//    
//    scrollTo.origin.x = scrollTo.size.width * self.buildItemIndex;
//    scrollTo.origin.y = 0.0f;
//    
//    
//    [self.scroller scrollRectToVisible:scrollTo animated:YES];
//    [self loadVisiblePages];
//}

#pragma mark - ItemEditor protocol methods


- (void) updateBuildItem:(BuildItem *)updatedItem{
    if(!self.isNewItem){
        
        
        NSLog(@"buildItemIndex - %d", self.buildItemIndex);
        BuildItem *itemToRemove = [self.currentBuildItems objectAtIndex:self.buildItemIndex];
        
        if(![updatedItem isEqual:itemToRemove]){
            
            updatedItem.build = self.currentBuild;
            [self.currentBuild removeBuildItemsObject:itemToRemove];
            [self.context deleteObject:itemToRemove];// need to delete from the context since there is no inverse relationship or cascade rule
            [self.currentBuild addBuildItemsObject:updatedItem];
            [self.currentBuildItems replaceObjectAtIndex:self.buildItemIndex withObject:updatedItem];
        }
        
        
    }else{
        self.isNewItem = NO;
        self.buildItemIndex = self.tempNewIndex;
        [self updateIndex];
        updatedItem.build = self.currentBuild;
        [self.currentBuild addBuildItemsObject:updatedItem];
        [self.currentBuildItems insertObject:updatedItem atIndex:self.buildItemIndex];
    }
    
    
    [self updateBuildItemIDs];
    
    
    NSError *error;
    if(![self.context save:&error])
        NSLog(@"The new E-R-R-O-R is %@", [error localizedFailureReason]);
    
    self.didMakeChanges = YES; 
    
}

- (void) updateBuildItemIDs{
    for(int i=0; i<self.currentBuildItems.count; i++){
        BuildItem *item = [self.currentBuildItems objectAtIndex:i];
        item.screenID = [NSNumber numberWithInt:i];
    }
    
}

- (void) deleteBuildItem:(BuildItem *)buildToDelete{
    // get the current build id for this object 
    // get the BuildItem by screenID and then delete it. This will only be called from the 
    
    [self.currentBuildItems removeObjectAtIndex:self.buildItemIndex];
    [self.currentBuild removeBuildItemsObject:buildToDelete];
    [self.context deleteObject:buildToDelete];
    [self updateBuildItemIDs];
    NSError *error;
    if(![self.context save:&error])
        NSLog(@"%@", [error localizedFailureReason]);
    
    self.didMakeChanges = YES; 

    
}

- (BuildItem*) loadBuildItem{// check to see if it's not the end build, if not, it has already been built and we return that object. If it's the last one, we generate a new object and return it
    NSLog(@"BUILDITEMINDEX -- %d",self.buildItemIndex);
    
    if(!self.isNewItem){// if it's not a new item, then it's been created before
        BuildItem* bi = [self.currentBuildItems objectAtIndex:self.buildItemIndex];// get the type so we can compare
        if(![bi.type isEqualToString:self.currentBuildItemType]){// if the types are not the same, then it means the type has been changed, so return a new object for the template
          // get the new one
            BuildItem *updatedItem = [self buildItemFromType:self.currentBuildItemType];
            updatedItem.build = self.currentBuild;// associate it with the build
            [self.currentBuild addBuildItemsObject:updatedItem];// add it to the build
            [self.currentBuildItems replaceObjectAtIndex:self.buildItemIndex withObject:updatedItem];// replace the old one with the new one
            [self.currentBuild removeBuildItemsObject:bi];// remove the old one from the build
            [self.context deleteObject:bi];// remove the old one from the context
            NSError *error;
            if(![self.context save:&error]){
                NSLog(@"%@", [error localizedFailureReason]);
                return nil;
            }else{
                return updatedItem;
            }           
        }else{// if the items are the same, then return the same object, user can edit it
            return [self.currentBuildItems objectAtIndex:self.buildItemIndex];
        }
        
    }else{
        return [self buildItemFromType:self.currentBuildItemType];// it's a new object, return a new item 
    }
}

- (void) setCurrentItemTypeString:(NSString *)itemType{// called from the editors
    self.currentBuildItemType = [self templateTypeToItemType:itemType];
}

- (BOOL) buildItemIsNew{
    
    return self.isNewItem; 
}
// if it's a new item, it was created just for this editor and now it needs to be deleted
- (void) userDidCancelFromEditor:(BuildItem *)newItemToRemove{
    if(self.isNewItem){
        self.isNewItem = NO;
        
        [self.context deleteObject:newItemToRemove];
        NSError *error;
        if(![self.context save:&error])
            NSLog(@"%@", [error localizedFailureReason]);
    }
    
}

#pragma mark - templateTypeToBuildItemType  and buildItemFromType

- (NSString*) templateTypeToItemType:(NSString *)templateType{
    
    if([templateType isEqualToString: @"Text And Image"]){
        return @"TextAndImageMO";
    }else if([templateType isEqualToString: @"Text And Video"]){
        return @"TextAndVideoMO";
    }else if([templateType isEqualToString: @"Video Only"]){
        return @"VideoOnlyMO";
    }else if([templateType isEqualToString: @"Text Only"]){
            return @"TextOnlyMO";
    }else{// default to text and image
        return @"UNKNOWN";
    }
}

- (NSString*) buildTypeToEditorType:(NSString *)buildType{
    if([buildType isEqualToString: @"TextAndImageMO"]){
        return @"Text And Image";
    }else if([buildType isEqualToString: @"TextAndVideoMO"]){
        return @"Text And Video";
    }else if([buildType isEqualToString: @"VideoOnlyMO"]){
        return @"Video Only";
    }else if([buildType isEqualToString: @"TextOnlyMO"]){
        return @"Text Only";
    }else{// default to text and image
        return @"UNKNOWN";
    }

}

- (BuildItem*) buildItemFromType:(NSString *)itemType{// inserts the object but doesn't save it until updateBuildItem is called
    if([self.currentBuildItemType isEqualToString:@"TextAndImageMO"]){
        TextAndImageMO *t = (TextAndImageMO*)
        [NSEntityDescription insertNewObjectForEntityForName:@"TextAndImageMO" inManagedObjectContext:self.context];
        t.screenTitle = @"give us some title";
        t.screenText = @"Some new Ben text";
        t.creationDate = [NSDate date];
        t.type = @"TextAndImageMO";
        //t.screenID = [NSNumber numberWithInt:self.buildItemIndex];
        return t;
    }else if([self.currentBuildItemType isEqualToString:@"TextAndVideoMO"]){
        TextAndVideoMO *t = (TextAndVideoMO*)
        [NSEntityDescription insertNewObjectForEntityForName:@"TextAndVideoMO" inManagedObjectContext:self.context];
        t.screenTitle = @"give us some title";
        t.screenText = @"Some new Ben text";
        t.creationDate = [NSDate date];
        t.type = @"TextAndVideoMO";
        //t.screenID = [NSNumber numberWithInt:self.buildItemIndex];
        return t;
    }else if([self.currentBuildItemType isEqualToString:@"VideoOnlyMO"]){
        VideoOnlyMO *t = (VideoOnlyMO*)
        [NSEntityDescription insertNewObjectForEntityForName:@"VideoOnlyMO" inManagedObjectContext:self.context];
        t.screenTitle = @"give us some title";
        t.creationDate = [NSDate date];
        t.type = @"VideoOnlyMO";
        //t.screenID = [NSNumber numberWithInt:self.buildItemIndex];
        return t;
    }else if([self.currentBuildItemType isEqualToString:@"TextOnlyMO"]){
        TextOnlyMO *t = (TextOnlyMO*)
        [NSEntityDescription insertNewObjectForEntityForName:@"TextOnlyMO" inManagedObjectContext:self.context];
        t.screenTitle = @"give us some title";
        t.creationDate = [NSDate date];
        t.type = @"TextOnlyMO";
        //t.screenID = [NSNumber numberWithInt:self.buildItemIndex];
        return t;
    }else{
        TextAndImageMO *t = (TextAndImageMO*)
        [NSEntityDescription insertNewObjectForEntityForName:@"TextAndImageMO" inManagedObjectContext:self.context];
        t.screenTitle = @"give us some title";
        t.screenText = @"Some new Ben text";
        t.creationDate = [NSDate date];
        t.type = @"TextAndImageMO";
        //t.screenID = [NSNumber numberWithInt:self.buildItemIndex];
        return t;
    }

}



#pragma mark - TemplatePickerDelegate methods

- (void) didChooseTemplate:(NSString *)templateType{
    
    // this is done within a block and it it waits until the animation completes to show the new editor
    [self dismissViewControllerAnimated:NO completion:^{
        self.currentBuildItemType = [self templateTypeToItemType:templateType];
        ItemEditor *templateChosen = [self.tempLoader loadEditor:templateType withDelegate:self];
        [self.navigationController pushViewController:templateChosen animated:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];

    }];
}

- (void) userDidCancel{
    self.isNewItem = NO;// set isNewItem to no if it's been cancelled
    [self dismissModalViewControllerAnimated:YES];
}
    
#pragma mark - UIAlertView delegate methods

#pragma mark - Publish methods

-(IBAction)publishBuild:(id)sender{
    UIAlertView *alertMsg = [[UIAlertView alloc] initWithTitle:@"Publish" message:@"Tap Yes to publish, tap No to continue editing. You will not be able to edit this item after you publish." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
   
    
    [alertMsg show];
}

// if the user chooses to proceed, it should bring them to the home screen
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex !=0){// if this is not the no button, then allow it to publish
        
    
        NSDictionary *holder = [NSDictionary dictionaryWithObjectsAndKeys:[self.currentBuild buildID],@"buildID",@"message to Ben",@"newMsg"            , nil];
        NSString *tester = [holder valueForKey:@"buildID"];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidUpload" object:nil userInfo:holder];
//        UploadViewer *uv = [[UploadViewer alloc] initWithNibName:@"UploadViewer" bundle:[NSBundle mainBundle]];
//        //uv.delegate = self.delegate;
//        uv.build = self.currentBuild;
//        uv.context = self.context;
        [self dismissModalViewControllerAnimated:YES];// dismiss the AlertView
        // add the uploadviewer to the navigation controller
        //[self.navigationController pushViewController:uv animated:YES];
    }
    
    
}

- (void) alertViewCancel:(UIAlertView *)alertView{// dismiss the AlertView
    [self dismissModalViewControllerAnimated:YES];
}





@end
