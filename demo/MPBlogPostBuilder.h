//
// MPBlogPostBuilder.h
// MyProject
//
// Copyright (c) 2012 MyCompany. All rights reserved.
//
// Generated by ModelMaker
// See http://github.com/aspyct/ModelMaker
//

#import <Foundation/Foundation.h>
#import "MPBlogPost.h"

@interface MPBlogPostBuilder : NSObject

@property (readonly) MPBlogPost *blogPost;

- (id)init;

- (void)setBlogPostId:(NSInteger)blogPostId;
- (void)setTitle:(NSString *)title;
- (void)setBody:(NSString *)body;
- (void)setPublicationDate:(NSDate *)publicationDate;
- (void)setTags:(NSSet *)tags;
- (void)setComments:(NSArray *)comments;
- (void)setOnline:(NSURL *)online;
- (void)setAuthor:(MPAuthor)author;
- (void)setTest:(NSObject *)test;

@end
