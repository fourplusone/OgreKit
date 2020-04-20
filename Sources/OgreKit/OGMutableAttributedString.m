/*
 * Name: OGMutableAttributedString.h
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

#import <OgreKit/OGMutableAttributedString.h>
#import <TargetConditionals.h>
#if TARGET_OS_OSX
#define APPKIT 1
#define UIKIT 0
#else
#if TARGET_OS_IPHONE
#define APPKIT 0
#define UIKIT 1
#endif
#endif

#if APPKIT
#import <AppKit/AppKit.h>
#endif

#if UIKIT
#import <UIKit/UIKit.h>
#endif


#if UIKIT
static UIFontDescriptorSymbolicTraits NSCondensedFontMask = UIFontDescriptorTraitCondensed;
static UIFontDescriptorSymbolicTraits NSExpandedFontMask = UIFontDescriptorTraitExpanded;
#endif
       

@implementation OGMutableAttributedString
{
    NSString        *_currentFontFamilyName;
    
    float            _currentFontWeight;
    float            _currentFontPointSize;
    NSDictionary    *_currentAttributes;
#if TARGET_OS_OSX
    NSFontTraitMask    _currentFontTraits;
    NSFontManager    *_fontManager;
#endif
    
#if UIKIT
    UIFontDescriptorSymbolicTraits _currentFontTraits;
#endif
}

- (id)init
{
	self = [super init];
	if (self != nil) {
		[self _setAttributedString:[[[NSMutableAttributedString alloc] init] autorelease]];
#if TARGET_OS_OSX
		_fontManager = [NSFontManager sharedFontManager];
#endif
	}
	return self;
}

- (id)initWithAttributedString:(NSAttributedString*)attributedString
{
	if (attributedString == nil) {
		[super release];
		[NSException raise:NSInvalidArgumentException format: @"nil string argument"];
	}
	
	self = [super init];
	if (self != nil) {
		[self _setAttributedString:[[[NSMutableAttributedString alloc] initWithAttributedString:attributedString] autorelease]];
#if TARGET_OS_OSX
		_fontManager = [NSFontManager sharedFontManager];
#endif
	}
	return self;
}

- (id)initWithString:(NSString*)string hasAttributesOfOGString:(NSObject<OGStringProtocol>*)ogString
{
	if (string == nil || ogString == nil) {
		[super release];
		[NSException raise:NSInvalidArgumentException format: @"nil string argument"];
	}
	
	self = [super init];
	if (self != nil) {
		[self _setAttributedString:[[[NSAttributedString alloc] initWithString:string 
			attributes:[[ogString attributedString] attributesAtIndex:0 effectiveRange:NULL]] autorelease]];
#if TARGET_OS_OSX
		_fontManager = [NSFontManager sharedFontManager];
#endif
	}
	return self;
}

- (void)dealloc
{
	[_currentFontFamilyName release];
	[_currentAttributes release];
	[super dealloc];
}

/* OGMutableStringProtocol */
- (void)appendOGString:(NSObject<OGStringProtocol>*)string
{
	[(NSMutableAttributedString*)[self _attributedString] appendAttributedString:[string attributedString]];
}

- (void)appendAttributedString:(NSAttributedString*)string
{
	[(NSMutableAttributedString*)[self _attributedString] appendAttributedString:string];
}

- (void)appendOGStringLeaveImprint:(NSObject<OGStringProtocol>*)string
{
	NSUInteger	length = [string length];
	if (length == 0) {
		return;
	}
	
	NSAttributedString	*appendant = [string attributedString];
	[(NSMutableAttributedString*)[self _attributedString] appendAttributedString:appendant];
	[_currentAttributes autorelease];
	_currentAttributes = [[appendant attributesAtIndex:(length - 1) effectiveRange:NULL] retain];
}

- (void)appendString:(NSString*)string 
{
	if ([string length] == 0) {
		return;
	}
	
	[(NSMutableAttributedString*)[self _attributedString] appendAttributedString:[[[NSAttributedString alloc] initWithString:string attributes:_currentAttributes] autorelease]];
}

- (void)appendString:(NSString*)string hasAttributesOfOGString:(NSObject<OGStringProtocol>*)ogString
{
	if ([string length] == 0) {
		return;
	}
	
	[(NSMutableAttributedString*)[self _attributedString] appendAttributedString:[[[NSAttributedString alloc] initWithString:string attributes:[[ogString attributedString] attributesAtIndex:0 effectiveRange:NULL]] autorelease]];
}

