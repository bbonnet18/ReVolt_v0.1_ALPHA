//
//  HomeView.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeView.h"
#import "Reachability.h"
#import "ImageUploadOperation.h"
#import "VideoUploadOperation.h"
#import "AppDelegate.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //this gets a reference to a background thread
//#define revoltURL [NSURL URLWithString:@"http://www.benbonnet.com/revolt/glossary1.json"] //2
#define revoltURL [NSURL URLWithString:@"http://api.kivaws.org/v1/loans/search.json?status=fundraising"]

@implementation HomeView
@synthesize videoBtn;

@synthesize buildBtnOutlet, networkIndicator, networkAvailable, lbl, uploadBtnOutlet, mediaQueue, cameraBtn, buildVCBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// CUSTOM FUNCTIONS

#pragma mark -

#pragma mark Tests

// Run basic reachability tests
//- (void) runTests
//{
//    UIDevice *device = [UIDevice currentDevice];
//    [self log:@"\n\n"];
//    [self log:@"Current host: %@", [device hostname]];
//    [self log:@"IPAddress: %@", [device localIPAddress]];
//    [self log:@"Local: %@", [device localWiFiIPAddress]];
//    [self log:@"All: %@", [device localWiFiIPAddresses]];
//    
//    [self log:@"Network available?: %@", [device networkAvailable] ? @"Yes" : @"No"];
//    [self log:@"Active WLAN?: %@", [device activeWLAN] ? @"Yes" : @"No"];
//    [self log:@"Active WWAN?: %@", [device activeWWAN] ? @"Yes" : @"No"];
//    [self log:@"Active hotspot?: %@", [device activePersonalHotspot] ? @"Yes" : @"No"];
//    if (![device activeWWAN]) return;
//    [self log:@"Contacting whatismyip.com"];
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//    [[[NSOperationQueue alloc] init] addOperationWithBlock:
//     ^{
//         NSString *results = [device whatismyipdotcom];
//         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//             [self log:@"IP Addy: %@", results];
//             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//         }];         
//     }];
//}
//
//- (void) checkAddresses
//{
//    UIDevice *device = [UIDevice currentDevice];
//    if (![device networkAvailable]) return;
//    [self log:@"Checking IP Addresses"];
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//    [[[NSOperationQueue alloc] init] addOperationWithBlock:
//     ^{
//         NSString *google = [device getIPAddressForHost:@"www.google.com"];
//         NSString *amazon = [device getIPAddressForHost:@"www.amazon.com"];
//         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//             [self log:@"Google: %@", google];
//             [self log:@"Amazon: %@", amazon];
//             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//         }];         
//     }];
//}
//
//#define CHECK(SITE) [self log:@"• %@ : %@", SITE, [device hostAvailable:SITE] ? @"available" : @"not available"];
//
//- (void) checkSites
//{
//    UIDevice *device = [UIDevice currentDevice];
//    NSDate *date = [NSDate date];
//    CHECK(@"www.google.com");
//    CHECK(@"www.ericasadun.com");
//    CHECK(@"www.notverylikely.com");
//    CHECK(@"192.168.0.108");
//    CHECK(@"pearson.com");
//    CHECK(@"www.pearson.com");
//    [self log:@"Elapsed time: %0.1f", [[NSDate date] timeIntervalSinceDate:date]];
//}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    log = [NSMutableString string];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"http://localhost/"];
    
    reach.reachableBlock = ^(Reachability * reachability)// this calls the dispatch_async 
    // so it can update the UI, otherwise the block is not called on the main thread, so 
    // always have to call the main queue to access the GUI
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            networkIndicator.image = [UIImage imageNamed:@"WWAN5.png"];
            networkAvailable = YES;
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            networkIndicator.image = [UIImage imageNamed:@"stop-32.png"]; 
            networkAvailable = NO;
        });
    };
    
    
    
    [reach startNotifier];
    
    

    
    //[self checkSites];
    //[self checkAddresses];
    
    //self.navigationItem.rightBarButtonItem = BARBUTTON(@"Test", @selector(runTests));    
    //[[UIDevice currentDevice] scheduleReachabilityWatcher:self];
    // Do any additional setup after loading the view from its nib.
}


-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        networkIndicator.image = [UIImage imageNamed:@"WWAN5.png"];
        networkAvailable = YES;
    }
    else
    {
        networkIndicator.image = [UIImage imageNamed:@"stop-32.png"];
        networkAvailable = NO;
    }
}





