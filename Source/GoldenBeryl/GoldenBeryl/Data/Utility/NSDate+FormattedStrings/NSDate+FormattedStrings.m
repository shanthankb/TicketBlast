//
//  NSDate+FormattedStrings.m
//


#import "NSDate+FormattedStrings.h"

@implementation NSDate (FormattedStrings)

- (NSString *)mediumString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:self];
}

@end