/*
 * Name: OGAttributedString.h
 * Project: OgreKit
 *
 * Creation Date: Sep 22 2004
 * Author: Isao Sonobe <sonoisa@gmail.com>
 * Copyright: Copyright (c) 2004-2018 Isao Sonobe, All rights reserved.
 * License: OgreKit License
 *
 * Encoding: UTF8
 * Tabsize: 4
 */

#import "OGString.h"

@interface OGAttributedString : NSObject <OGStringProtocol, NSCopying, NSCoding>
{
	NSAttributedString	*_attrString;
}

- (id)initWithString:(NSString*)string;
- (id)initWithAttributedString:(NSAttributedString*)attributedString;
- (id)initWithString:(NSString*)string hasAttributesOfOGString:(NSObject<OGStringProtocol>*)ogString;

+ (id)stringWithString:(NSString*)string;
+ (id)stringWithAttributedString:(NSAttributedString*)attributedString;
+ (id)stringithString:(NSString*)string hasAttributesOfOGString:(NSObject<OGStringProtocol>*)ogString;

- (NSAttributedString*)_attributedString;
- (void)_setAttributedString:(NSAttributedString*)attributedString;

@end