- (void)appendOGString:(NSObject<OGStringProtocol>*)string 
	changeFont:(BOOL)changeFont 
	mergeAttributes:(BOOL)mergeAttributes 
	ofOGString:(NSObject<OGStringProtocol>*)srcString
{
	if ([string length] == 0) {
		return;
	}
	
	NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc] init];
	
	NSAttributedString			*appendant = [string attributedString];
	NSMutableAttributedString	*attrString = (NSMutableAttributedString*)[self _attributedString];
	
	NSMutableAttributedString	*aString = [[[NSMutableAttributedString alloc] initWithAttributedString:appendant] autorelease];
	NSUInteger		length = [appendant length];
	NSRange			effectiveRange = NSMakeRange(0, 0);
#if APPKIT
	NSFont			*srcFont, *font;
    NSFontTraitMask    appendantFontTraits, srcFontTraits, newFontTraits = 0;
    NSFont            *newFont;

#endif
    
#if UIKIT
    UIFont            *srcFont, *font;
    UIFontDescriptorSymbolicTraits  appendantFontTraits, srcFontTraits, newFontTraits = 0;
    UIFont            *newFont;
#endif
	NSString		*appendantFontFamilyName = nil, *srcFontFamilyName;
    
	float			appendantFontWeight = 0, srcFontWeight;
	float			appendantFontPointSize = 0, srcFontPointSize;
	NSDictionary	*srcAttributes;
	NSAttributedString	*srcAttributedString = [srcString attributedString];
	
	srcAttributes = [srcAttributedString attributesAtIndex:0 effectiveRange:NULL];
    
	srcFont = [srcAttributes objectForKey:NSFontAttributeName];
	if (srcFont == nil) {
#if APPKIT
		srcFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
#elif UIKIT
        srcFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
#endif
	}
	srcFontFamilyName = [srcFont familyName];
#if APPKIT
	srcFontTraits = [_fontManager traitsOfFont:srcFont];
	srcFontWeight = [_fontManager weightOfFont:srcFont];
#elif UIKIT
    srcFontTraits = srcFont.fontDescriptor.symbolicTraits;
    srcFontWeight = [srcFont.fontDescriptor.fontAttributes[UIFontWeightTrait] floatValue];
#endif
	srcFontPointSize = [srcFont pointSize];
	
	if (!mergeAttributes) {
		// replace attributes
		[aString setAttributes:srcAttributes range:NSMakeRange(0, length)];
		[_currentAttributes autorelease];
		_currentAttributes = [srcAttributes retain];
	} else {
		// merge attributes
		NSEnumerator	*keyEnumerator = [srcAttributes keyEnumerator];
		NSString		*attrKey;
		while ((attrKey = [keyEnumerator nextObject]) != nil) {
			id	attr = [srcAttributes objectForKey:attrKey];
			//if (attr != nil) {
				[aString addAttribute:attrKey 
					value:attr 
					range:NSMakeRange(0, length)];
			//}
		}
		[_currentAttributes autorelease];
		_currentAttributes = [[aString attributesAtIndex:(length - 1) effectiveRange:NULL] retain];
	}
	
	while (effectiveRange.location < length) {
		font = [appendant attribute:NSFontAttributeName 
			atIndex:effectiveRange.location 
			effectiveRange:&effectiveRange];
		if (font == nil) {
#if APPKIT
			font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
#elif UIKIT
            font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
#endif
		}
		appendantFontFamilyName = [font familyName];
#if APPKIT
		appendantFontTraits = [_fontManager traitsOfFont:font];
		appendantFontWeight = [_fontManager weightOfFont:font];
#elif UIKIT
        appendantFontTraits = srcFont.fontDescriptor.symbolicTraits;
        appendantFontWeight = [srcFont.fontDescriptor.fontAttributes[UIFontWeightTrait] floatValue];
#endif
    
        
 
		appendantFontPointSize = [font pointSize];
		
		if (!mergeAttributes) {
			// replace traits
			newFontTraits = srcFontTraits;
		} else {
			// merge traits
			newFontTraits = srcFontTraits | appendantFontTraits;
#if APPKIT
            if ((newFontTraits & NSBoldFontMask) != 0) { newFontTraits &= ~NSUnboldFontMask; }
			if ((newFontTraits & NSItalicFontMask) != 0) { newFontTraits &= ~NSUnitalicFontMask; }
#endif
			if ((newFontTraits & NSCondensedFontMask) != 0 && (newFontTraits & NSExpandedFontMask) != 0) {
				if ((srcFontTraits & NSCondensedFontMask) != 0) {
					newFontTraits &= ~NSExpandedFontMask;
				} else {
					newFontTraits &= ~NSCondensedFontMask;
				}
			}
		}
#if APPKIT
		if (changeFont) {
			newFont = [_fontManager fontWithFamily:srcFontFamilyName 
				traits:0 
				weight:srcFontWeight 
				size:srcFontPointSize];
		} else {
			newFont = [_fontManager fontWithFamily:appendantFontFamilyName 
				traits:0 
				weight:appendantFontWeight 
				size:appendantFontPointSize];
		}
		NSFontTraitMask	trait;
		for (trait = 1; trait <= newFontTraits; trait <<= 1) {
			if ((trait & newFontTraits) != 0 && (font = [_fontManager convertFont:newFont toHaveTrait:(trait & newFontTraits)]) != nil) {
				newFont = font;
			}
		}
#elif UIKIT
        // TODO: iOS Traits
        if (changeFont) {
            UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithFontAttributes:@{
                UIFontDescriptorFamilyAttribute:srcFontFamilyName,
                UIFontDescriptorTraitsAttribute:@{
                        UIFontWeightTrait: @(srcFontWeight),
                }
            }];
            newFont = [UIFont fontWithDescriptor:desc size:srcFontPointSize];
        } else {
            UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithFontAttributes:@{
                UIFontDescriptorFamilyAttribute:appendantFontFamilyName,
                UIFontDescriptorTraitsAttribute:@{
                        UIFontWeightTrait: @(appendantFontWeight),
                }
            }];
            newFont = [UIFont fontWithDescriptor:desc size:appendantFontPointSize];
        }
