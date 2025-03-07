#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import "SocialConnectionsManager.h"
#import "TipboxAppDelegate.h"
#import "EGOImageView.h"
#import "TWSignedRequest.h"
#import "OAuth+Additions.h"

#define TW_X_AUTH_MODE_KEY                  @"x_auth_mode"
#define TW_X_AUTH_MODE_REVERSE_AUTH         @"reverse_auth"
#define TW_X_AUTH_MODE_CLIENT_AUTH          @"client_auth"
#define TW_X_AUTH_REVERSE_PARMS             @"x_reverse_auth_parameters"
#define TW_X_AUTH_REVERSE_TARGET            @"x_reverse_auth_target"
#define TW_X_AUTH_USERNAME                  @"x_auth_username"
#define TW_X_AUTH_PASSWORD                  @"x_auth_password"
#define TW_SCREEN_NAME                      @"screen_name"
#define TW_USER_ID                          @"user_id"
#define TW_OAUTH_URL_REQUEST_TOKEN          @"https://api.twitter.com/oauth/request_token"
#define TW_OAUTH_URL_AUTH_TOKEN             @"https://api.twitter.com/oauth/access_token"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation SocialConnectionsManager

@synthesize dataRequest, responseData;

#pragma mark setTitle override
- (void)setTitle:(NSString *)title
{
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        titleView.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        titleView.shadowOffset = CGSizeMake(0, 1);
        
        titleView.textColor = [UIColor colorWithRed:49.0/255.0 green:49.0/255.0 blue:49.0/255.0 alpha:1.0]; // Change to desired color.
        
        self.navigationItem.titleView = titleView;
        [titleView release];
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	// Remove HUD from screen when the HUD was hidden.
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}

- (void)showConnectionError
{	
	HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
	
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
	HUD.dimBackground = YES;
    HUD.delegate = self;
    HUD.labelText = @"Could not connect!";
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight negativeStrobeLight];
	
    [HUD show:YES];
	[HUD hide:YES afterDelay:3];
}

- (void)renewFBToken:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    // Lock the buttons.
    fbButton.enabled = NO;
    fbButtonLabel.text = @"Connecting...";
    twitterButton.enabled = NO;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // Show the network activity indicator.
    
    if (button.tag == 1) {          // Facebook
        if (![appDelegate.facebook isSessionValid]) {
            //[appDelegate.facebook authorize:fbUserPermissions];
            [self openSessionWithAllowLoginUI:YES];
        } else {
            [appDelegate.facebook requestWithGraphPath:@"me" andDelegate:self];
        }
    }
}

- (void)renewTWToken:(id)sender
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // Show the network activity indicator.
    
    // Lock the buttons.
    twitterButton.enabled = NO;
    twitterButtonLabel.text = @"Connecting...";
    fbButton.enabled = NO;
    
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    //  Request access from the user for access to his Twitter accounts
    [store requestAccessToAccountsWithType:twitterAccountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if (!granted) {
            // The user rejected your request
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error!"
                                  message:@"You need to allow Tipbox access to your Twitter accounts. Go to the Settings app." delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            // Unlock the buttons.
            fbButton.enabled = YES;
            twitterButton.enabled = YES;
            [appDelegate.strobeLight deactivateStrobeLight];
        } else {
            // Grab the available accounts
            NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
            
            if ([twitterAccounts count] == 1) {
                // Use the first account.
                ACAccount *account = [twitterAccounts objectAtIndex:0];
                [self initiateTwitterSignupForAccount:account];
            } else {
                // This loop will lag like shit if it's not executed on the main thread!
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIActionSheet *accountList = [[UIActionSheet alloc]
                                                  initWithTitle:@"Twitter Accounts"
                                                  delegate:self
                                                  cancelButtonTitle:nil
                                                  destructiveButtonTitle:nil
                                                  otherButtonTitles:nil];
                    
                    for (int i = 0; i < [twitterAccounts count]; i++) {
                        ACAccount *twitterAccount = [twitterAccounts objectAtIndex:i];
                        [accountList addButtonWithTitle:[NSString stringWithFormat:@"@%@", twitterAccount.username]];
                    }
                    
                    [accountList addButtonWithTitle:@"Cancel"];
                    accountList.cancelButtonIndex = [twitterAccounts count];
                    accountList.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                    accountList.tag = 100;
                    [accountList showFromTabBar:appDelegate.mainTabBarController.tabBar];
                    [accountList release];
                });
            }
        }
    }];
    
    
}

