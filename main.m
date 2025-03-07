//
//  main.m
//  Tipbox
//
//  Created by Ali Mahouk on 10/2/11.
//  Copyright 2011 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCClassUtils.h"

int main(int argc, char *argv[])
{
    [SCClassUtils swizzleSelector:@selector(insertSubview:atIndex:)
                          ofClass:[UINavigationBar class]
                     withSelector:@selector(scInsertSubview:atIndex:)];
    [SCClassUtils swizzleSelector:@selector(sendSubviewToBack:)
                          ofClass:[UINavigationBar class]
                     withSelector:@selector(scSendSubviewToBack:)];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"TipboxAppDelegate");
    [pool release];
    return retVal;
}
