//
// MPComment.h
// MyProject
//
// Copyright (c) 2012 MyCompany. All rights reserved.
//
// Generated by ModelMaker
// See http://github.com/aspyct/ModelMaker
//

#import <Foundation/Foundation.h>

@interface MPComment : NSObject {
@protected
    NSInteger _commentId;
    NSString * _body;
    NSString * _author;
}

@property (readonly) NSInteger commentId;
@property (readonly) NSString * body;
@property (readonly) NSString * author;

@end