#endif
		
		if (newFont != nil) {
			[aString addAttribute:NSFontAttributeName 
				value:newFont 
				range:effectiveRange];
		}
		
		effectiveRange.location = NSMaxRange(effectiveRange);
	}
	
	if (changeFont) {
		[_currentFontFamilyName autorelease];
		_currentFontFamilyName = [srcFontFamilyName retain];
		_currentFontTraits = newFontTraits;
		_currentFontWeight = srcFontWeight;
		_currentFontPointSize = srcFontPointSize;
	} else if (appendantFontFamilyName != nil) {
		[_currentFontFamilyName autorelease];
		_currentFontFamilyName = [appendantFontFamilyName retain];
		_currentFontTraits = newFontTraits;
		_currentFontWeight = appendantFontWeight;
		_currentFontPointSize = appendantFontPointSize;
	}
	
	[attrString appendAttributedString:aString];
	
	[pool release];
}

- (void)appendOGString:(NSObject<OGStringProtocol>*)string 
	changeFont:(BOOL)changeFont 
	mergeAttributes:(BOOL)mergeAttributes 
{
	if ([string length] == 0) {
		return;
	}
	
	NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc] init];
	
	NSAttributedString			*appendant = [string attributedString];
	NSMutableAttributedString	*attrString = (NSMutableAttributedString*)[self _attributedString];
	
	NSMutableAttributedString	*aString = [[[NSMutableAttributedString alloc] initWithAttributedString:appendant] autorelease];
	NSRange			effectiveRange;
	NSUInteger		length = [appendant length];
	NSString		*appendantFontFamilyName = nil;
#if APPKIT
    NSFont            *font;
	NSFontTraitMask	appendantFontTraits, newFontTraits = 0;
    NSFont            *newFont;
#elif UIKIT
    UIFont            *font;
    UIFontDescriptorSymbolicTraits appendantFontTraits, newFontTraits = 0;
    UIFont            *newFont;