#define RESPONSE_EXPECTED_SIZE 4
- (void)initiateTwitterSignupForAccount:(ACAccount *)account
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    twitterUsername = account.username;
    
    NSURL *authurl = [NSURL URLWithString:TW_OAUTH_URL_REQUEST_TOKEN];
    
    // "reverse_auth" is a required parameter
    NSDictionary *dict = [[NSDictionary dictionaryWithObject:TW_X_AUTH_MODE_REVERSE_AUTH forKey:TW_X_AUTH_MODE_KEY] retain];
    TWSignedRequest *signedRequest = [[TWSignedRequest alloc] initWithURL:authurl parameters:dict requestMethod:TWSignedRequestMethodPOST];
    
    [signedRequest performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!data) {
            NSLog(@"Unable to receive a request_token.");
        } else {
            NSString *signedReverseAuthSignature = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            //
            //  Step 2)  Ask Twitter for the user's auth token and secret
            //           include x_reverse_auth_target=CK2 and x_reverse_auth_parameters=signedReverseAuthSignature parameters
            //
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSDictionary *step2Params = [NSDictionary dictionaryWithObjectsAndKeys:[TWSignedRequest consumerKey], TW_X_AUTH_REVERSE_TARGET, signedReverseAuthSignature, TW_X_AUTH_REVERSE_PARMS, nil];
                NSURL *authTokenURL = [NSURL URLWithString:TW_OAUTH_URL_AUTH_TOKEN];
                TWRequest *step2Request = [[TWRequest alloc] initWithURL:authTokenURL parameters:step2Params requestMethod:TWRequestMethodPOST];
                
                [step2Request setAccount:account];
                [step2Request performRequestWithHandler:^(NSData *responseData_twitter, NSHTTPURLResponse *urlResponse, NSError *error) {
                    if (!responseData_twitter) {
                        NSLog(@"Error occurred in Step 2.  Check console for more info.");
                    } else {
                        NSString *responseStr = [[NSString alloc] initWithData:responseData_twitter encoding:NSUTF8StringEncoding];
                        NSLog(@"response: %@", responseStr);
                        NSDictionary *responseDict = [NSURL ab_parseURLQueryString:responseStr];
                        
                        // We are expecting a response responseDict of the format:
                        //
                        // {
                        //     "oauth_token" = ...
                        //     "oauth_token_secret" = ...
                        //     "screen_name" = ...
                        //     "user_id" = ...
                        // }
                        
                        if ([responseDict count] == RESPONSE_EXPECTED_SIZE) {
                            NSLog(@"%@", [NSString stringWithFormat:@"User: %@\nUser ID: %@", [responseDict objectForKey:TW_SCREEN_NAME], [responseDict objectForKey:TW_USER_ID]]);
                            NSLog(@"The user's info for your server:\n%@", responseDict);
                            
                            appDelegate.TWToken = [responseDict objectForKey:@"oauth_token"];
                            TWTokenSecret = [[responseDict objectForKey:@"oauth_token_secret"] retain];
                            
                            // Now make an authenticated request to our endpoint.
                            NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] retain];
                            [params setObject:twitterUsername forKey:TW_SCREEN_NAME];
                            [params setObject:@"1" forKey:@"include_entities"];
                            
                            // The endpoint that we wish to call.
                            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/users/show.json"];
                            
                            // Build the request with our parameter.
                            TWRequest *request = [[TWRequest alloc] initWithURL:url
                                                                     parameters:params
                                                                  requestMethod:TWRequestMethodGET];
                            
                            // Attach the account object to this request.
                            [request setAccount:account];
                            
                            [request performRequestWithHandler:
                             ^(NSData *responseData_twitter, NSHTTPURLResponse *urlResponse, NSError *error) {
                                 if (!responseData_twitter) {
                                     // Inspect the contents of the error.
                                     [self showConnectionError];
                                     NSLog(@"%@", error);
                                 } else {
                                     NSError *jsonError;
                                     NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:responseData_twitter options:NSJSONReadingMutableLeaves error:&jsonError];
                                     
                                     if (userData) {
                                         NSLog(@"%@", userData);
                                         twitterid = [userData objectForKey:@"id"];
                                         
                                         // At this point, we have an object that we can parse.
                                         NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/logtwttoken", SH_DOMAIN]];
                                         
                                         dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
                                         [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
                                         [dataRequest setPostValue:appDelegate.TWToken forKey:@"twtToken"];
                                         [dataRequest setPostValue:TWTokenSecret forKey:@"twtTokenSec"];
                                         [dataRequest setPostValue:twitterUsername forKey:@"twtUsername"];
                                         [dataRequest setPostValue:twitterid forKey:@"twtid"];
                                         [dataRequest setCompletionBlock:^{
                                             NSError *jsonError;
                                             responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
                                             NSLog(@"%@", dataRequest.responseString);
                                             if ([[responseData objectForKey:@"error"] intValue] == 0) {
                                                 [global writeValue:@"YES" forProperty:@"twitterConnected"];
                                                 
                                                 // Lock the button.
                                                 twitterButton.enabled = NO;
                                                 twitterButtonLabel.text = @"Connected to Twitter";
                                                 [appDelegate.strobeLight affirmativeStrobeLight];
                                             } else {
                                                 [global writeValue:@"NO" forProperty:@"twitterConnected"];
                                                 
                                                 // Unlock the button.
                                                 twitterButton.enabled = YES;
                                                 
                                                 if ([[global readProperty:@"fbConnected"] boolValue]) {
                                                     fbButton.enabled = NO;
                                                 } else {
                                                     fbButton.enabled = YES;
                                                 }
                                                 
                                                 NSLog(@"Could not renew Twitter data!\nError:\n%@", dataRequest.responseString);
                                                 [appDelegate.strobeLight negativeStrobeLight];
                                                 
                                                 if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                                                     [self.navigationController popToRootViewControllerAnimated:YES];
                                                     [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
                                                 }
                                             }
                                         }];
                                         [dataRequest setFailedBlock:^{
                                             [self showConnectionError];
                                             [global writeValue:@"NO" forProperty:@"twitterConnected"];
                                             
                                             // Unlock the button.
                                             twitterButton.enabled = YES;
                                             
                                             if ([[global readProperty:@"fbConnected"] boolValue]) {
                                                 fbButton.enabled = NO;
                                             } else {
                                                 fbButton.enabled = YES;
                                             }
                                             
                                             NSError *error = [dataRequest error];
                                             NSLog(@"%@", error);
                                         }];
                                         [dataRequest startAsynchronous];
                                     } else {
                                         // Inspect the contents of jsonError.
                                         NSLog(@"%@", jsonError);
                                     }
                                 }
                             }];
                            
                            [params release];
                            [request release];
                        } else {
                            NSLog(@"The response doesn't seem correct.  Please check the console.");
                            NSLog(@"The user's info for your server:\n%@", responseDict);
                        }
                    }
                }];
            });
        }
    }];
    
    [dict release];
}

