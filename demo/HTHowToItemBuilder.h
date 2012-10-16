//
// HTHowToItemBuilder.h
// HowTo
//
// Copyright (c) 2012 Antoine d'Otreppe. All rights reserved.
//
// Generated by EntityMaker on 18/09/12.
// See http://github.com/aspyct/EntityMaker
//

#import <Foundation/Foundation.h>
#import "HTHowToItem.h"

@interface HTHowToItemBuilder : NSObject

@property (readonly) HTHowToItem *howToItem;

- (id)init;

- (void)setId:(NSInteger)id;
- (void)setTitle:(NSString *)title;
- (void)setAuthor:(NSString *)author;
- (void)setImage:(NSURL *)image;
- (void)setDescription:(NSString *)description;
- (void)setScore:(NSInteger)score;
- (void)setTags:(NSSet *)tags;
- (void)setComments:(NSArray *)comments;
- (void)setPublication:(NSDate *)publication;

@end