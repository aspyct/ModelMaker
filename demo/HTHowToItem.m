//
// HTHowToItem.m
// HowTo
//
// Generated by EntityMaker on 18/09/12.
// Copyright (c) 2012 Antoine d'Otreppe. All rights reserved.
//
// EntityMaker, http://github.com/aspyct/EntityMaker
//

#import "HTHowToItem.h"

@implementation HTHowToItem
@synthesize id = _id;
@synthesize title = _title;
@synthesize author = _author;
@synthesize image = _image;
@synthesize description = _description;
@synthesize score = _score;
@synthesize tags = _tags;
@synthesize comments = _comments;

- (id)init
{
    self = [super init];
    
    if (self) {
        _tags = [[NSMutableSet alloc] init];
        _comments = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end
