//
//  TemplateLoader.m
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TemplateLoader.h"
#import "BuildMainEditScreen.h"
#import "textAndImage.h"
#import "textAndVideo.h"
#import "textOnlyEditor.h"
#import "videoOnly.h"

@implementation TemplateLoader 
@synthesize templateType = _templateType;

- (ItemEditor*) loadEditor:(NSString *)itemType withDelegate:(id<ItemEditor>)delegate{
    self.templateType = itemType;
    
    if([itemType isEqualToString: @"Text And Image"]){
        textAndImage *temp = [[textAndImage alloc] initWithNibName:@"textAndImage" bundle:[NSBundle mainBundle]];
        temp.delegate = delegate;
        return temp;
    }else if([itemType isEqualToString: @"Text And Video"]){
        textAndVideo *temp = [[textAndVideo alloc] initWithNibName:@"textAndVideo" bundle:[NSBundle mainBundle]];
        temp.delegate = delegate;
        return temp;
    }else if([itemType isEqualToString: @"Video Only"]){
        videoOnly *temp = [[videoOnly alloc] initWithNibName:@"videoOnly" bundle:[NSBundle mainBundle]];
        temp.delegate = delegate;
        return temp;
    }else if([itemType isEqualToString: @"Text Only"]){
        textOnlyEditor *temp = [[textOnlyEditor alloc] initWithNibName:@"textOnlyEditor" bundle:[NSBundle mainBundle]];
        temp.delegate = delegate;
        return temp;
    }else{// default to text and image
        textAndImage *temp = [[textAndImage alloc] initWithNibName:@"textAndImage" bundle:[NSBundle mainBundle]];
        temp.delegate = delegate;
        return temp;

    }
    
}

@end
