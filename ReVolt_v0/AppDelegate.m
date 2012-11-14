//
//  AppDelegate.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


/*
 CREATE THE UPLOADVIEWER AND PLACE A TIMER ON IT. THAT TIMER CAN CHECK TO SEE IF THE UPLOAD IS 
 DONE ON THE MAIN APPLICATION. THE APPDELEGATE WILL HOLD REFERENCES TO THE DOWNLOADING OBJECTS, SINCE IT ALREADY HOLDS EVERYTHING ELSE RELATED TO THE BUILDS. You should be able to track each one of the uploads and then update the total uploads as necessary. After each upload, you can update that item as 'uploaded' and then start the next upload. The network activity indicator would remain active until all items are uploaded. At that point, the build itself should show up as 'uploaded' and should be marked accordingly.
 
    If the user wants to check the progress of the upload on a build, they can do so by going to the tableview and selecting that build. If that build is already uploaded fully, the build will show up with a green checkmark and selecting that build will acutally go to that build. If the build is not currently uploaded, selecting it will bring them to the upload progress screen where the user can see the progress of the upload. A timer on the upload progress screen will continually query the 'currentUploads' array on the application delegate and report progress based on how many of the items in the currentUploads array are marked as uploaded
 */

#import "AppDelegate.h"
#import "UIDevice-Reachability.h"
#import "UploadsViewController.h"
#import "ConnectionHandler.h"
#import "BuildStartVC.h"



#define DATA(STRING)	[STRING dataUsingEncoding:NSUTF8StringEncoding]

@implementation AppDelegate

@synthesize window = _window;
@synthesize mainConnection = _mainConnection;
@synthesize navController, currentBuild, uploadQueue, uploadObjects;
@synthesize connHandler = _connHandler;
@synthesize isReachable = _isReachable;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize uploader = _uploader;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize fetched = _fetched;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // set up the buildItemTypes array;
    self->buildItemTypes = [NSArray arrayWithObjects:@"TextAndImageMO",@"TextAndVideoMO",@"TextOnlyMO",@"VideoOnlyMO", nil];
    
    
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Build" inManagedObjectContext:self.managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name LIKE[c] 'Build Two')"];
//    [request setPredicate:predicate];
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
//    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//    
//    NSError *error = nil;
//    
//    
//    NSArray *thisarray = [self.managedObjectContext executeFetchRequest:request error:&error];
//    for(Build *build in thisarray){
//        
//        [self.managedObjectContext deleteObject:build];
//        
//    }
//    NSError *Terror = nil;
//    if(![self.managedObjectContext save:&Terror]){
//        NSLog(@"error saving the context after deleting all objects");
//    }
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"userID"] == nil){
        
            
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:65] forKey:@"userID"];
    }
    // set up the buildID so it can be incremented as needed to create a buildID for each build
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"buildID"] == nil){
        
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:@"buildID"];
    }
    
   // if we were uploading something, then we need to start that back up
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"]  && [[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
        NSInteger uploadingBuildID = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastUploadingBuildID"];
        
        
        // this should be encapsulated in another method, so it can be called from here and from the published function
        NSNumber *idForBuild = [NSNumber numberWithInt:uploadingBuildID];
        Build * newBuild = [self getBuild:idForBuild];
        
        [self startUploadProcessWithBuild:newBuild withBuildID:idForBuild];
        
    }
    
    
   // [self addNew];
   // [self getBuildMOs];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(published:) name:@"UserDidUpload" object:nil];
    Reachability * reach = [Reachability reachabilityWithHostname:@"http://www.google.com/"];
    
    reach.reachableBlock = ^(Reachability * reachability)// this calls the dispatch_async 
    // so it can update the UI, otherwise the block is not called on the main thread, so 
    // always have to call the main queue to access the GUI
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isReachable = YES;
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isReachable = NO;
        });
    };
    
    [reach startNotifier];

    
    BuildStartVC *bs = [[BuildStartVC alloc] initWithNibName:@"BuildStartVC" bundle:[NSBundle mainBundle]];
    //bs.delegate = self;
    bs.context = [self moc];// set the moc so it can be passed around
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:bs];
    self.navController = nav;
    
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.navController;// setting the root view controller is the right way, instead of making the homeview's view a subview of the window - maybe because it then releases the view controller and simply holds onto the subview (in this case that's a button)

    [self.window makeKeyAndVisible];
    
    self.uploadQueue =  [[NSOperationQueue alloc] init];// set the background queue
    
    
    return YES;
}

