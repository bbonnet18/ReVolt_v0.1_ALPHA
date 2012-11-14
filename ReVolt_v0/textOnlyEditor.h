//
//  textOnlyEditor.h
//  ReVolt_v0
//
//  Created by Ben Bonnet on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemEditor.h"
#import "TextOnlyMO.h"


@interface textOnlyEditor : ItemEditor
{

    TextOnlyMO *_buildItem;
}

@property (strong, nonatomic) TextOnlyMO *buildItem;
@property (strong, nonatomic) IBOutlet UITextView *screenText;

@end