- (void)viewDidLoad
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    global = appDelegate.global;
    
    // Set up the nav bar.
    [self setTitle:@"Social Connections"];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture"]];
    
    card = [[UIView alloc] initWithFrame:CGRectMake(8, 9, 303, 51)];
    card.backgroundColor = [UIColor whiteColor];;
    card.layer.masksToBounds = NO;
    card.layer.shadowOffset = CGSizeMake(0, 0);
    card.layer.shadowRadius = 1;
    card.layer.shadowOpacity = 1.0;
    card.layer.borderWidth = 0.7;
    card.layer.borderColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0].CGColor;
    card.layer.cornerRadius = 4;
    
    cardBg = [[UIView alloc] initWithFrame:CGRectMake(1, 1, 301, 49)];
    cardBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise"]];;
    cardBg.layer.masksToBounds = YES;
    card.layer.borderWidth = 0.5;
    card.layer.borderColor = [UIColor whiteColor].CGColor;
    cardBg.layer.cornerRadius = 4;
    
    EGOImageView *userThmbnl = [[EGOImageView alloc] initWithFrame:CGRectMake(9, 9, 30, 30)];
    NSString *profilePicPath = [NSString stringWithFormat:@"http://%@/userphotos/%d/profile/m_%@.jpg", SH_DOMAIN, [[global readProperty:@"userid"] intValue], [global readProperty:@"userPicHash"]];
	userThmbnl.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
    userThmbnl.imageURL = [NSURL URLWithString:profilePicPath];
    
    UIImage *userThmbnlOverlay = [[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:3.0];
    UIImageView *userThmbnlOverlayView = [[UIImageView alloc] initWithImage:userThmbnlOverlay];
    userThmbnlOverlayView.frame = CGRectMake(6, 7, 36, 36);
    
    LPLabel *storyActor = [[LPLabel alloc] initWithFrame:CGRectMake(48, 7, 258, 20)];
    storyActor.backgroundColor = [UIColor clearColor];
    storyActor.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    storyActor.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    storyActor.shadowOffset = CGSizeMake(0, 1);
    storyActor.numberOfLines = 1;
    storyActor.minimumFontSize = 8.;
    storyActor.adjustsFontSizeToFitWidth = YES;
    storyActor.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
    
    LPLabel *usernameLabel = [[LPLabel alloc] initWithFrame:CGRectMake(48, 25, 258, 20)];
    usernameLabel.backgroundColor = [UIColor clearColor];
    usernameLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    usernameLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    usernameLabel.numberOfLines = 1;
    usernameLabel.minimumFontSize = 8.;
    usernameLabel.adjustsFontSizeToFitWidth = YES;
    usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    
    CALayer *dottedDivider = [CALayer layer];
    dottedDivider.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_grey.png"]].CGColor;
    dottedDivider.opaque = YES;
    [dottedDivider setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
    dottedDivider.frame = CGRectMake(0, card.frame.size.height + 20, 320, 2);
    
    fbButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [fbButton addTarget:self action:@selector(renewFBToken:) forControlEvents:UIControlEventTouchUpInside];
    [fbButton setBackgroundImage:[[UIImage imageNamed:@"facebook_button.png"] stretchableImageWithLeftCapWidth:33.0 topCapHeight:31.0] forState:UIControlStateNormal];
    fbButton.frame = CGRectMake(70, 229, 180, 31);
    fbButton.tag = 1;
    
    twitterButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [twitterButton addTarget:self action:@selector(renewTWToken:) forControlEvents:UIControlEventTouchUpInside];
    [twitterButton setBackgroundImage:[[UIImage imageNamed:@"twitter_button.png"] stretchableImageWithLeftCapWidth:33.0 topCapHeight:31.0] forState:UIControlStateNormal];
    twitterButton.frame = CGRectMake(70, 299, 180, 31);
    twitterButton.tag = 2;
    
    fbButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, 140, 31)];
    fbButtonLabel.backgroundColor = [UIColor clearColor];
    fbButtonLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    fbButtonLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    fbButtonLabel.shadowOffset = CGSizeMake(0, -1);
    fbButtonLabel.textAlignment = UITextAlignmentCenter;
    fbButtonLabel.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
    
    twitterButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, 140, 31)];
    twitterButtonLabel.backgroundColor = [UIColor clearColor];
    twitterButtonLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    twitterButtonLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    twitterButtonLabel.shadowOffset = CGSizeMake(0, -1);
    twitterButtonLabel.textAlignment = UITextAlignmentCenter;
    twitterButtonLabel.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
    
    storyActor.text = [global readProperty:@"name"];
    usernameLabel.text = [NSString stringWithFormat:@"@%@", [global readProperty:@"username"]];
    
    if ([[global readProperty:@"fbConnected"] boolValue]) {
        fbButtonLabel.text = @"Connected to Facebook";
        fbButton.enabled = NO;
    } else {
        fbButtonLabel.text = @"Connect to Facebook";
        fbButton.enabled = YES;
    }
    
    if ([[global readProperty:@"twitterConnected"] boolValue]) {
        twitterButtonLabel.text = @"Connected to Twitter";
        twitterButton.enabled = NO;
    } else {
        twitterButtonLabel.text = @"Connect to Twitter";
        twitterButton.enabled = YES;
    }
    
    // Initialize FB permissions.
    fbUserPermissions = appDelegate.fbUserPermissions;
    appDelegate.facebook.sessionDelegate = self;
    
    [self.view addSubview:card];
    [self.view.layer addSublayer:dottedDivider];
    [self.view addSubview:fbButton];
    [self.view addSubview:twitterButton];
    [card addSubview:cardBg];
    [cardBg addSubview:userThmbnlOverlayView];
    [cardBg addSubview:userThmbnl];
    [cardBg addSubview:storyActor];
    [cardBg addSubview:usernameLabel];
    [fbButton addSubview:fbButtonLabel];
    [twitterButton addSubview:twitterButtonLabel];
    
    [userThmbnl release];
    [userThmbnlOverlayView release];
    [storyActor release];
    [usernameLabel release];
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count - 2] == self) { // View is disappearing because a new view controller was pushed onto the stack
        
        
    } else if ([viewControllers indexOfObject:self] == NSNotFound) { // View is disappearing because it was popped from the stack
        HUD.delegate = nil;
        [appDelegate.strobeLight deactivateStrobeLight];
    }
}

