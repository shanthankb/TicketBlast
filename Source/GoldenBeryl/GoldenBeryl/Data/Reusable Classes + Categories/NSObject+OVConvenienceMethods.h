//
//  NSObject+OVConvenienceMethods.h
//  CitrineEx
//
//  Created by Sourcebits Inc
//  Copyright 2012 Research Habits LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define selfRef [self nonRetainedReference]


@interface NSObject (OVConvenienceMethods)

//Universal alloc is used to automatically find the proper iPhone or iPad specific class
//of a particular object, specifically view controllers, and alloc it with that 
//specific class, instead of having branching code to alloc either _iPad classes or 
//_iPhone classes. Just point at the base class and say "universalAlloc" and you'll have an 
//object of the _iPad or _iPhone subclass automatically!
+ (id)universalAlloc;

- (void)setValue:(id)value forIVar:(NSString *)iVarKey;
- (id)valueForIVar:(NSString *)iVarKey;
- (void)releaseAllIVars;
- (NSValue *)nonRetainedReference;

- (void)setBool:(BOOL)boolValue forIVar:(NSString *)iVarKey;
- (BOOL)boolForIVar:(NSString *)iVarKey;
- (void)setFloat:(float)floatValue forIVar:(NSString *)iVarKey;
- (float)floatForIVar:(NSString *)iVarKey;

@end
