//
//  FacemashPhoto.m
//  Tipbox
//
//  Created by Ali Mahouk on 1/6/12.
//  Copyright (c) 2012 Scapehouse. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "FacemashPhoto.h"

@implementation FacemashPhoto

@synthesize photo, menuController, userid;
@synthesize name, username;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        photo = [[EGOImageView alloc] initWithFrame:CGRectMake(1, 1, 23, 24)];
        photo.layer.masksToBounds = YES;
        photo.layer.cornerRadius = 2;
        photo.opaque = YES;
        
        // Show the tooltips on tap-and-hold.
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:longPressRecognizer];
        
        [self setBackgroundImage:[UIImage imageNamed:@"beige_user_icon_overlay_small.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"beige_user_icon_overlay_small_highlighted.png"] forState:UIControlStateHighlighted];
        self.adjustsImageWhenHighlighted = NO;
        self.adjustsImageWhenDisabled = NO;
        [self addSubview:photo];
        
        [longPressRecognizer release];
    }
    
    return self;
}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        menuController = [UIMenuController sharedMenuController];
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ ⋅ @%@", name, username] action:@selector(menuItemClicked:)];
        
        [self becomeFirstResponder];
        [menuController setMenuItems:[NSArray arrayWithObject:menuItem]];
        [menuController setTargetRect:self.frame inView:[self superview]];
        [menuController setMenuVisible:YES animated:YES];
        
        [menuItem release];
    }
}

- (void)menuItemClicked:(id)sender
{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside]; // The equivalent of tapping the photo itself.
}

- (BOOL)canPerformAction:(SEL)selector withSender:(id)sender
{
    if (selector == @selector(menuItemClicked:)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)dealloc
{
    [photo release];
    [userid release];
    [name release];
    [username release];
    [super dealloc];
}

@end