#pragma mark UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (actionSheet.tag == 100) { // Twitter accounts list.
        ACAccountStore *store = [[ACAccountStore alloc] init];
        ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
        
        if (buttonIndex != [twitterAccounts count]) {
            ACAccount *account = [twitterAccounts objectAtIndex:buttonIndex];
            [self initiateTwitterSignupForAccount:account];
        } else { // Don't do shit if it's the cancel button.
            [appDelegate.strobeLight deactivateStrobeLight];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // Show the network activity indicator.
            
            if ([[global readProperty:@"fbConnected"] boolValue]) {
                fbButton.enabled = NO;
            } else {
                fbButton.enabled = YES;
            }
            
            twitterButton.enabled = YES;
            twitterButtonLabel.text = @"Connect to Twitter";
        }
        
        [store release];
    }
}

#pragma UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}

#pragma mark FB SDK 3.x

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session!
                NSLog(@"User session found.");
                
                [self storeAuthData:[FBSession.activeSession accessToken] expiresAt:[FBSession.activeSession expirationDate]];
                
                [FBSession.activeSession
                 reauthorizeWithPublishPermissions:
                 [NSArray arrayWithObjects:@"publish_stream", @"publish_actions", nil]
                 defaultAudience:FBSessionDefaultAudienceEveryone
                 completionHandler:^(FBSession *session, NSError *error) {
                     if (!error) {
                         // Success case.
                     } else {
                         [appDelegate.strobeLight negativeStrobeLight];
                         
                         UIAlertView *alert = [[UIAlertView alloc]
                                               initWithTitle:@"Warning!"
                                               message:@"Now you won't be able to post your tips to Facebook!" delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
                         [alert show];
                         [alert release];
                     }
                }];
                
                [FBRequestConnection
                 startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                                   NSDictionary<FBGraphUser> *user,
                                                   NSError *error) {NSLog(@"%@", user);
                     if (!error) {
                         NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/logfbtoken", SH_DOMAIN]];
                         
                         NSString *FBTokenExp = [NSString stringWithFormat:@"%f", [appDelegate.facebook.expirationDate timeIntervalSince1970]];
                         
                         dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
                         [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
                         [dataRequest setPostValue:appDelegate.FBToken forKey:@"fbToken"];
                         [dataRequest setPostValue:FBTokenExp forKey:@"fbTokenExp"];
                         [dataRequest setPostValue:user.id forKey:@"fbid"];
                         [dataRequest setCompletionBlock:^{
                             NSError *jsonError;
                             responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
                             
                             if ([[responseData objectForKey:@"error"] intValue] == 0) {
                                 [global writeValue:@"YES" forProperty:@"fbConnected"];
                                 fbButtonLabel.text = @"Connected to Facebook";
                                 
                                 // Lock the button.
                                 fbButton.enabled = NO;
                                 [appDelegate.strobeLight affirmativeStrobeLight];
                             } else {
                                 [global writeValue:@"NO" forProperty:@"fbConnected"];
                                 
                                 // Unlock the button.
                                 fbButton.enabled = YES;
                                 
                                 NSLog(@"Could not renew FB token!\nError:\n%@", dataRequest.responseString);
                                 [appDelegate.strobeLight negativeStrobeLight];
                                 
                                 if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                                     [self.navigationController popToRootViewControllerAnimated:YES];
                                     [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
                                 }
                             }
                             
                             if ([[global readProperty:@"twitterConnected"] boolValue]) {
                                 twitterButton.enabled = NO;
                             } else {
                                 twitterButton.enabled = YES;
                             }
                         }];
                         [dataRequest setFailedBlock:^{
                             [self showConnectionError];
                             [global writeValue:@"NO" forProperty:@"fbConnected"];
                             
                             // Unlock the button.
                             fbButton.enabled = YES;
                             
                             if ([[global readProperty:@"twitterConnected"] boolValue]) {
                                 twitterButton.enabled = NO;
                             } else {
                                 twitterButton.enabled = YES;
                             }
                             
                             NSError *error = [dataRequest error];
                             NSLog(@"%@", error);
                         }];
                         [dataRequest startAsynchronous];
                     }
                 }];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            [appDelegate.strobeLight negativeStrobeLight];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            // Unlock the buttons.
            fbButton.enabled = YES;
            twitterButton.enabled = YES;
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error!"
                                  message:@"An error occured. Tipbox only uses your basic info such as your name and username. Please try again." delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    return [FBSession openActiveSessionWithReadPermissions:[NSArray arrayWithObjects:@"email", @"user_location", @"user_website", @"user_about_me", nil]
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}

- (void)apiFQLIMe {
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT uid, name, pic FROM user WHERE uid=me()", @"query",
                                   nil];
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.facebook requestWithMethodName:@"fql.query"
                                      andParams:params
                                  andHttpMethod:@"POST"
                                    andDelegate:self];
}

