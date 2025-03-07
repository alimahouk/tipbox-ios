#import <QuartzCore/QuartzCore.h>
#import "TipboxAppDelegate.h"
#import "SCAppUtils.h"
#import "Global.h"
#import "Sound.h"
#import "Publisher.h"
#import "FeedViewController.h"
#import "TipViewController.h"
#import "TopicViewController.h"
#import "MeViewController.h"
#import "Flurry.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation TipboxAppDelegate

@synthesize dataRequest, responseData, global, currentDeviceModel, window, mainTabBarController;
@synthesize signupViewNavigationController, publisherNavigationController, strobeLight, boxCoverUpper;
@synthesize boxCoverLower, device_token, SHToken, FBToken, TWToken, SHAppid, facebook, fbUserPermissions;

NSString *const FBSessionStateChangedNotification = @"com.scapehouse.Tipbox:FBSessionStateChangedNotification";

// Startup animation.
- (void)openBoxWithConfiguration:(NSString *)configuration
{
    // Cancel the running timer, otherwise you'll see some strange behavior sometimes.
    [boxAnimationTimer invalidate];
    boxAnimationTimer = nil;
    
    [self showNavbarShadowAnimated:YES]; // Show the navbar shadow!
    [self showTabbarShadowAnimated:YES]; // Show the tab bar shadow!
    
    // Drop shadows.
    boxCoverUpper.layer.shadowOffset = CGSizeMake(0, 0);
    boxCoverUpper.layer.shadowRadius = 5;
    boxCoverUpper.layer.shadowOpacity = 1.0;
    
    boxCoverLower.layer.shadowOffset = CGSizeMake(0, 0);
    boxCoverLower.layer.shadowRadius = 5;
    boxCoverLower.layer.shadowOpacity = 1.0;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    
    // 3D rotations.
    CATransform3D rotationAndPerspectiveTransformUpper = CATransform3DIdentity;
    rotationAndPerspectiveTransformUpper.m43 = 1.0 / 500;
    rotationAndPerspectiveTransformUpper = CATransform3DTranslate(rotationAndPerspectiveTransformUpper, -200, -320, 0);
    rotationAndPerspectiveTransformUpper = CATransform3DRotate(rotationAndPerspectiveTransformUpper, M_PI * 1.5, 0, 1, 1);
    rotationAndPerspectiveTransformUpper = CATransform3DTranslate(rotationAndPerspectiveTransformUpper, 320, 0, 0);
    boxCoverUpper.layer.transform = rotationAndPerspectiveTransformUpper;
    
    CATransform3D rotationAndPerspectiveTransformLower = CATransform3DIdentity;
    rotationAndPerspectiveTransformLower.m43 = 1.0 / 500;
    rotationAndPerspectiveTransformLower = CATransform3DTranslate(rotationAndPerspectiveTransformLower, -200, 320, 0);
    rotationAndPerspectiveTransformLower = CATransform3DRotate(rotationAndPerspectiveTransformLower, M_PI * 1.5, 0, 1, -1);
    rotationAndPerspectiveTransformLower = CATransform3DTranslate(rotationAndPerspectiveTransformLower, 320, 0, 0);
    boxCoverLower.layer.transform = rotationAndPerspectiveTransformLower;
    
    [UIView commitAnimations];
    
    // Covers fade out.
    // NOTE: Duration should always be 0.1 less than the opening animation!
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.9];
    boxCoverUpper.alpha = 0.0;
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.9];
    boxCoverLower.alpha = 0.0;
    [UIView commitAnimations];
    
    // Main view fade in.
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.removedOnCompletion = YES;
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
    
    CABasicAnimation *scaleInAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleInAnimation.fromValue = [NSNumber numberWithFloat:0.5];
    scaleInAnimation.toValue = [NSNumber numberWithFloat:1.0];
    
    animationGroup.animations = [NSArray arrayWithObjects:fadeInAnimation, scaleInAnimation, nil];
    
    if ([configuration isEqualToString:@"main"]) {
        mainTabBarController.tabBar.hidden = NO;
        [mainTabBarController.view.layer addAnimation:animationGroup forKey:@"fadeInAnimation"];
        mainTabBarController.view.layer.opacity = 1.0;
    } else if ([configuration isEqualToString:@"signup"]) {
        [signupViewNavigationController.view.layer addAnimation:animationGroup forKey:@"fadeInAnimation"];
        signupViewNavigationController.view.layer.opacity = 1.0;
    } else if ([configuration isEqualToString:@"explorer"]) {
        [tipExplorerNavigationController.view.layer addAnimation:animationGroup forKey:@"fadeInAnimation"];
        tipExplorerNavigationController.view.layer.opacity = 1.0;
    }
    
    // Hide the covers once they're out of view.
    boxAnimationTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(hideBoxCovers)
                                   userInfo:nil
                                    repeats:NO] retain];
}

- (void)closeBoxWithConfiguration:(NSString *)configuration
{
    // Cancel the running timer, otherwise you'll see some strange behavior sometimes.
    [boxAnimationTimer invalidate];
    boxAnimationTimer = nil;
    
    [self hideNavbarShadowAnimated:YES]; // Hide the navbar shadow!
    [self hideTabbarShadowAnimated:YES]; // Hide the tab bar shadow!
    [strobeLight deactivateStrobeLight];
    boxCoverUpper.hidden = NO;
    boxCoverLower.hidden = NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4]; // The closing animation is faster than the opening one.
    
    // 3D rotations.
    CATransform3D rotationAndPerspectiveTransformUpper = CATransform3DIdentity;
    rotationAndPerspectiveTransformUpper.m43 = 1.0 / 500;
    rotationAndPerspectiveTransformUpper = CATransform3DTranslate(rotationAndPerspectiveTransformUpper, -200, -320, 0);
    rotationAndPerspectiveTransformUpper = CATransform3DRotate(rotationAndPerspectiveTransformUpper, M_PI * 4, 0, 0, -1);
    rotationAndPerspectiveTransformUpper = CATransform3DTranslate(rotationAndPerspectiveTransformUpper, 200, 320, 0);
    boxCoverUpper.layer.transform = rotationAndPerspectiveTransformUpper;
    
    CATransform3D rotationAndPerspectiveTransformLower = CATransform3DIdentity;
    rotationAndPerspectiveTransformLower.m43 = 1.0 / 500;
    rotationAndPerspectiveTransformLower = CATransform3DTranslate(rotationAndPerspectiveTransformLower, -200, -320, 0);
    rotationAndPerspectiveTransformLower = CATransform3DRotate(rotationAndPerspectiveTransformLower,  M_PI * 4, 0, 0, 1);
    rotationAndPerspectiveTransformLower = CATransform3DTranslate(rotationAndPerspectiveTransformLower, 200, 320, 0);
    boxCoverLower.layer.transform = rotationAndPerspectiveTransformLower;
    
    [UIView commitAnimations];
    
    // Covers fade in.
    // NOTE: Duration should always be 0.1 less than the closing animation!
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    boxCoverUpper.alpha = 1.0;
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    boxCoverLower.alpha = 1.0;
    [UIView commitAnimations];
    
    // Main view fade out.
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.removedOnCompletion = YES;
    
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    fadeOutAnimation.toValue = [NSNumber numberWithFloat:0.0];
    
    CABasicAnimation *scaleOutAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleOutAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleOutAnimation.toValue = [NSNumber numberWithFloat:0.5];
    
    animationGroup.animations = [NSArray arrayWithObjects:fadeOutAnimation, scaleOutAnimation, nil];
    
    
    if ([configuration isEqualToString:@"main"]) {
        [mainTabBarController.view.layer addAnimation:animationGroup forKey:@"fadeOutAnimation"];
        mainTabBarController.view.layer.opacity = 0.0;
    } else if ([configuration isEqualToString:@"signup"]) {
        [signupViewNavigationController.view.layer addAnimation:animationGroup forKey:@"fadeOutAnimation"];
        signupViewNavigationController.view.layer.opacity = 0.0;
        
        [NSTimer scheduledTimerWithTimeInterval:0.4
                                         target:self
                                       selector:@selector(hideSignupView)
                                       userInfo:nil
                                        repeats:NO];
    } else if ([configuration isEqualToString:@"explorer"]) {
        [tipExplorerNavigationController.view.layer addAnimation:animationGroup forKey:@"fadeOutAnimation"];
        tipExplorerNavigationController.view.layer.opacity = 0.0;
        
        [NSTimer scheduledTimerWithTimeInterval:0.4
                                         target:self
                                       selector:@selector(hideTipExplorer)
                                       userInfo:nil
                                        repeats:NO];
    } else if ([configuration isEqualToString:@"home"]) {
        [signupViewNavigationController.view.layer addAnimation:animationGroup forKey:@"fadeOutAnimation"];
        signupViewNavigationController.view.layer.opacity = 0.0;
        
        [NSTimer scheduledTimerWithTimeInterval:0.4
                                         target:self
                                       selector:@selector(goHome)
                                       userInfo:nil
                                        repeats:NO];
    }
    
    // Remove the drop shadows.
    boxCoverUpper.layer.shadowRadius = 0;
    boxCoverLower.layer.shadowRadius = 0;
    
    boxAnimationTimer = [[NSTimer scheduledTimerWithTimeInterval:0.4
                                     target:self
                                   selector:@selector(showLoginFields)
                                   userInfo:nil
                                    repeats:NO] retain];
}

