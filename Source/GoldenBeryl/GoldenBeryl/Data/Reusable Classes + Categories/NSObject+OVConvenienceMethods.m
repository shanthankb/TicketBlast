//
//  NSObject+OVConvenienceMethods.m
//  CitrineEx
//
//  Created by Sourcebits Inc
//  Copyright 2012 Research Habits LLC. All rights reserved.
//

#import "NSObject+OVConvenienceMethods.h"
#import <UIKit/UIKit.h>

@implementation NSObject (OVConvenienceMethods)

+ (id)universalAlloc {
 
    NSString *className = NSStringFromClass(self);
    NSString *deviceSpecificSubclassName = [NSString stringWithFormat:@"%@_%@",className, (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? @"iPad":@"iPhone")];
    
    Class subclassObject = NSClassFromString(deviceSpecificSubclassName);
    Class chosenClass = (subclassObject) ? subclassObject : self;
    
    return [chosenClass alloc];
}


static NSMutableDictionary *sIVarsHolder;

- (void)setValue:(id)value forIVar:(NSString *)iVarKey {
    
    if(!sIVarsHolder)
    {
        sIVarsHolder = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    
    NSMutableDictionary *allVars = [sIVarsHolder objectForKey:selfRef];
    
    if(!allVars)
    {
        allVars = [[NSMutableDictionary alloc] initWithCapacity:1];
        [sIVarsHolder setObject:allVars forKey:selfRef];
        [allVars release];
    }
        
    [allVars setObject:value forKey:iVarKey];
}

- (id)valueForIVar:(NSString *)iVarKey {
    
    NSMutableDictionary *allVars = [sIVarsHolder objectForKey:selfRef];
    return [allVars objectForKey:iVarKey];
}

- (void)releaseAllIVars {
    
    [sIVarsHolder removeObjectForKey:selfRef];
}

- (NSValue *)nonRetainedReference {
    
    return [NSValue valueWithNonretainedObject:self];
}



- (void)setBool:(BOOL)boolValue forIVar:(NSString *)iVarKey {
    
    NSNumber *boolNumber = [NSNumber numberWithBool:boolValue];
    [self setValue:boolNumber forIVar:iVarKey];
}

- (BOOL)boolForIVar:(NSString *)iVarKey {
    
    NSNumber *boolNumber = [self valueForIVar:iVarKey];
    return [boolNumber boolValue];
}

- (void)setFloat:(float)floatValue forIVar:(NSString *)iVarKey {
    
    NSNumber *floatNumber = [NSNumber numberWithFloat:floatValue];
    [self setValue:floatNumber forIVar:iVarKey];
}

- (float)floatForIVar:(NSString *)iVarKey {
    
    NSNumber *floatNumber = [self valueForIVar:iVarKey];
    return [floatNumber floatValue];
}

@end