- (void)apiGraphUserPermissions
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.facebook requestWithGraphPath:@"me/permissions" andDelegate:self];
}

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.FBToken = accessToken;
}

#pragma mark - FBSessionDelegate Methods
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self storeAuthData:[appDelegate.facebook accessToken] expiresAt:[appDelegate.facebook expirationDate]];
    [appDelegate.facebook requestWithGraphPath:@"me" andDelegate:self];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
{
    NSLog(@"Token extended!");
    [self storeAuthData:accessToken expiresAt:expiresAt];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight negativeStrobeLight];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [global writeValue:@"NO" forProperty:@"fbConnected"];
    
    // Unlock the buttons.
    fbButton.enabled = YES;
    
    if ([[global readProperty:@"twitterConnected"] boolValue]) {
        twitterButton.enabled = NO;
    } else {
        twitterButton.enabled = YES;
    }
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout
{
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight negativeStrobeLight];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [global writeValue:@"NO" forProperty:@"fbConnected"];
    
    // Unlock the buttons.
    fbButton.enabled = YES;
    
    if ([[global readProperty:@"twitterConnected"] boolValue]) {
        twitterButton.enabled = NO;
    } else {
        twitterButton.enabled = YES;
    }
}

/**
 * Called when the session has expired.
 */