- (void)hideBoxCovers
{
    boxCoverUpper.hidden = YES;
    boxCoverLower.hidden = YES;
    logoutMessage.hidden = YES; // Hide the logout message.
}

- (void)showLoginFields
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    loginBoxShadow.hidden = NO;
    loginBox.hidden = NO;
    loginBoxShadow.layer.zPosition = 1;
    loginBox.layer.zPosition = 1;
    loginBoxShadow.frame = CGRectMake(-252, (screenHeight / 2) - 70, 251, 164);
    loginBox.frame = CGRectMake(-252, (screenHeight / 2) - 70, 251, 164);
    
    // Clear out any junk values in the fields.
    field_username.text = @"";
    field_passwd.text = @"";
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    loginBoxShadow.frame = CGRectMake(33, (screenHeight / 2) - 70, 251, 164);
    loginBox.frame = CGRectMake(33, (screenHeight / 2) - 70, 251, 164);
    [UIView commitAnimations];
}

- (void)hideLoginFields
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    loginBoxShadow.frame = CGRectMake(321, (screenHeight / 2) - 70, 251, 164);
    loginBox.frame = CGRectMake(321, (screenHeight / 2) - 70, 251, 164);
    [UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:0.4
                                     target:self
                                   selector:@selector(hideLoginBox)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)flipBackLoginBox
{
    // Reset these...
    label_cancelPasswdResetButton.text = @"Cancel";
    label_passwdResetButton.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    passwdResetButton.enabled = YES;
    passwdResetButton.hidden = NO;
    passwdResetFieldBGImageView.hidden = NO;
    field_passwdReset.enabled = YES;
    field_passwdReset.hidden = NO;
    field_passwdReset.text = @"";
    passwdResetDescLabel.text = @"Forgot your password? Enter your email and we'll help you reset it.";
    
    if (keyboardIsShown) {
        [self hideKeyboardForFlip:@"back"];
        return;
    }
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.8];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
						   forView:loginBox
							 cache:YES];
	[UIView commitAnimations];
    
    if ([currentDeviceModel isEqualToString:@"iPhone5,1"]) {
        // iPhone 5, no need to move anything up/down.
    } else {
        loginBoxShadow.frame = CGRectMake(33, 155, 251, 164);
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:0.8];
    if ([currentDeviceModel isEqualToString:@"iPhone5,1"]) {
        // iPhone 5, no need to move anything up/down.
    } else {
        loginBoxShadow.frame = CGRectMake(33, 155, 231, 164);
    }
	[UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.8];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
						   forView:loginBoxBack
							 cache:YES];
	[UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:0.4
                                     target:self
                                   selector:@selector(reverseCoverLayerOrder)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)reverseCoverLayerOrder
{
    loginBox.hidden = YES;
    loginBoxBack.hidden = NO;
    loginBoxBack.layer.zPosition = 1;
    
    if ([currentDeviceModel isEqualToString:@"iPhone5,1"]) {
        // iPhone 5, no need to move anything up/down.
    } else {
        loginBoxShadow.frame = CGRectMake(33, 155, 231, 164);
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:0.4];
    if ([currentDeviceModel isEqualToString:@"iPhone5,1"]) {
        // iPhone 5, no need to move anything up/down.
    } else {
        loginBoxShadow.frame = CGRectMake(33, 155, 251, 164);
    }
	[UIView commitAnimations];
}

- (void)flipFrontLoginBox
{
    field_passwdReset.enabled = NO;
    
    if (keyboardIsShown) {
        [self hideKeyboardForFlip:@"front"];
        return;
    }
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.8];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
						   forView:loginBox
							 cache:YES];
	[UIView commitAnimations];
    
    if ([currentDeviceModel isEqualToString:@"iPhone5,1"]) {
        // iPhone 5, no need to move anything up/down.
    } else {
        loginBoxShadow.frame = CGRectMake(33, 155, 251, 164);
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:0.8];
    if ([currentDeviceModel isEqualToString:@"iPhone5,1"]) {
        // iPhone 5, no need to move anything up/down.
    } else {
        loginBoxShadow.frame = CGRectMake(123, 155, 161, 164);
    }
	[UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.8];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
						   forView:loginBoxBack
							 cache:YES];
	[UIView commitAnimations];
    
    [NSTimer scheduledTimerWithTimeInterval:0.4
                                     target:self
                                   selector:@selector(restoreCoverLayerOrder)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)restoreCoverLayerOrder
{
    loginBox.hidden = NO;
    loginBoxBack.hidden = YES;
    loginBox.layer.zPosition = 1;
    
    if ([currentDeviceModel isEqualToString:@"iPhone5,1"]) {
        // iPhone 5, no need to move anything up/down.
    } else {
        loginBoxShadow.frame = CGRectMake(123, 155, 161, 164);
    }
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:0.4];
    if ([currentDeviceModel isEqualToString:@"iPhone5,1"]) {
        // iPhone 5, no need to move anything up/down.
    } else {
        loginBoxShadow.frame = CGRectMake(33, 155, 251, 164);
    }
	[UIView commitAnimations];
}

- (void)hideKeyboardForFlip:(NSString *)flipDirection
{
    [field_username resignFirstResponder];
    [field_passwd resignFirstResponder];
    [field_passwdReset resignFirstResponder];
    
    if ([flipDirection isEqualToString:@"back"]) {
        [NSTimer scheduledTimerWithTimeInterval:0.3
                                         target:self
                                       selector:@selector(flipBackLoginBox)
                                       userInfo:nil
                                        repeats:NO];
    } else {
        [NSTimer scheduledTimerWithTimeInterval:0.3
                                         target:self
                                       selector:@selector(flipFrontLoginBox)
                                       userInfo:nil
                                        repeats:NO];
    }
    
}

- (void)hideLoginBox
{
    loginBoxShadow.hidden = YES;
    loginBox.hidden = YES;
}

#pragma mark -
#pragma mark Publisher handler

