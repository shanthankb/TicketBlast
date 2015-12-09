//
//  GBNotesCustomTextView.m
//  TicketBlast
//
//  Created by Mohammed Shahid on 02/04/13.
//  Copyright (c) 2013 Sourcebits. All rights reserved.
//

#import "GBNotesCustomTextView.h"

@interface UITextView ()
- (id)styleString; // make compiler happy
@end

@implementation GBNotesCustomTextView

- (id)styleString {
    return [[super styleString] stringByAppendingString:@"; line-height: 1.8em"];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
	}
    return self;
}

//- (void)drawRect:(CGRect)rect
//{
//	CGContextRef context = UIGraphicsGetCurrentContext();
//	
//    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
//    CGContextSetLineWidth(context, self.lineWidth);
//    CGFloat strokeOffset = (self.lineWidth/2);
//	
//    CGFloat rowHeight = 15.0;
//    if (rowHeight > 0) {
//        CGRect rowRect = CGRectMake(self.contentOffset.x, - self.bounds.size.height-3.0, self.contentSize.width, rowHeight);
//        while (rowRect.origin.y < (self.bounds.size.height + self.contentSize.height)) {
//        
//			//if( rowRect.origin.y > 25 ) // Skip First Line As Per VD
//			{
//				CGContextMoveToPoint(context, rowRect.origin.x + strokeOffset, rowRect.origin.y + strokeOffset);
//				CGContextAddLineToPoint(context, rowRect.origin.x + rowRect.size.width + strokeOffset, rowRect.origin.y + strokeOffset);
//				CGContextDrawPath(context, kCGPathStroke);
//			}
//            rowRect.origin.y += rowHeight;
//        
//        }
//    }
//}

@end