- (void)fbSessionInvalidated
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Error!"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil,
                              nil];
    [alertView show];
    [alertView release];
    [self fbDidLogout];
}

#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
    }
    // This callback can be a result of getting the user's basic
    // information or getting the user's permissions.
    if ([result objectForKey:@"name"]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/logfbtoken", SH_DOMAIN]];
        
        NSString *FBTokenExp = [NSString stringWithFormat:@"%f", [appDelegate.facebook.expirationDate timeIntervalSince1970]];
        
        dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
        [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
        [dataRequest setPostValue:appDelegate.FBToken forKey:@"fbToken"];
        [dataRequest setPostValue:FBTokenExp forKey:@"fbTokenExp"];
        [dataRequest setPostValue:[result objectForKey:@"id"] forKey:@"fbid"];
        [dataRequest setCompletionBlock:^{
            NSError *jsonError;
            responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if ([[responseData objectForKey:@"error"] intValue] == 0) {
                [global writeValue:@"YES" forProperty:@"fbConnected"];
                fbButtonLabel.text = @"Connected to Facebook";
                
                // Lock the button.
                fbButton.enabled = NO;
                [appDelegate.strobeLight affirmativeStrobeLight];
            } else {
                [global writeValue:@"NO" forProperty:@"fbConnected"];
                
                // Unlock the button.
                fbButton.enabled = YES;
                
                NSLog(@"Could not renew FB token!\nError:\n%@", dataRequest.responseString);
                [appDelegate.strobeLight negativeStrobeLight];
                
                if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
                }
            }
            
            if ([[global readProperty:@"twitterConnected"] boolValue]) {
                twitterButton.enabled = NO;
            } else {
                twitterButton.enabled = YES;
            }
        }];
        [dataRequest setFailedBlock:^{
            [self showConnectionError];
            [global writeValue:@"NO" forProperty:@"fbConnected"];
            
            // Unlock the button.
            fbButton.enabled = YES;
            
            if ([[global readProperty:@"twitterConnected"] boolValue]) {
                twitterButton.enabled = NO;
            } else {
                twitterButton.enabled = YES;
            }
            
            NSError *error = [dataRequest error];
            NSLog(@"%@", error);
        }];
        [dataRequest startAsynchronous];
        [self apiGraphUserPermissions];
    } else {
        // Processing permissions information
        appDelegate.fbUserPermissions = [[result objectForKey:@"data"] objectAtIndex:0];
    }
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight negativeStrobeLight];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [global writeValue:@"NO" forProperty:@"fbConnected"];
    
    // Unlock the buttons.
    fbButton.enabled = YES;
    fbButtonLabel.text = @"Connect to Facebook";
    
    if ([[global readProperty:@"twitterConnected"] boolValue]) {
        twitterButton.enabled = NO;
    } else {
        twitterButton.enabled = YES;
    }
    
    NSLog(@"Error message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSLog(@"Error code: %d", [error code]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [card release];
    [cardBg release];
    [fbButton release];
    [twitterButton release];
    [fbButtonLabel release];
    [twitterButtonLabel release];
    [super dealloc];
}


@end