#endif
    
	float			appendantFontWeight = 0;
	float			appendantFontPointSize = 0;
	
	
	if (mergeAttributes) {
		// overwrite attributes
		effectiveRange = NSMakeRange(0, 0);
		while (effectiveRange.location < length) {
			NSDictionary	*attr = [appendant attributesAtIndex:effectiveRange.location 
				effectiveRange:&effectiveRange];
			NSEnumerator	*keyEnumerator = [_currentAttributes keyEnumerator];
			NSString		*attrKey;
			while ((attrKey = [keyEnumerator nextObject]) != nil) {
				if ([attr objectForKey:attrKey] == nil) {
					id	attr = [_currentAttributes objectForKey:attrKey];
					//if (attr != nil) {
						[aString addAttribute:attrKey 
							value:attr 
							range:effectiveRange];
					//}
				}
			}
			effectiveRange.location = NSMaxRange(effectiveRange);
		}
		[_currentAttributes autorelease];
		_currentAttributes = [[aString attributesAtIndex:(length - 1) effectiveRange:NULL] retain];
	}
	
	effectiveRange = NSMakeRange(0, 0);
	while (effectiveRange.location < length) {
		font = [appendant attribute:NSFontAttributeName 
			atIndex:effectiveRange.location 
			effectiveRange:&effectiveRange];
		if (font == nil) {
#if APPKIT
			font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
#elif UIKIT
            font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
#endif
		}
		appendantFontFamilyName = [font familyName];
        
#if APPKIT
		appendantFontTraits = [_fontManager traitsOfFont:font];
		appendantFontWeight = [_fontManager weightOfFont:font];
#elif UIKIT
        appendantFontTraits = font.fontDescriptor.symbolicTraits;
        appendantFontWeight = [font.fontDescriptor.fontAttributes[UIFontWeightTrait] floatValue];
#endif
		appendantFontPointSize = [font pointSize];
		
		if (!mergeAttributes) {
			// replace traits
			newFontTraits = appendantFontTraits;
		} else {
			// overwrite traits
			newFontTraits = _currentFontTraits | appendantFontTraits;
#if APPKIT
			if ((newFontTraits & NSBoldFontMask) != 0) { newFontTraits &= ~NSUnboldFontMask; }
			if ((newFontTraits & NSItalicFontMask) != 0) { newFontTraits &= ~NSUnitalicFontMask; }
#endif
			if ((newFontTraits & NSCondensedFontMask) != 0 && (newFontTraits & NSExpandedFontMask) != 0) {
				if ((appendantFontTraits & NSCondensedFontMask) != 0) {
					newFontTraits &= ~NSExpandedFontMask;
				} else {
					newFontTraits &= ~NSCondensedFontMask;
				}
			}
		}
#if APPKIT
		if (changeFont) {
			newFont = [_fontManager fontWithFamily:appendantFontFamilyName 
				traits:0 
				weight:appendantFontWeight 
				size:appendantFontPointSize];
		} else {
			newFont = [_fontManager fontWithFamily:_currentFontFamilyName 
				traits:0 
				weight:_currentFontWeight 
				size:_currentFontPointSize];
		}
		NSFontTraitMask	trait;
		for (trait = 1; trait <= newFontTraits; trait <<= 1) {
			if ((trait & newFontTraits) != 0 && (font = [_fontManager convertFont:newFont toHaveTrait:(trait & newFontTraits)]) != nil) {
				newFont = font;
			}
		}
#elif UIKIT
        // TODO: iOS Traits
        if (changeFont) {
            UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithFontAttributes:@{
                UIFontDescriptorFamilyAttribute:appendantFontFamilyName,
                UIFontDescriptorTraitsAttribute:@{
                        UIFontWeightTrait: @(appendantFontWeight),
                }
            }];
            newFont = [UIFont fontWithDescriptor:desc size:appendantFontPointSize];
        } else {
            UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithFontAttributes:@{
                UIFontDescriptorFamilyAttribute:_currentFontFamilyName,
                UIFontDescriptorTraitsAttribute:@{
                        UIFontWeightTrait: @(_currentFontWeight),
                }
            }];
            newFont = [UIFont fontWithDescriptor:desc size:_currentFontPointSize];
        }
#endif
		
		if (newFont != nil) {
			[aString addAttribute:NSFontAttributeName 
				value:newFont 
				range:effectiveRange];
		}
		
		effectiveRange.location = NSMaxRange(effectiveRange);
	}
	
	if (changeFont && _currentFontFamilyName != nil) {
		[_currentFontFamilyName autorelease];
		_currentFontFamilyName = [appendantFontFamilyName retain];
		_currentFontTraits = newFontTraits;
		_currentFontWeight = appendantFontWeight;
		_currentFontPointSize = appendantFontPointSize;
	}
	
	[attrString appendAttributedString:aString];
	
	[pool release];
}

- (void)setAttributesOfOGString:(NSObject<OGStringProtocol>*)string atIndex:(NSUInteger)index
{
	NSUInteger	attrIndex;
	if (index > 0) {
		attrIndex = index -1;
	} else {
		attrIndex = index;
	}
	
#if APPKIT
	NSFont				*font;
#elif UIKIT
    UIFont                *font;
#endif
	NSAttributedString	*attrString;
	if (attrIndex < [string length]) {
		attrString = [string attributedString];
	} else {
		attrString = [[[NSAttributedString alloc] initWithString:@" "] autorelease];
	}
	
	font = [attrString attribute:NSFontAttributeName atIndex:attrIndex effectiveRange:nil];
	if (font == nil) {
#if APPKIT
		font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
#elif UIKIT
        font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
#endif
	}
	[_currentFontFamilyName autorelease];
	_currentFontFamilyName = [[font familyName] retain];

#if APPKIT
    _currentFontTraits = [_fontManager traitsOfFont:font];
    _currentFontWeight = [_fontManager weightOfFont:font];
#elif UIKIT
    _currentFontTraits = font.fontDescriptor.symbolicTraits;
    _currentFontWeight = [font.fontDescriptor.fontAttributes[UIFontWeightTrait] floatValue];
#endif
	_currentFontPointSize = [font pointSize];
	
	[_currentAttributes autorelease];
	_currentAttributes = [[attrString attributesAtIndex:attrIndex effectiveRange:NULL] retain];
}

@end