- (void)SHPopupPublisher
{
    mainTabBarController.tabBar.hidden = YES;
    [self navbarShadowMode_navbar];
    [self tabbarShadowMode_nobar];
    [self showNavbarShadowAnimated:YES];
    [self showTabbarShadowAnimated:YES];
    
	Publisher *pub = [[Publisher alloc] init];
    publisherNavigationController = [[UINavigationController alloc] initWithRootViewController:pub];
    pub.category = -1; // Default value.
	[mainTabBarController presentModalViewController:publisherNavigationController animated:true];
	[pub release];
}

#pragma mark -
#pragma mark Navbar shadow

- (void)hideNavbarShadowAnimated:(BOOL)animated
{
    if (navbarShadow.alpha == 1.0) {
        navbarShadow.alpha = 1.0;
        
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.2];
            navbarShadow.alpha = 0.0;
            [UIView commitAnimations];
        } else {
            navbarShadow.alpha = 0.0;
        }
    }
}

- (void)showNavbarShadowAnimated:(BOOL)animated
{
    if (navbarShadow.alpha == 0.0) {
        navbarShadow.alpha = 0.0;
        
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.2];
            navbarShadow.alpha = 1.0;
            [UIView commitAnimations];
        } else {
            navbarShadow.alpha = 1.0;
        }
    }
}

- (void)navbarShadowMode_navbar
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.1];
    navbarShadow.frame = CGRectMake(0, 64, 320, 20);
    [UIView commitAnimations];
}

- (void)navbarShadowMode_searchbar
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.1];
    navbarShadow.frame = CGRectMake(0, 108, 320, 20);
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Tab bar shadow

- (void)hideTabbarShadowAnimated:(BOOL)animated
{
    if (tabbarShadow.alpha == 1.0) {
        tabbarShadow.alpha = 1.0;
        
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.2];
            tabbarShadow.alpha = 0.0;
            [UIView commitAnimations];
        } else {
            tabbarShadow.alpha = 0.0;
        }
    }
}

- (void)showTabbarShadowAnimated:(BOOL)animated
{
    if (tabbarShadow.alpha == 0.0) {
        tabbarShadow.alpha = 0.0;
        
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.2];
            tabbarShadow.alpha = 1.0;
            [UIView commitAnimations];
        } else {
            tabbarShadow.alpha = 1.0;
        }
    }
}

- (void)tabbarShadowMode_toolbar
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    tabbarShadow.frame = CGRectMake(0, screenHeight - 63, 320, 20);
    [UIView commitAnimations];
}

- (void)tabbarShadowMode_tabbar
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    tabbarShadow.frame = CGRectMake(0, screenHeight - 68, 320, 20);
    [UIView commitAnimations];
}

- (void)tabbarShadowMode_nobar
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    tabbarShadow.frame = CGRectMake(0, screenHeight - 20, 320, 20);
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Signup handler

- (void)signup
{
    signupViewNavigationController.view.alpha = 0.0;
    [mainTabBarController presentModalViewController:signupViewNavigationController animated:NO];
    
    [self hideLoginFields];
    [self openBoxWithConfiguration:@"signup"];
}

- (void)hideSignupView
{
    [signupViewNavigationController dismissModalViewControllerAnimated:NO];
}

