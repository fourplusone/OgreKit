/*
 * Name: OgreKit.h
 * Project: OgreKit
 *
 * Creation Date: Sep 7 2003
 * Author: Isao Sonobe <sonoisa@gmail.com>
 * Copyright: Copyright (c) 2003-2018 Isao Sonobe, All rights reserved.
 * License: OgreKit License
 *
 * Encoding: UTF8
 * Tabsize: 4
 */

#import <Foundation/Foundation.h>

#ifndef NOT_RUBY
#	define NOT_RUBY
#endif
#ifndef HAVE_CONFIG_H
#	define HAVE_CONFIG_H
#endif
#import <onigmo.h>

/* Regular Expressions */
#import "OGRegularExpression.h"
#import "OGRegularExpressionEnumerator.h"
#import "OGRegularExpressionMatch.h"
#import "OGRegularExpressionCapture.h"
#import "OGRegularExpressionFormatter.h"
#import "OGReplaceExpression.h"
#import "NSString_OgreKitAdditions.h"
#import "OGString.h"
#import "OGMutableString.h"