- (void) startUploadProcessWithBuild: (Build*) newBuild withBuildID:(NSNumber*) idForBuild{
    
    if(newBuild != nil){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BuildItem" inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"build == %@",newBuild];
        [request setPredicate:predicate];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"screenID" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        NSError *error = nil;
        
        // each of these is actually a buildItem rather than a media item, but the media items are part of each BuildItem so they can be brought in
        NSArray *mediaItems = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:request error:&error]];// go get all the mediaItems
        
        
        NSMutableArray *mediaItemsToUpload = [[NSMutableArray alloc] initWithCapacity:[mediaItems count]];// inititate the mediaItemsToUpload array that will be passed to the uploader
       if(error == nil){
            
            // create array to hold the objects to pass to the uploader
            
            for (BuildItem * b in mediaItems) {
                NSString * mediaType = @"";// set the media type and path
                NSString * mediaPath = @"";
                if([b.type isEqualToString:@"TextAndImageMO"]){
                    mediaType = @"image";
                    TextAndImageMO *obj = (TextAndImageMO*)b;
                    mediaPath = obj.imagePath;
                }else{
                    mediaType = @"video";
                    TextAndVideoMO *obj = (TextAndVideoMO*)b;
                    mediaPath = obj.videoPath;
                }
                
                NSMutableDictionary *mediaObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:mediaType,@"type",mediaPath,@"path",@"NO",@"status", nil];
                [mediaItemsToUpload addObject:mediaObject];// add it to the array to be passed
                
                
                // create a dictionary of objects that have types and media paths and send those to the uploader
            }
            
            // get the JSON data from the build
            NSData * jsonData = [self generateJSONFromBuild:newBuild withItems:mediaItems];
            // create an instance of uploader and assign it to the uploader instance variable so it can be acted on and tracked
            self.uploader = [[Uploader alloc] initWithBuildItems:mediaItemsToUpload andJSONData:jsonData buildID:idForBuild];
           self.uploader.delegate = self;// should probably set this before calling the method above, or set it with it. 
    }
      }

    
}

- (void) published:(NSNotification*) buildID{
    
    
    
    NSDictionary *myDictionary = [buildID userInfo];
    NSNumber * idForBuild = [myDictionary valueForKey:@"buildID"];
    
    // save this a reference to the last uploaded buildID so it can be re-launched the next time if it quits
    [[NSUserDefaults standardUserDefaults] setInteger:[idForBuild integerValue] forKey:@"lastUploadingBuildID"];
    
    self.uploader = nil;
    Build * newBuild = [self getBuild:idForBuild];
    
    [self startUploadProcessWithBuild:newBuild withBuildID:idForBuild];
//    if(newBuild != nil){
//        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BuildItem" inManagedObjectContext:self.managedObjectContext];
//        NSFetchRequest *request = [[NSFetchRequest alloc] init];
//        [request setEntity:entityDescription];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"build == %@",newBuild];
//        [request setPredicate:predicate];
//        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"screenID" ascending:YES];
//        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//        
//        NSError *error = nil;
//        
//        // each of these is actually a buildItem rather than a media item, but the media items are part of each BuildItem so they can be brought in
//        NSArray *mediaItems = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:request error:&error]];// go get all the mediaItems
//        
//        
//        NSMutableArray *mediaItemsToUpload = [[NSMutableArray alloc] initWithCapacity:[mediaItems count]];// inititate the mediaItemsToUpload array that will be passed to the uploader
//        if(error == nil){
//            
//            // create array to hold the objects to pass to the uploader
//            
//            for (BuildItem * b in mediaItems) {
//                NSString * mediaType = @"";// set the media type and path
//                NSString * mediaPath = @"";
//                if([b.type isEqualToString:@"TextAndImageMO"]){
//                    mediaType = @"image";
//                    TextAndImageMO *obj = (TextAndImageMO*)b;
//                    mediaPath = obj.imagePath;
//                }else{
//                    mediaType = @"video";
//                    TextAndVideoMO *obj = (TextAndVideoMO*)b;
//                    mediaPath = obj.videoPath;
//                }
//                
//                NSMutableDictionary *mediaObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:mediaType,@"type",mediaPath,@"path",@"NO",@"status", nil];
//                [mediaItemsToUpload addObject:mediaObject];// add it to the array to be passed
//                
//                
//                // create a dictionary of objects that have types and media paths and send those to the uploader
//            }
//            
//            // get the JSON data from the build
//            NSData * jsonData = [self generateJSONFromBuild:newBuild withItems:mediaItems];
//            // create an instance of uploader and assign it to the uploader instance variable so it can be acted on and tracked
//            self.uploader = [[Uploader alloc] initWithBuildItems:mediaItemsToUpload andJSONData:jsonData buildID:idForBuild];
//        }
//
//    }
    
    // from here you need to extract all the data necessary and instantiate the uploader object, providing it the array and the JSON data object, you also need to enact the delegate method and be ready to stop/resume it at any point
}

