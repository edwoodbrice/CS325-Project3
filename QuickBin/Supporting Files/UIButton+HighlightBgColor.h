//
//  UIButton+HighlightBgColor.h
//  -
//
//  Created by User on 8/30/18.
//  Copyright © 2018 User. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIButton (HighlightBgColor)

+ (UIImage *) imageForColor: (UIColor *) color;
- (void) setBackgroundColor:(UIColor *)color forState:(UIControlState)state;

@end
NS_ASSUME_NONNULL_END