- (void)signupPanelDidGetDismissed
{
    [signupViewNavigationController popToRootViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark Tip Explorer handler

- (void)explore
{
    [global writeValue:@"-111" forProperty:@"userid"]; // Gibberize this.
    
    tipExplorerNavigationController.view.alpha = 0.0;
    [mainTabBarController presentModalViewController:tipExplorerNavigationController animated:NO];
    
    mainTabBarController.tabBar.hidden = YES;
    
    [self hideLoginFields];
    [self openBoxWithConfiguration:@"explorer"];
}

- (void)hideTipExplorer
{
    [tipExplorerNavigationController dismissModalViewControllerAnimated:NO];
}

- (void)tipExplorerDidGetDismissed
{
    
}

- (void)goHome
{
    [boxAnimationTimer invalidate];
    boxAnimationTimer = nil;
    
    [mainTabBarController setSelectedIndex:0];
    
    // Load the feed and refresh user info.
    UINavigationController *defaultNavController_feed = [self.mainTabBarController.viewControllers objectAtIndex:0];
    UINavigationController *defaultNavController_profile = [self.mainTabBarController.viewControllers objectAtIndex:4];
    
    FeedViewController *feedView = (FeedViewController *)[defaultNavController_feed.viewControllers objectAtIndex:0];
    MeViewController *profileView = (MeViewController *)[defaultNavController_profile.viewControllers objectAtIndex:0];
    profileView.isCurrentUser = YES;
    
    [profileView getUserInfoForUsername:[global readProperty:@"username"]];
    [feedView downloadTimeline:@"getuserfeed" batch:0];
    
    [self hideSignupView];
    [self hideLoginBox];
    [self openBoxWithConfiguration:@"main"];
}

#pragma mark -
#pragma mark Login/Logout handlers

- (void)login
{
    if (field_username.text.length != 0 && field_passwd.text.length != 0) {
        [Sound soundEffect:0]; // Play the login sound.
        [field_username resignFirstResponder];
        [field_passwd resignFirstResponder];
        loginButton.enabled = NO;
        field_username.enabled = NO;
        field_username.hidden = YES;
        field_passwd.enabled = NO;
        field_passwd.hidden = YES;
        label_loginButton.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        label_loginButton.text = @"Checking...";
        
        // Remove whitespace.
        field_username.text = [field_username.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // Set the shadow copies.
        field_usernameShadowCopy.text = field_username.text;
        field_passwdShadowCopy.text = field_passwd.text;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3];
        usernameFieldCover.frame = CGRectMake(0, 0, 216, 38);
        passwdFieldCover.frame = CGRectMake(0, 0, 216, 38);
        [UIView commitAnimations];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/login", SH_DOMAIN]];
        dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
        [dataRequest setPostValue:field_username.text forKey:@"username"];
        [dataRequest setPostValue:field_passwd.text forKey:@"password"];
        [dataRequest setPostValue:[NSString stringWithFormat:@"%@", device_token] forKey:@"deviceToken"];
        [dataRequest setDelegate:self];
        activeConnectionIdentifier = @"login";
        [dataRequest startAsynchronous];
    } else if (field_username.text.length == 0) {
        [self explore];
    } else if (field_passwd.text.length == 0) {
        [field_passwd becomeFirstResponder];
    }
}

- (void)logout
{
    // If the feed is auto-refreshing, kill it.
    UINavigationController *defaultNavController_feed = [self.mainTabBarController.viewControllers objectAtIndex:0];
    FeedViewController *feedView = (FeedViewController *)[defaultNavController_feed.viewControllers objectAtIndex:0];
    [feedView.dataRequest cancel];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/logout", SH_DOMAIN]];
    dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest setPostValue:SHToken forKey:@"token"];
    [dataRequest setDelegate:self];
    activeConnectionIdentifier = @"logout";
    [dataRequest startAsynchronous];
    logoutMessage.hidden = YES;
}

- (void)logoutWithMessage:(NSString *)message
{
    if ([message isEqualToString:@"You need to log in before you can do that!"]) {
        logoutMessage.text = message;
        logoutMessage.hidden = NO;
        
        [mainTabBarController.tipExplorerView dismissTipExplorerForLogin];
        
        return;
    }
    
    [self logout];
    logoutMessage.text = message;
    logoutMessage.hidden = NO;
}

#pragma mark -
#pragma mark Reset password

- (void)resetPasswd
{
    if (field_passwdReset.text.length != 0) {
        label_passwdResetButton.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        passwdResetButton.enabled = NO;
        field_passwdReset.enabled = NO;
        [field_passwdReset resignFirstResponder];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/forgotpassword", SH_DOMAIN]];
        
        dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
        [dataRequest setPostValue:field_passwdReset.text forKey:@"email"];
        [dataRequest setCompletionBlock:^{
            NSError *jsonError;
            self.responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if ([[self.responseData objectForKey:@"error"] intValue] == 0) {
                label_cancelPasswdResetButton.text = @"Back";
                passwdResetButton.hidden = YES;
                passwdResetFieldBGImageView.hidden = YES;
                field_passwdReset.hidden = YES;
                passwdResetDescLabel.text = @"Alright! Now check your email!";
            }
        }];
        [dataRequest setFailedBlock:^{
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
            HUD.labelText = @"Could not connect!";
            HUD.mode = MBProgressHUDModeCustomView;
            
            [window bringSubviewToFront:HUD];
            HUD.layer.zPosition = 1;
            [HUD show:YES];
            [HUD hide:YES afterDelay:3];
            
            NSError *error = [dataRequest error];
            NSLog(@"\nERROR!\n======\n%@", error);
        }];
        [dataRequest startAsynchronous];
    } else if (field_username.text.length == 0) {
        [field_passwdReset becomeFirstResponder];
    }
}

#pragma mark -
#pragma mark Tip Publisher

- (void)postTip:(NSMutableDictionary *)tip
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/createtip", SH_DOMAIN]];
    dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest setPostValue:[tip objectForKey:@"token"] forKey:@"token"];
    [dataRequest setPostValue:[tip objectForKey:@"content"] forKey:@"content"];
    [dataRequest setPostValue:[tip objectForKey:@"topicid"] forKey:@"topicid"];
    [dataRequest setPostValue:[tip objectForKey:@"topicContent"] forKey:@"topicContent"];
    [dataRequest setPostValue:[tip objectForKey:@"catid"] forKey:@"catid"];
    [dataRequest setPostValue:[tip objectForKey:@"location_long"] forKey:@"location_long"];
    [dataRequest setPostValue:[tip objectForKey:@"location_lat"] forKey:@"location_lat"];
    [dataRequest setPostValue:[tip objectForKey:@"fbPost"] forKey:@"fbPost"];
    [dataRequest setPostValue:[tip objectForKey:@"twtPost"] forKey:@"twtPost"];
    
    [dataRequest setDelegate:self];
    activeConnectionIdentifier = @"createTip";
    [strobeLight activateStrobeLight];
    [dataRequest startAsynchronous];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Let the device know we want to receive push notifications.
    device_token = @"";
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)];
    
    [self getDeviceModel]; // Get the device model (iPhone, iPad 2, etc.)
    
    global = [[Global alloc] init];
    //[global writeValue:@"" forProperty:@"token"];
    SHToken = [global readProperty:@"token"];
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    // Set the usage count.
    if (![global readProperty:@"usageCount"] || [[global readProperty:@"usageCount"] isEqualToString:@""]) {
        [global writeValue:@"1" forProperty:@"usageCount"];
    } else {
        int usageCount = [[global readProperty:@"usageCount"] intValue];
        [global writeValue:[NSString stringWithFormat:@"%d", ++usageCount] forProperty:@"usageCount"];
    }
    
    // Add the tab bar controller's view to the window and display.
    NSArray *tabBarViewControllers = [NSArray arrayWithArray:self.mainTabBarController.viewControllers];
    
    // Notice we don't include the view controller under the green new tip button.
    [SCAppUtils customizeNavigationController:[tabBarViewControllers objectAtIndex:0]];
    [SCAppUtils customizeNavigationController:[tabBarViewControllers objectAtIndex:1]];
    [SCAppUtils customizeNavigationController:[tabBarViewControllers objectAtIndex:3]];
    [SCAppUtils customizeNavigationController:[tabBarViewControllers objectAtIndex:4]];
    
    // APP STATE SAVING CODE.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Check for a token.
    if (!SHToken || [SHToken isEqualToString:@""]) {
        [mainTabBarController setSelectedIndex:2];
    } else {
        mainTabBarController.selectedViewController = [mainTabBarController.viewControllers objectAtIndex:[defaults integerForKey:@"mainTabBarControllerSelectedIndex"]]; // Load last selected tab.
    }
    
    mainTabBarController.delegate = self;
    mainTabBarController.moreNavigationController.delegate = self;
    window.backgroundColor = [UIColor blackColor];
    [window setRootViewController:mainTabBarController];
    mainTabBarController.view.alpha = 0.0;
    [window makeKeyAndVisible];
    
    // Initialize Facebook.
    facebook = [[Facebook alloc] initWithAppId:FB_APP_ID andDelegate:nil];
    
    // Check and retrieve Facebook authorization information.
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        
        FBToken = [facebook.accessToken retain];
    }
    
    // Initialize Facebook user permissions.
    fbUserPermissions = [[NSArray alloc] initWithObjects:@"email", @"user_location", @"user_website", @"user_about_me", @"publish_stream", nil];
    
    SignupViewController *signupView = mainTabBarController.signupView;
    signupViewNavigationController = [[UINavigationController alloc] initWithRootViewController:signupView];
    signupView.delegate = self;
    
    TipExplorerViewController *tipExplorerView = mainTabBarController.tipExplorerView;
    tipExplorerNavigationController = [[UINavigationController alloc] initWithRootViewController:tipExplorerView];
    tipExplorerView.delegate = self;
    
    strobeLight = [[UIStrobeLight alloc] initWithFrame:CGRectMake(0, 54, 320, 20)];
    
    HUD = [[MBProgressHUD alloc] initWithWindow:window];
    HUD.delegate = self;
    
    navbarShadow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"nav_bar_shadow.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0]];
    navbarShadow.frame = CGRectMake(0, 64, 320, 20);
    
    tabbarShadow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tab_bar_shadow.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0]];
    tabbarShadow.frame = CGRectMake(0, screenHeight - 68, 320, 20);
    
    if ([currentDeviceModel isEqualToString:@"iPhone5,1"]) {
        boxCoverUpper = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover_upper_half_568h.png"]];
        boxCoverLower = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover_lower_half_568h.png"]];
        boxCoverUpper.frame = CGRectMake(0, 0, 320, 296);
        boxCoverLower.frame = CGRectMake(0, 296, 320, 272);
    } else {
        boxCoverUpper = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover_upper_half.png"]];
        boxCoverLower = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover_lower_half.png"]];
        boxCoverUpper.frame = CGRectMake(0, 0, 320, 250);
        boxCoverLower.frame = CGRectMake(0, 250, 320, 230);
    }
    
    boxCoverUpper.userInteractionEnabled = YES;
    boxCoverLower.userInteractionEnabled = YES;
    
    loginBox = [[UIView alloc] initWithFrame:CGRectMake(-252, (screenHeight / 2) - 70, 251, 164)];
    loginBox.clipsToBounds = NO;
    loginBox.hidden = YES;
    UIImageView *loginBoxCover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_box.png"]];
    loginBoxCover.frame = CGRectMake(0, 0, 251, 164);
    
    loginBoxBack = [[UIView alloc] initWithFrame:CGRectMake(33, (screenHeight / 2) - 70, 251, 164)];
    loginBoxBack.clipsToBounds = NO;
    loginBoxBack.hidden = YES;
    UIImageView *loginBoxBackCover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_box_back.png"]];
    loginBoxBackCover.frame = CGRectMake(0, 0, 251, 164);
    
    loginBoxShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_box_shadow.png"]];
    loginBoxShadow.hidden = YES;
    loginBoxShadow.frame = CGRectMake(-252, (screenHeight / 2) - 70, 251, 164);
    
    UIImage *frontsideButtonBGImage = [[UIImage imageNamed:@"login_box_join_button.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    UIImage *frontsideButtonPressedBGImage = [[UIImage imageNamed:@"login_box_join_button_pressed.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinButton setBackgroundImage:frontsideButtonBGImage forState:UIControlStateNormal];
    [joinButton setBackgroundImage:frontsideButtonPressedBGImage forState:UIControlStateHighlighted];
    [joinButton addTarget:self action:@selector(signup) forControlEvents:UIControlEventTouchUpInside];
    joinButton.frame = CGRectMake(20, 20, 70, 30);
    
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setBackgroundImage:frontsideButtonBGImage forState:UIControlStateNormal];
    [loginButton setBackgroundImage:frontsideButtonPressedBGImage forState:UIControlStateHighlighted];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    loginButton.frame = CGRectMake(161, 20, 70, 30);
    
    UILabel *joinButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    joinButtonLabel.backgroundColor = [UIColor clearColor];
    joinButtonLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    joinButtonLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    joinButtonLabel.shadowOffset = CGSizeMake(0, -1);
    joinButtonLabel.numberOfLines = 1;
    joinButtonLabel.minimumFontSize = 8.;
    joinButtonLabel.adjustsFontSizeToFitWidth = YES;
    joinButtonLabel.textAlignment = UITextAlignmentCenter;
    joinButtonLabel.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
    joinButtonLabel.text = @"Join";
    
    label_loginButton = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 55, 30)]; // Frame accounts for padding 'cuz of dynamic text.
    label_loginButton.backgroundColor = [UIColor clearColor];
    label_loginButton.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    label_loginButton.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    label_loginButton.shadowOffset = CGSizeMake(0, -1);
    label_loginButton.numberOfLines = 1;
    label_loginButton.minimumFontSize = 8.;
    label_loginButton.adjustsFontSizeToFitWidth = YES;
    label_loginButton.textAlignment = UITextAlignmentCenter;
    label_loginButton.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
    label_loginButton.text = @"Login";
    
    forgotPasswdButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    forgotPasswdButton.backgroundColor = [UIColor clearColor];
    [forgotPasswdButton addTarget:self action:@selector(flipBackLoginBox) forControlEvents:UIControlEventTouchUpInside];
    forgotPasswdButton.frame = CGRectMake(206, 108, 26, 26);
    forgotPasswdButton.hidden = YES;
    
    UIImage *backsideButtonBGImage = [[UIImage imageNamed:@"login_box_join_button.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    UIImage *backsideButtonPressedBGImage = [[UIImage imageNamed:@"login_box_join_button_pressed.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    cancelPasswdResetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelPasswdResetButton setBackgroundImage:backsideButtonBGImage forState:UIControlStateNormal];
    [cancelPasswdResetButton setBackgroundImage:backsideButtonPressedBGImage forState:UIControlStateHighlighted];
    [cancelPasswdResetButton addTarget:self action:@selector(flipFrontLoginBox) forControlEvents:UIControlEventTouchUpInside];
    cancelPasswdResetButton.frame = CGRectMake(20, 20, 70, 30);
    
    passwdResetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [passwdResetButton setBackgroundImage:backsideButtonBGImage forState:UIControlStateNormal];
    [passwdResetButton setBackgroundImage:backsideButtonPressedBGImage forState:UIControlStateHighlighted];
    [passwdResetButton addTarget:self action:@selector(resetPasswd) forControlEvents:UIControlEventTouchUpInside];
    passwdResetButton.frame = CGRectMake(161, 20, 70, 30);
    
    label_cancelPasswdResetButton = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    label_cancelPasswdResetButton.backgroundColor = [UIColor clearColor];
    label_cancelPasswdResetButton.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    label_cancelPasswdResetButton.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    label_cancelPasswdResetButton.shadowOffset = CGSizeMake(0, -1);
    label_cancelPasswdResetButton.textAlignment = UITextAlignmentCenter;
    label_cancelPasswdResetButton.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
    label_cancelPasswdResetButton.text = @"Cancel";
    
    label_passwdResetButton = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    label_passwdResetButton.backgroundColor = [UIColor clearColor];
    label_passwdResetButton.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    label_passwdResetButton.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    label_passwdResetButton.shadowOffset = CGSizeMake(0, -1);
    label_passwdResetButton.textAlignment = UITextAlignmentCenter;
    label_passwdResetButton.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
    label_passwdResetButton.text = @"Reset";
    
    UIImage *usernameFieldBGImage = [[UIImage imageNamed:@"box_login_field.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    UIImage *usernameFieldCoverImage = [UIImage imageNamed:@"box_login_field_backside_1.png"];
    UIImage *passwdFieldBGImage = [[UIImage imageNamed:@"box_login_field.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    UIImage *passwdFieldCoverImage = [UIImage imageNamed:@"box_login_field_backside_2.png"];
    UIImage *passwdResetFieldBGImage = [[UIImage imageNamed:@"box_login_field.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    
    usernameFieldBGImageView = [[UIImageView alloc] initWithImage:usernameFieldBGImage];
    usernameFieldBGImageView.frame = CGRectMake(20, 65, 214, 31);
    usernameFieldBGImageView.clipsToBounds = YES;
    
    usernameFieldCover = [[UIImageView alloc] initWithImage:usernameFieldCoverImage];
    usernameFieldCover.frame = CGRectMake(0, -39, 216, 38);
    
    passwdFieldBGImageView = [[UIImageView alloc] initWithImage:passwdFieldBGImage];
    passwdFieldBGImageView.frame = CGRectMake(20, 105, 214, 31);
    passwdFieldBGImageView.clipsToBounds = YES;
    
    passwdFieldCover = [[UIImageView alloc] initWithImage:passwdFieldCoverImage];
    passwdFieldCover.frame = CGRectMake(0, -39, 216, 38);
    
    passwdResetFieldBGImageView = [[UIImageView alloc] initWithImage:passwdResetFieldBGImage]; // This is an ivar 'cuz we need to access it elsewhere.
    passwdResetFieldBGImageView.frame = CGRectMake(20, 105, 214, 31);
    
    field_username = [[UITextField alloc] initWithFrame:CGRectMake(25, 70, 209, 26)];
    field_username.tag = 1;
    field_username.borderStyle = UITextBorderStyleNone;
    field_username.placeholder = @"Username";
    field_username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field_username.keyboardType = UIKeyboardTypeEmailAddress;
    field_username.returnKeyType = UIReturnKeyNext;
    field_username.delegate = self;
    
    field_passwd = [[UITextField alloc] initWithFrame:CGRectMake(25, 110, 185, 26)]; // This field is narrower so that it doesn't go under the i button!
    field_passwd.tag = 2;
    field_passwd.borderStyle = UITextBorderStyleNone;
    field_passwd.placeholder = @"Password";
    field_passwd.secureTextEntry = YES;
    field_passwd.returnKeyType = UIReturnKeyDone;
    field_passwd.delegate = self;
    
    field_passwdReset = [[UITextField alloc] initWithFrame:CGRectMake(25, 110, 209, 26)];
    field_passwdReset.tag = 3;
    field_passwdReset.borderStyle = UITextBorderStyleNone;
    field_passwdReset.placeholder = @"Email";
    field_passwdReset.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field_passwdReset.keyboardType = UIKeyboardTypeEmailAddress;
    field_passwdReset.returnKeyType = UIReturnKeyDone;
    field_passwdReset.delegate = self;
    field_passwdReset.enabled = NO;
    
    passwdResetDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 65, 209, 26)];
    passwdResetDescLabel.backgroundColor = [UIColor clearColor];
    passwdResetDescLabel.textColor = [UIColor whiteColor];
    passwdResetDescLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    passwdResetDescLabel.shadowOffset = CGSizeMake(0, -1);
    passwdResetDescLabel.numberOfLines = 0;
    passwdResetDescLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_SECONDARY_FONT_SIZE];
    passwdResetDescLabel.text = @"Forgot your password? Enter your email and we'll help you reset it.";
    
    logoutMessage = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 280, 26)];
    logoutMessage.backgroundColor = [UIColor clearColor];
    logoutMessage.textColor = [UIColor whiteColor];
    logoutMessage.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    logoutMessage.shadowOffset = CGSizeMake(0, -1);
    logoutMessage.numberOfLines = 0;
    logoutMessage.textAlignment = UITextAlignmentCenter;
    logoutMessage.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:SECONDARY_FONT_SIZE];
    logoutMessage.hidden = YES;
    
    // These copies appear under the wooden covers that slide over the fields.
    field_usernameShadowCopy = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, 209, 26)];
    field_usernameShadowCopy.borderStyle = UITextBorderStyleNone;
    field_usernameShadowCopy.enabled = NO;
    
    field_passwdShadowCopy = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, 209, 26)];
    field_passwdShadowCopy.borderStyle = UITextBorderStyleNone;
    field_passwdShadowCopy.secureTextEntry = YES;
    field_passwdShadowCopy.enabled = NO;
    
    // Listen for keyboard hide/show notifications so we can properly adjust the cover's position.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [joinButton addSubview:joinButtonLabel];
    [loginButton addSubview:label_loginButton];
    [cancelPasswdResetButton addSubview:label_cancelPasswdResetButton];
    [passwdResetButton addSubview:label_passwdResetButton];
    [usernameFieldBGImageView addSubview:field_usernameShadowCopy];
    [usernameFieldBGImageView addSubview:usernameFieldCover];
    [passwdFieldBGImageView addSubview:field_passwdShadowCopy];
    [passwdFieldBGImageView addSubview:passwdFieldCover];
    [loginBoxBack addSubview:loginBoxBackCover];
    [loginBoxBack addSubview:cancelPasswdResetButton];
    [loginBoxBack addSubview:passwdResetButton];
    [loginBoxBack addSubview:passwdResetFieldBGImageView];
    [loginBoxBack addSubview:field_passwdReset];
    [loginBoxBack addSubview:passwdResetDescLabel];
    [loginBox addSubview:loginBoxCover];
    [loginBox addSubview:joinButton];
    [loginBox addSubview:loginButton];
    [loginBox addSubview:usernameFieldBGImageView];
    [loginBox addSubview:passwdFieldBGImageView];
    [loginBox addSubview:field_username];
    [loginBox addSubview:field_passwd];
    [loginBox addSubview:forgotPasswdButton];
    [window addSubview:navbarShadow];
    [window addSubview:tabbarShadow];
    [window addSubview:strobeLight];
    [window addSubview:boxCoverUpper];
    [window addSubview:boxCoverLower];
    [window addSubview:loginBoxShadow];
    [window addSubview:loginBoxBack];
    [window addSubview:loginBox];
    [boxCoverUpper addSubview:logoutMessage];
    [window addSubview:HUD];
    [window bringSubviewToFront:loginBox];
    
    // * =================== *
    // * Poke the server to: *
    // * =================== *
    // # Extend the FB token.
    // # See if a critical update is needed.
    NSURL *url_pokeServer = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/pokeserver", SH_DOMAIN]];
    
    dataRequest = [[ASIFormDataRequest requestWithURL:url_pokeServer] retain];
    [dataRequest setPostValue:SHToken forKey:@"token"];
    [dataRequest setPostValue:[NSString stringWithFormat:@"%@", device_token] forKey:@"deviceToken"];
    [dataRequest setPostValue:APP_VERSION forKey:@"appVer"];
    [dataRequest setCompletionBlock:^{
        NSError *jsonError;
        self.responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[self.responseData objectForKey:@"error"] intValue] == 0) {
            NSDictionary *responce = [self.responseData objectForKey:@"responce"];
            SHAppid = [responce objectForKey:@"appid"];
            BOOL criticalUpdateNeeded = [[responce objectForKey:@"critUp"] boolValue];
            NSString *criticalMessage = [responce objectForKey:@"critMsg"];
            
            if ([[global readProperty:@"usageCount"] intValue] == 5) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Rate Tipbox!"
                                      message:@"So what do you think of Tipbox? We would really appreciate it if you rated it! :)" delegate:self
                                      cancelButtonTitle:@"No, Thanks!"
                                      otherButtonTitles:@"Rate", nil];
                alert.tag = 0;
                [alert show];
                [alert release];
            }
            
            if (criticalUpdateNeeded) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"App Update Needed!"
                                      message:@"Some features might not work properly anymore until you update Tipbox. Launch the App Store and go to the Updates tab." delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                alert.tag = 1;
                [alert show];
                [alert release];
            }
            
            if (![criticalMessage isEqualToString:@"false"] && criticalMessage.length > 1) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Message from Scapehouse HQ"
                                      message:criticalMessage delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                alert.tag = 2;
                [alert show];
                [alert release];
            }
        }
    }];
    [dataRequest setFailedBlock:^{
        NSError *error = [dataRequest error];
        NSLog(@"\nERROR!\n======\n%@", error);
    }];
    [dataRequest startAsynchronous];
    
    // Check for a token.
    if (!SHToken || [SHToken isEqualToString:@""]) {
        [global writeValue:@"-1" forProperty:@"userid"];
        [self explore];
    } else {
        // Auto-refresh the Feed view if the app launched after the set time interval.
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm"];
        
        lastRefreshedDate = [dateFormatter dateFromString:[global readProperty:@"lastRefreshedDate"]];
        
        NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *calendarComponents = [calendar components:NSMinuteCalendarUnit
                                                           fromDate:lastRefreshedDate
                                                             toDate:[NSDate date]
                                                            options:0];
        
        if (calendarComponents.minute >= AUTOREFRESH_THRESHOLD && mainTabBarController.selectedIndex != 0) {
            UINavigationController *defaultNavController_feed = [self.mainTabBarController.viewControllers objectAtIndex:0];
            FeedViewController *feedView = (FeedViewController *)[defaultNavController_feed.viewControllers objectAtIndex:0];
            [feedView downloadTimeline:@"getuserfeed" batch:0];
        }
        
        [self openBoxWithConfiguration:@"main"]; // Open le box.
    }
    
    [Flurry startSession:@"VPSKQSRJZXTHBTDRRY7V"]; // Start analytics.
    
    // Handle notifications.
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (remoteNotif) {
        
        NSDictionary *notifData = [[remoteNotif objectForKey:@"aps"] objectForKey:@"supdata"];
        UINavigationController *defaultNavController_profile = [self.mainTabBarController.viewControllers objectAtIndex:4];
       
        mainTabBarController.selectedViewController = [mainTabBarController.viewControllers objectAtIndex:4];
        [defaultNavController_profile popToRootViewControllerAnimated:NO];
        
        if ([[notifData objectForKey:@"type"] isEqualToString:@"tip"]) {
            TipViewController *notifSheetView = [[TipViewController alloc] init];
            notifSheetView.tipid = [[notifData objectForKey:@"id"] intValue];
            notifSheetView.fetchesOwnData = YES;
            
            [defaultNavController_profile pushViewController:notifSheetView animated:YES];
            [notifSheetView release];
        } else if ([[notifData objectForKey:@"type"] isEqualToString:@"topic"]) {
            TopicViewController *notifSheetView = [[TopicViewController alloc] init];
            notifSheetView.viewTopicid = [[notifData objectForKey:@"id"] intValue];
            
            [defaultNavController_profile pushViewController:notifSheetView animated:YES];
            [notifSheetView release];
        }
    }
    
    [loginBoxBackCover release];
    [loginBoxCover release];
    [joinButtonLabel release];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Reset the app notification badge count.
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        NSURL *url_pokeServer = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/resetbadgecount", SH_DOMAIN]];
        
        dataRequest = [[ASIFormDataRequest requestWithURL:url_pokeServer] retain];
        [dataRequest setPostValue:SHToken forKey:@"token"];
        [dataRequest setCompletionBlock:^{
            NSError *jsonError;
            self.responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if ([[self.responseData objectForKey:@"error"] intValue] == 0) {
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            }
        }];
        [dataRequest setFailedBlock:^{
            NSError *error = [dataRequest error];
            NSLog(@"\nERROR!\n======\n%@", error);
        }];
        [dataRequest startAsynchronous];
    }
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self.facebook extendAccessTokenIfNeeded];
    [FBSession.activeSession handleDidBecomeActive];
    
    // Auto-refresh the Feed view after the set time interval.
    if (!SHToken || [SHToken isEqualToString:@""]) {
        // Don't do anything.
    } else {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm"];
        
        lastRefreshedDate = [dateFormatter dateFromString:[global readProperty:@"lastRefreshedDate"]];
        
        NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *calendarComponents = [calendar components:NSMinuteCalendarUnit
                                                           fromDate:lastRefreshedDate
                                                             toDate:[NSDate date]
                                                            options:0];
        
        if (calendarComponents.minute >= AUTOREFRESH_THRESHOLD) {
            UINavigationController *defaultNavController_feed = [self.mainTabBarController.viewControllers objectAtIndex:0];
            FeedViewController *feedView = (FeedViewController *)[defaultNavController_feed.viewControllers objectAtIndex:0];
            [feedView downloadTimeline:@"getuserfeed" batch:0];
        }
    }
}