- (void)viewDidUnload
{
    
    [self setBuildBtnOutlet:nil];
    [self setCameraBtn:nil];
    [self setVideoBtn:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
// downloads the data from the site, need to add progress indicator


// Custom Methods

-(void)launchLearn:(id)sender{
    
    //AppDelegate *ad =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //[ad launchLearn];
    
}


-(void)launchBuildVC:(id)sender{
    AppDelegate *ad =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [ad launchBuildVC];
}


-(IBAction)checkBuild:(id)sender{
   
    
//    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Hello World!"
//                                                      message:@"This is your first UIAlertview message."
//                                                     delegate:nil
//                                            cancelButtonTitle:@"OK"
//                                            otherButtonTitles:nil];
//    
//    [message show];
    [self loadData];
}

-(void) loadData{
    if(networkAvailable){
        dispatch_async(kBgQueue, ^(void){
            
            NSData* data = [NSData dataWithContentsOfURL:revoltURL];
            [self performSelectorOnMainThread:@selector(downloadedData:) 
                                   withObject:data waitUntilDone:YES];
        });
    }else{
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Network Unavailable" message:@"Network Unavailble" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [message show];
    }
    
}

-(void) downloadedData:(NSData*) data{
    NSError* error;
    // get the json from the object, 
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSArray* latestLoans = [json objectForKey:@"loans"]; //2
    
    NSLog(@"loans: %@", latestLoans); //3
    
    NSDictionary* loan = [latestLoans objectAtIndex:0];
    
    // 2) Get the funded amount and loan amount
    NSNumber* fundedAmount = [loan objectForKey:@"funded_amount"];
    NSNumber* loanAmount = [loan objectForKey:@"loan_amount"];
    float outstandingAmount = [loanAmount floatValue] - 
    [fundedAmount floatValue];
    
    // 3) Set the label appropriately
    lbl.text = [NSString stringWithFormat:@"Latest loan: %@ from %@ needs another $%.2f to pursue their entrepreneural dream",
                         [loan objectForKey:@"name"],
                         [(NSDictionary*)[loan objectForKey:@"location"] 
                          objectForKey:@"country"],
                         outstandingAmount];
}

- (IBAction)testAction:(id)sender {
    [self createWithColor:[UIColor greenColor]];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/out.jpg"];
//    ImageUploadOperation *op = [ImageUploadOperation operationWithDelegate:self andPath:path];
//    
    ImageUploadOperation *op1 = [ImageUploadOperation operationWithDelegate:self andPath:path andItemID:path];
    
    NSString  *videoFilepath = [[NSBundle mainBundle] pathForResource:@"IMG_1881"  ofType:@"mov"];
    
    VideoUploadOperation *op2 = [VideoUploadOperation operationWithDelegate:self andPath:videoFilepath andItemID:videoFilepath];


    mediaQueue = [[NSOperationQueue alloc] init];
    [mediaQueue waitUntilAllOperationsAreFinished];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [mediaQueue addOperation:op1];
    [mediaQueue addOperation:op2];
    


    
}

- (IBAction)testMovie:(id)sender {
//    NSString  *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/movie2.mov"]];
    
    NSString  *videoFilepath = [[NSBundle mainBundle] pathForResource:@"movie2"  ofType:@"mov"];
    
    VideoUploadOperation *op = [VideoUploadOperation operationWithDelegate:self andPath:videoFilepath andItemID:videoFilepath];
    
    
    mediaQueue  = [[NSOperationQueue alloc] init];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [mediaQueue addOperation:op];
    
    NSLog(@"Filepath is: %@", videoFilepath);    
}

- (void) createWithColor: (UIColor *) aColor// this is a way to make snapshots of the screen
{
    CGRect rect = (CGRect){.size = CGSizeMake(320.0f, 320.0f)};
    UIGraphicsBeginImageContext(rect.size);
    [[UIColor whiteColor] set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    [aColor set];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 40.0f, 40.0f) cornerRadius:32.0f] fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/out.jpg"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [UIImageJPEGRepresentation(image, 0.75f) writeToURL:url atomically:YES];
}


- (void) doneUploading:(NSString*)message{
    NSString *test = @"test";
    mediaQueue = nil;
    lbl.text = message;
    NSLog(@"test is %@",test);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)launchCamera:(id)sender {
    
   AppDelegate *ad =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [ad launchCamera];
}
@end
