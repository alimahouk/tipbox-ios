//
//  FacemashPhoto.h
//  Tipbox
//
//  Created by Ali Mahouk on 1/6/12.
//  Copyright (c) 2012 Scapehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface FacemashPhoto : UIButton {
    EGOImageView *photo;
    UIMenuController *menuController;
    NSString *userid;
    NSString *name;
    NSString *username;
}

@property (nonatomic, retain) EGOImageView *photo;
@property (nonatomic, retain) UIMenuController *menuController;
@property (nonatomic, retain) NSString *userid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *username;

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void)menuItemClicked:(id)sender;

@end
