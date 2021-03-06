/*
 * Name: OGRegularExpressionCapturePrivate.m
 * Project: OgreKit
 *
 * Creation Date: Jun 24 2004
 * Author: Isao Sonobe <sonoisa@gmail.com>
 * Copyright: Copyright (c) 2003-2018 Isao Sonobe, All rights reserved.
 * License: OgreKit License
 *
 * Encoding: UTF8
 * Tabsize: 4
 */


#import "OGRegularExpressionCapturePrivate.h"


@implementation OGRegularExpressionCapture (Private)

- (id)initWithTreeNode:(OnigCaptureTreeNode*)captureNode 
    index:(NSUInteger)index
    level:(NSUInteger)level
    parentNode:(OGRegularExpressionCapture*)parentNode 
    match:(OGRegularExpressionMatch*)match
{
    self = [super init];
    if (self != nil) {
        _captureNode = captureNode;
        _index = index;
        _level = level;
        _parent = parentNode;
        _match = match;
    }
    return self;
}


- (OnigCaptureTreeNode*)_captureNode
{
    return _captureNode;
}

@end
