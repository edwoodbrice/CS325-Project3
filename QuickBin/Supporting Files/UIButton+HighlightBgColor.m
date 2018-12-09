//
//  UIButton+HighlightBgColor.m
//  -
//
//  Created by User on 8/30/18.
//  Copyright © 2018 User. All rights reserved.
//

#import "UIButton+HighlightBgColor.h"

@implementation UIButton (HighlightBgColor)

+ (nonnull UIImage *)imageForColor:(nonnull UIColor *)color { 
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (void)setBackgroundColor:(nonnull UIColor *)color forState:(UIControlState)state {
    [self setBackgroundImage:[UIButton imageForColor:color] forState:state];
}

@end