- (void)applicationWillTerminate:(UIApplication *)application
{
	NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle the error.
        } 
    }
    
    // Save app state.
    [[NSUserDefaults standardUserDefaults] synchronize];
    [FBSession.activeSession close];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

#pragma mark Push notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    device_token = [[NSString stringWithFormat:@"%@", deviceToken] retain];
    device_token = [[device_token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] retain];
    device_token = [[device_token stringByReplacingOccurrencesOfString:@" " withString:@""] retain];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	//NSLog(@"Failed to get device token, error: %@", error);
    device_token = @"";
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (userInfo) {
        if (application.applicationState == UIApplicationStateActive) { // App was already in the foreground.
            
        } else { // App was just brought from background to foreground.
            NSDictionary *notifData = [[userInfo objectForKey:@"aps"] objectForKey:@"supdata"];
            UINavigationController *defaultNavController_profile = [self.mainTabBarController.viewControllers objectAtIndex:4];
            
            mainTabBarController.selectedViewController = [mainTabBarController.viewControllers objectAtIndex:4];
            [defaultNavController_profile popToRootViewControllerAnimated:NO];
            
            if ([[notifData objectForKey:@"type"] isEqualToString:@"tip"]) {
                TipViewController *notifSheetView = [[TipViewController alloc] init];
                notifSheetView.tipid = [[notifData objectForKey:@"id"] intValue];
                notifSheetView.fetchesOwnData = YES;
                
                [defaultNavController_profile pushViewController:notifSheetView animated:YES];
                [notifSheetView release];
            } else if ([[notifData objectForKey:@"type"] isEqualToString:@"topic"]) {
                TopicViewController *notifSheetView = [[TopicViewController alloc] init];
                notifSheetView.viewTopicid = [[notifData objectForKey:@"id"] intValue];
                
                [defaultNavController_profile pushViewController:notifSheetView animated:YES];
                [notifSheetView release];
            }
        }
    }
}

