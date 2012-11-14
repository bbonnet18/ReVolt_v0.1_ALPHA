//
//  TemplateLoader.h
//  ReVolt_v0
//
//  Created by Lauren Bonnet on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "ItemEditor.h"


@interface TemplateLoader : NSObject{
    NSString *_templateType;
}
@property (strong, nonatomic) NSString *templateType;


- (ItemEditor*) loadEditor: (NSString*) itemType withDelegate:(id<ItemEditor>)delegate;

@end