-(Build*) getBuild:(NSNumber*) buildID{
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Build" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"buildID == %@",buildID];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    // each of these is actually a buildItem rather than a media item, but the media items are part of each BuildItem so they can be brought in
    
    NSArray *builds = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:request error:&error]];
    
    if(error == nil){
        
        Build * b = [builds objectAtIndex:0];// get the build for this id
        return b; 
    }else{
        return nil;
    }
}
// creates a dictionary and adds an array of items to the dictionary to create the JSON data
- (NSData*) generateJSONFromBuild:(Build*)b withItems:(NSArray*)buildItems{
    // get the date
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    NSString *creationDateString = [formatter stringFromDate:b.creationDate];
    // this builds a hierarchy with the main node being the build and the items string data making up the rest
    NSDictionary *metaDataDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:creationDateString, @"buildCreationDate",nil];
    
    // initialize the dictionary that we'll use to add the items to
    NSMutableDictionary *buildDictionary = [[NSMutableDictionary alloc] initWithDictionary:metaDataDictionary];
    // create an array to store the items
    NSMutableArray * itemArray = [[NSMutableArray alloc] init];
    // roll through the items and extract what's needed and add each to the array
    for (BuildItem * b in buildItems) {
        NSString * screenTitle = b.screenTitle;
        NSString * screenID = [b.screenID stringValue];
        NSString * itemType = b.type;
        NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:screenTitle,@"screenTitle",screenID,@"screenID",itemType,@"itemType", nil];
        
        NSString * screenText = nil;
        if([itemType isEqualToString: @"TextAndImageMO"]){
            TextAndImageMO *t = (TextAndImageMO*)b;
            screenText = t.screenText;
        }else if([itemType isEqualToString: @"TextAndVideoMO"]){
            TextAndVideoMO * t = (TextAndVideoMO*)b;
            screenText = t.screenText;
        }else if([itemType isEqualToString: @"TextOnlyMO"]){
            TextOnlyMO *t = (TextOnlyMO*)b;
            screenText = t.screenText;
        }
        
        if(screenText != nil){
            [itemDictionary setValue:screenText forKey:@"screenText"];
        }
        [itemArray addObject:itemDictionary];
        
    }
    // add the item array to the buildDictionary
    [buildDictionary setObject:itemArray forKey:@"buildItems"];
    NSError *error;
    // create json data
    NSData *buildData = [NSJSONSerialization dataWithJSONObject:buildDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *stringData = [[NSString alloc] initWithData:buildData encoding:NSUTF8StringEncoding];
    
    if(!error){
        NSLog(@"jsonData: %@",stringData );
        return buildData;
    }else {
        return nil;
    }
    
}

#pragma mark - Application events

#pragma mark - Application lifecycle methods