#pragma mark -
#pragma mark Getting device model

- (void)getDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    currentDeviceModel = [[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding] retain];
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setInteger:mainTabBarController.selectedIndex forKey:@"mainTabBarControllerSelectedIndex"];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setInteger:mainTabBarController.selectedIndex forKey:@"mainTabBarControllerSelectedIndex"];
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [[NSUserDefaults standardUserDefaults] setInteger:tabBarController.selectedIndex forKey:@"mainTabBarControllerSelectedIndex"];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1) {
        [field_passwd becomeFirstResponder];
        return NO;
    } else {
        [field_passwdReset resignFirstResponder];
        [field_passwd resignFirstResponder];
        
        if (field_username.text.length > 0 && field_passwd.text.length > 0) {
            [self login];
        }
        
        return YES;
    }
}

- (void)keyboardWillShow:(NSNotification *)aNotification 
{
    forgotPasswdButton.hidden = NO;
    keyboardIsShown = YES;
    [self setViewMovedUp:YES];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    forgotPasswdButton.hidden = YES;
    keyboardIsShown = NO;
    [self setViewMovedUp:NO];
}

// Method to move the view up/down whenever the keyboard is shown/dismissed.
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    if (movedUp) {
        if ([currentDeviceModel isEqualToString:@"iPhone5,1"]) {
            // iPhone 5, no need to move anything up.
        } else {
            boxCoverUpper.frame = CGRectMake(0, -30, 320, 250);
            boxCoverLower.frame = CGRectMake(0, 220, 320, 230);
            loginBox.frame = CGRectMake(33, 125, 251, 164);
            loginBoxBack.frame = CGRectMake(33, 125, 251, 164);
        }
    } else { // Revert back to the normal state.
        if ([currentDeviceModel isEqualToString:@"iPhone5,1"]) {
            // iPhone 5, no need to revert anything.
        } else {
            boxCoverUpper.frame = CGRectMake(0, 0, 320, 250);
            boxCoverLower.frame = CGRectMake(0, 250, 320, 230);
            loginBox.frame = CGRectMake(33, 155, 251, 164);
            loginBoxBack.frame = CGRectMake(33, 155, 251, 164);
        }
    }
    
    [UIView commitAnimations];
}

