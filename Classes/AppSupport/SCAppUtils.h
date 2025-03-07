/*
 * Copyright (c) 2010-2010 Sebastian Celis
 * All rights reserved.
 */

#import <UIKit/UIKit.h>

#define kSCNavigationBarBackgroundImageTag 6183746
#define kSCNavigationBarTintColor [UIColor colorWithRed:137/255.0 green:138/255.0 blue:139/255.0 alpha:1.0]

@interface SCAppUtils : NSObject
{
}

+ (void)customizeNavigationController:(UINavigationController *)navController;

@end