- (void)applicationWillResignActive:(UIApplication *)application
{
     // if an upload is currently active, pause the upload
    
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
        if(self.uploader){
            [self.uploader stopUpload];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
        if(self.uploader){
            [self.uploader stopUpload];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
     // same as for active status
    
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
        if(self.uploader){
            [self.uploader resumeUpload];
        }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // if there is an upload to complete, make sure you can get it and then resume the upload

    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
        if(self.uploader){
            [self.uploader resumeUpload];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // stop the upload process and clean up. Make sure to store all relevant user settings
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUploading"] == YES){
        [self.uploader stopUpload];// stop the upload process
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}



-(void) reachabilityChanged:(NSNotification *)note{
    
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        self.isReachable = YES;
    }
    else
    {
        self.isReachable = NO;
    }

}

#pragma mark - uploader protocol

-(void) uploadDidCompleWithBuildID:(NSNumber*)buildID{
    self.uploader = nil;// nilify the uploader, the next upload will take the place of this one.
    
    
}

#pragma mark - build editor protocols

- (NSFetchedResultsController*) results{
    return self.fetched;
}


-(NSNumber*) getCurrentBuildID{
    // if uninitialized, then make it 1
    if(_currentBuildID == nil){
        _currentBuildID = [NSNumber numberWithInt:1];
    }
    NSLog(@"currentBuildID: %d",[_currentBuildID intValue]);
    return _currentBuildID;
}
-(void) setCurrentBuildID:(NSNumber*) newID{
    _currentBuildID = newID;
}

-(NSNumber*) getCurrentItemID{
    if(_currentItemID == nil){
        _currentItemID = [NSNumber numberWithInt:1];
    }
    return _currentItemID;
}
-(void) setCurrentItemID: (NSNumber*) newID{
    _currentItemID = newID;
}

-(NSManagedObjectContext*)moc{
    return self.managedObjectContext;
}

- (NSNumber*) getPreviousBuildID{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Build" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"buildID" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    BOOL success = [frc performFetch:&error];
    
    if(![frc performFetch:&error]){
        NSLog(@"ERROR: %@", error);
    }
    
    NSArray *arr = frc.fetchedObjects;
    NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity:[arr count]];// set up an array to hold all the ids
    for(Build *b in arr){// add all the ids to the ids array
        NSLog(@"id: %@",[b valueForKey:@"buildID"]);
        [ids addObject:[b valueForKey:@"buildID"]];// add the objects
    }
    /* GET THE HIGHEST VALUE */
    
    // if there are builds, return the id of the last one
    NSInteger count = [arr count];
    if(count > 0){
        count = count -1;
        
        Build *lastBuild = [frc.fetchedObjects objectAtIndex:count];
        
        if([lastBuild valueForKey:@"buildID"]){
            NSNumber* lastItemID = [lastBuild valueForKey:@"buildID"];
            return lastItemID;
        }
    }
    return nil;
}

-(NSArray*)getBuildItemsForBuildID{
    
    Build *selectedBuild = [self getCurrentBuild];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"BuildItem" inManagedObjectContext:self.moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"build == %@",selectedBuild];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"screenID" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    
    //NSArray *results = [self.context executeFetchRequest:request error:&error];
    
    NSArray *arrayToReturn = [NSMutableArray arrayWithArray:[self.moc executeFetchRequest:request error:&error]];//[NSMutableArray arrayWithArray:[[self.currentBuild buildItems] allObjects]];
    
    if(!error)
        return arrayToReturn; 
    
    return nil;

}

- (Build*)getCurrentBuild{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Build" inManagedObjectContext:self.moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"buildID == %@",[self getCurrentBuildID]];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    
    NSArray *results = [self.moc executeFetchRequest:request error:&error];
    if(!error)
        return [results objectAtIndex:0];
    
    return nil;

}

-(BOOL)networkIsReachable{
    return self.isReachable;
}

#pragma mark - BuildItemEditor protocol methods

- (void) addBuildItem:(BuildItem *)newBuild{
    
}

- (void) updateBuildItem:(BuildItem *)updatedItem{
    
}

- (void) deleteBuildItem:(BuildItem *)buildToDelete{
    
}





#pragma mark - uploads
- (void) addItemsToUploadObjects:(NSMutableArray *)mediaItems{
    
    [self.uploadObjects addObject:mediaItems];
    
}

- (NSArray*) getUploadObjectsAtIndex:(NSUInteger)uploadIndex{
    return [self.uploadObjects objectAtIndex:uploadIndex];
}





#pragma mark - ConnectionResponse delegate methods

- (void) doneLoading:(NSString *)response{
  
}

#pragma mark - CoreData methods

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}
//overriding the feched property getter to make sure we set it up properly
- (NSFetchedResultsController*) fetched{
    if(_fetched != nil){
        return _fetched;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Build" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"bCACHE"];
    
    
    self.fetched = frc;
    _fetched.delegate = self;
    NSError *error;
    [self.fetched performFetch:&error];
    NSLog(@"IsSuccess: Success");
    return _fetched;
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ReVolt_Data" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ReVolt_Data.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}





//-(void) launchLearn{
//    
//    FirstLearnViewController *mnv = [[FirstLearnViewController alloc] initWithNibName:@"FirstLearnViewController" bundle:[NSBundle mainBundle]];
//    
//    mnv.delegate = self;
//    
//    // create the navController if it's not there, then make it the root view controller  
//    // this appears to be the only or "right" way to do this - having a NavController as a
//    // sub controller to the window, not as a subcontrolller of another UIViewController
//    if(!self.navController){
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mnv];
//        
//        self.navController = nav;
//    }
//    // this transition code creates a transition between the current rootViewController and the rootViewController that we're adding
//    [UIView
//     transitionWithView:self.window 
//     duration:0.5
//     options:UIViewAnimationOptionTransitionCrossDissolve
//     animations:^(void) {
//         [self.window.rootViewController removeFromParentViewController]; 
//         self.window.rootViewController = self.navController;
//         
//    } 
//                                                                           
//     completion:nil];
//    
//   // self.window.rootViewController = self.navController;
//
//}





@end