#pragma ASIFormDataRequestDelegate methods
- (void)requestFinished:(ASIFormDataRequest *)request
{
    NSError *jsonError;
    self.responseData = [NSJSONSerialization JSONObjectWithData:[request.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
    
    if ([activeConnectionIdentifier isEqualToString:@"login"]) { // Login.
        
        // Reset login items.
        loginButton.enabled = YES;
        label_loginButton.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        label_loginButton.text = @"Login";
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            usernameFieldCover.frame = CGRectMake(0, -39, 216, 38);
            passwdFieldCover.frame = CGRectMake(0, -39, 216, 38);
        } completion:^(BOOL finished){
            field_username.enabled = YES;
            field_username.hidden = NO;
            field_passwd.enabled = YES;
            field_passwd.hidden = NO;
            
            field_usernameShadowCopy.text = @"";
            field_passwdShadowCopy.text = @"";
            field_passwd.text = @"";
        }];
        
        if ([[self.responseData objectForKey:@"error"] intValue] == 0) {
            NSDictionary *responce = [self.responseData objectForKey:@"responce"];
            NSDictionary *userData = [responce objectForKey:@"userData"];
            
            int currentUserid = [[[userData objectForKey:@"id"] retain] intValue];
            NSString *currentName = [[userData objectForKey:@"fullname"] retain];
            NSString *currentUsername = [[userData objectForKey:@"username"] retain];
            NSString *currentEmail = [[userData objectForKey:@"email"] retain];
            NSString *currentHash = [[userData objectForKey:@"pichash"] retain];
            BOOL fbConnected = [[[userData objectForKey:@"fbConnected"] retain] boolValue];
            BOOL twtConnected = [[[userData objectForKey:@"twtConnected"] retain] boolValue];
            
            // Store the generated token and user data.
            [global writeValue:[responce objectForKey:@"shToken"] forProperty:@"token"];
            [global writeValue:[NSString stringWithFormat:@"%d", currentUserid] forProperty:@"userid"];
            [global writeValue:currentName forProperty:@"name"];
            [global writeValue:currentUsername forProperty:@"username"];
            [global writeValue:currentEmail forProperty:@"email"];
            [global writeValue:currentHash forProperty:@"userPicHash"];
            [global writeValue:[NSString stringWithFormat:@"%@", fbConnected ? @"YES":@"NO"] forProperty:@"fbConnected"];
            [global writeValue:[NSString stringWithFormat:@"%@", twtConnected ? @"YES":@"NO"] forProperty:@"twitterConnected"];
            
            // Refresh the variables.
            SHToken = [global readProperty:@"token"];
            FBToken = [[[self.responseData objectForKey:@"responce"] objectForKey:@"fbToken"] retain];
            
            if (![[NSNull null] isEqual:FBToken]) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:FBToken forKey:@"FBAccessTokenKey"];
                [defaults synchronize];
            }
            
            [mainTabBarController setSelectedIndex:0];
            [self hideLoginFields];
            SEL selector = @selector(openBoxWithConfiguration:);
            
            NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setSelector:selector];
            
            NSString *arg1 = @"main";
            
            // The invocation object must retain its arguments.
            [arg1 retain];
            
            // Set the arguments.
            [invocation setTarget:self];
            [invocation setArgument:&arg1 atIndex:2];
            
            [NSTimer scheduledTimerWithTimeInterval:0.2 invocation:invocation repeats:NO];
            
            // Load the feed.
            UINavigationController *defaultNavController_feed = [self.mainTabBarController.viewControllers objectAtIndex:0];
            
            FeedViewController *feedView = (FeedViewController *)[defaultNavController_feed.viewControllers objectAtIndex:0];
            [feedView downloadTimeline:@"getuserfeed" batch:0];
            
            [currentName release];
            [currentUsername release];
            [currentEmail release];
            [currentHash release];
        } else {
            NSString *errorMsg = [self.responseData objectForKey:@"errormsg"];
            
            if ([errorMsg isEqualToString:@"loginFail"]) {
                HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
                HUD.labelText = @"Incorrect Username/Password!";
                HUD.mode = MBProgressHUDModeCustomView;
                
                [window bringSubviewToFront:HUD];
                HUD.layer.zPosition = 1;
                [HUD show:YES];
                [HUD hide:YES afterDelay:3];
                
                [field_passwd becomeFirstResponder];
            } else {
                HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
                HUD.labelText = @"Some error occured! :(";
                HUD.mode = MBProgressHUDModeCustomView;
                
                [window bringSubviewToFront:HUD];
                HUD.layer.zPosition = 1;
                [HUD show:YES];
                [HUD hide:YES afterDelay:3];
                
                [field_passwd becomeFirstResponder];
            }
        }
    } else if ([activeConnectionIdentifier isEqualToString:@"logout"]) { // Logout.
        if ([[self.responseData objectForKey:@"error"] intValue] == 0) {
            [global clearAll]; // Clear this out.
            [facebook logout];
            SHToken = [global readProperty:@"token"]; // This ivar needs refreshing!
            
            [self closeBoxWithConfiguration:@"main"];
            
            // Clear out all feeds.
            UINavigationController *defaultNavController_feed = [self.mainTabBarController.viewControllers objectAtIndex:0];
            UINavigationController *defaultNavController_tipExplorer = [self.mainTabBarController.viewControllers objectAtIndex:1];
            UINavigationController *defaultNavController_profile = [self.mainTabBarController.viewControllers objectAtIndex:4];
            
            FeedViewController *feedView = (FeedViewController *)[defaultNavController_feed.viewControllers objectAtIndex:0];
            TipExplorerViewController *tipExplorerView = (TipExplorerViewController *)[defaultNavController_tipExplorer.viewControllers objectAtIndex:0];
            MeViewController *profileView = (MeViewController *)[defaultNavController_profile.viewControllers objectAtIndex:0];
            profileView.isCurrentUser = YES;
            
            [feedView.feedEntries removeAllObjects];
            [feedView.timelineFeed reloadData];
            
            [tipExplorerView.feedEntries_hot removeAllObjects];
            [tipExplorerView.feedEntries_recent removeAllObjects];
            [tipExplorerView.timelineFeed reloadData];
            
            [profileView.feedEntries removeAllObjects];
            [profileView.timelineFeed reloadData];
            [profileView redrawContents];
        }
    } else if ([activeConnectionIdentifier isEqualToString:@"createTip"]) { // Tip creation.
        if ([[self.responseData objectForKey:@"error"] intValue] == 0) {
            UINavigationController *defaultNavController_profile = [self.mainTabBarController.viewControllers objectAtIndex:4];
            MeViewController *profileView = (MeViewController *)[defaultNavController_profile.viewControllers objectAtIndex:0];
            profileView.isCurrentUser = YES;
            profileView.freshTip = YES;
            
            mainTabBarController.selectedViewController = [mainTabBarController.viewControllers objectAtIndex:4];
            [defaultNavController_profile popToRootViewControllerAnimated:YES];
            
            [profileView getUserInfoForUsername:[global readProperty:@"username"]];
        } else {
            NSLog(@"Could not post tip!\nError:\n%@", request.responseString);
            [strobeLight negativeStrobeLight];
            
            if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self logout];
            }
        }
    }
    
    activeConnectionIdentifier = @""; // Clear this out.
}

