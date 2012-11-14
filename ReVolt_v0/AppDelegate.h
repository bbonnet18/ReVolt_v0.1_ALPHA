//
//  AppDelegate.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionHandler.h"
#import "Reachability.h"
#import "TextOnlyMO.h"
#import "TextAndImageMO.h"
#import "VideoOnlyMO.h"
#import "TextAndVideoMO.h"
#import "Build.h"
#import "BuildItem.h"
#import "Group.h"
#import "Uploader.h"


@protocol  BuildEditor
@required


- (NSFetchedResultsController *) results;// the fetched results controller set and used by the whole application
- (NSNumber*) getCurrentBuildID;
- (void) setCurrentBuildID:(NSNumber*)newID;
- (NSNumber*) getCurrentItemID;
- (void) setCurrentItemID:(NSNumber*)newID;
- (NSNumber*) getPreviousBuildID;
- (NSArray*)getBuildItemsForBuildID;//Gets the build items for the BuildID provided
- (Build*)getCurrentBuild;// returns the current build object

@optional
-(BOOL)networkIsReachable;// tests the isReachable variable and returns, this is handy for network operations
@end


// NavDelegate was declared to allow the child controller of the navController to call methods on this AppDelegate 
@interface AppDelegate : UIResponder <UIApplicationDelegate,ConnectionResponse, NSFetchedResultsControllerDelegate, BuildEditor, UploadProtocol>
{
    
    UINavigationController *navController;
    Build *currentBuild;

    NSMutableArray *uploadObjects; //
    NSURLConnection *_mainConnection;// the connection object
    ConnectionHandler *_connHandler;
    BOOL _isReachable;
    Uploader *_uploader;// this uploader will be used to upload content from builds
    NSNumber *_currentBuildID;
    NSNumber *_currentItemID;
    NSArray *buildItemTypes;// these are the types of builds available, i.e. the types of buildItems
    BOOL _isNewItem;
    NSFetchedResultsController *_fetched;// to get the fetched results
    
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;



@property (strong, nonatomic) NSOperationQueue *uploadQueue;// the upload queue will be responsible for all upload operations and we will check the status of this to determine whether all build items have uploaded for a specific build or if any uploads are going on at the moment

@property (strong, nonatomic) NSMutableArray *uploadObjects;// this would be a holder for the media items that need to be uploaded to the server, i.e text, video, audio, images
@property (strong, nonatomic) NSFetchedResultsController *fetched;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;

@property (strong,nonatomic) NSURLConnection *mainConnection;
@property (strong, nonatomic) ConnectionHandler *connHandler;
@property (nonatomic, assign) BOOL isReachable;// this will be toggled on and off based on the reachability
@property (strong, nonatomic) Build *currentBuild;
@property (strong, nonatomic) Uploader *uploader;// used to upload all the media in the build

- (void) addItemsToUploadObjects:(NSMutableArray *)mediaItems;

- (NSArray*) getUploadObjectsAtIndex:(NSUInteger)uploadIndex;

-(void)reachabilityChanged:(NSNotification*)note;




@end