- (void)requestFailed:(ASIHTTPRequest *)request
{	
	HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
    HUD.labelText = @"Could not connect!";
    HUD.mode = MBProgressHUDModeCustomView;
	
    [window bringSubviewToFront:HUD];
    HUD.layer.zPosition = 1;
    [HUD show:YES];
	[HUD hide:YES afterDelay:3];
    
    if ([activeConnectionIdentifier isEqualToString:@"login"]) { // Login.
        
        // Reset login items.
        loginButton.enabled = YES;
        label_loginButton.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        label_loginButton.text = @"Login";
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            usernameFieldCover.frame = CGRectMake(0, -39, 216, 38);
            passwdFieldCover.frame = CGRectMake(0, -39, 216, 38);
        } completion:^(BOOL finished){
            field_username.enabled = YES;
            field_username.hidden = NO;
            field_passwd.enabled = YES;
            field_passwd.hidden = NO;
            
            field_usernameShadowCopy.text = @"";
            field_passwdShadowCopy.text = @"";
            field_passwd.text =@"";
        }];
    } else if ([activeConnectionIdentifier isEqualToString:@"createTip"]) { // Tip creation.
        
    }
    
    [strobeLight negativeStrobeLight];
    activeConnectionIdentifier = @""; // Clear this out.
}

#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (void)saveAction
{
    NSError *error;
    
    if (![[self managedObjectContext] save:&error]) {
		// Handle error.
    }
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Tipbox.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle the error.
    }
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory
{	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

#pragma UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) { // Rate app
        if (buttonIndex == 1) { 
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8", SHAppid]];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
    [global release];
    [currentDeviceModel release];
    [mainTabBarController release];
    [publisherNavigationController release];
    [signupViewNavigationController release];
    [tipExplorerNavigationController release];
    [strobeLight release];
    [navbarShadow release];
    [boxCoverUpper release];
    [boxCoverLower release];
    [loginBox release];
    [loginBoxBack release];
    [label_loginButton release];
    [label_cancelPasswdResetButton release];
    [label_passwdResetButton release];
    [field_username release];
    [field_passwd release];
    [field_passwdReset release];
    [field_usernameShadowCopy release];
    [field_passwdShadowCopy release];
    [usernameFieldBGImageView release];
    [usernameFieldCover release];
    [passwdFieldCover release];
    [passwdFieldBGImageView release];
    [passwdResetFieldBGImageView release];
    [passwdResetDescLabel release];
    [logoutMessage release];
    [device_token release];
    [facebook release];
    [FBToken release];
    [fbUserPermissions release];
    [window release];
    [super dealloc];
}

@end

