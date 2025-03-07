#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import "SignupViewController.h"
#import "SCAppUtils.h"
#import "Signup_FormViewController.h"
#import "TipboxAppDelegate.h"
#import "WebViewController.h"
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

@implementation SignupViewController

@synthesize delegate, cancelButton, fbUserPermissions;

#pragma mark setTitle override
- (void)setTitle:(NSString *)title
{
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        titleView.shadowOffset = CGSizeMake(0, -1);
        
        titleView.textColor = [UIColor colorWithWhite:1.0 alpha:0.85]; // Change to desired color.
        
        self.navigationItem.titleView = titleView;
        [titleView release];
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (void)dismissSettingsPanel
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight deactivateStrobeLight];
    [appDelegate.facebook logout];
    [appDelegate hideTabbarShadowAnimated:NO];
    [appDelegate closeBoxWithConfiguration:@"signup"];
    
    // Unlock the buttons.
    fbButton.enabled = YES;
    twitterButton.enabled = YES;
    emailButton.enabled = YES;
    
    if (delegate && [delegate respondsToSelector:@selector(signupPanelDidGetDismissed)]) {
        [delegate signupPanelDidGetDismissed];
    } else {
        NSLog(@"Not Delegating. I don't know why. :/");
    }
}

- (void)initiateSignup:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    // Lock the buttons.
    fbButton.enabled = NO;
    twitterButton.enabled = NO;
    emailButton.enabled = NO;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // Show the network activity indicator.
    
    if (button.tag == 1) {                              // Facebook.
        if (![appDelegate.facebook isSessionValid]) {
            //[appDelegate.facebook authorize:fbUserPermissions];
            [self openSessionWithAllowLoginUI:YES];
        } else {
            [appDelegate.facebook requestWithGraphPath:@"me" andDelegate:self];
        }
    } else if (button.tag == 2) {                        // Twitter.
        ACAccountStore *store = [[ACAccountStore alloc] init];
        ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        //  Request access from the user for access to his Twitter accounts.
        [store requestAccessToAccountsWithType:twitterAccountType withCompletionHandler:^(BOOL granted, NSError *error) {
            if (!granted) {
                // The user rejected your request.
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
                emailButton.enabled = YES;
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
    } else if (button.tag == 3) {                       // Email.
        Signup_FormViewController *signupForm = [[Signup_FormViewController alloc] init];
        [self.navigationController pushViewController:signupForm animated:YES];
        [signupForm showFieldsForConfiguration:@"email"];
        [signupForm release];
    }
    
    
}

#define RESPONSE_EXPECTED_SIZE 4
- (void)initiateTwitterSignupForAccount:(ACAccount *)account
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    Signup_FormViewController *signupForm = [[Signup_FormViewController alloc] init];
    username = account.username;
    
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
                            [params setObject:username forKey:TW_SCREEN_NAME];
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
                                         // At this point, we have an object that we can parse.
                                         twitterid = [userData objectForKey:@"id"];
                                         name = [userData objectForKey:@"name"];
                                         picHash = [userData objectForKey:@"profile_image_url"];
                                         location = [userData objectForKey:@"location"];
                                         bio = [userData objectForKey:@"description"];
                                         websiteURL = [userData objectForKey:@"url"];
                                         userTimezone = [userData objectForKey:@"utc_offset"];
                                         
                                         self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
                                         signupForm.twitterid = twitterid;
                                         signupForm.name = name;
                                         signupForm.username = username;
                                         signupForm.twitterUsername = username;
                                         signupForm.picHash = picHash;
                                         signupForm.location = location;
                                         signupForm.bio = bio;
                                         signupForm.websiteURL = websiteURL;
                                         signupForm.TWTokenSecret = TWTokenSecret;
                                         signupForm.userTimezone = userTimezone;
                                         
                                         // This next part must be done on the main thread, or it'll crash the app!
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.navigationController pushViewController:signupForm animated:YES];
                                             [signupForm showFieldsForConfiguration:@"twitter"];
                                         });
                                         
                                         // Unlock the buttons.
                                         fbButton.enabled = YES;
                                         twitterButton.enabled = YES;
                                         emailButton.enabled = YES;
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
    [signupForm release];
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

- (void)viewDidLoad
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Set up the nav bar.
    [SCAppUtils customizeNavigationController:self.navigationController];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:192.0/255.0 green:133.0/255.0 blue:87.0/255.0 alpha:1.0];
    [self setTitle:@"Join Tipbox"];
    
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissSettingsPanel)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = cancelButton;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    
    UIImageView *tipWall = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_tips_everywhere.png"]];
    tipWall.frame = CGRectMake(0, 5, 320, 504);
    
    UIImageView *theBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signup_box.png"]];
    theBox.frame = CGRectMake(17, 50, 284, 307);
    theBox.userInteractionEnabled = YES;
    
    descLabel = [[UILabel alloc] initWithFrame:CGRectMake(53, 115, 178, 25)];
    descLabel.backgroundColor = [UIColor clearColor];
    descLabel.textColor = [UIColor whiteColor];
    descLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    descLabel.shadowOffset = CGSizeMake(0, -1);
    descLabel.numberOfLines = 0;
    descLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_SECONDARY_FONT_SIZE];
    descLabel.text = @"Tipbox is tip sharing, reinvented for your iPhone.";
    
    fbButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [fbButton addTarget:self action:@selector(initiateSignup:) forControlEvents:UIControlEventTouchUpInside];
    [fbButton setBackgroundImage:[[UIImage imageNamed:@"facebook_button.png"] stretchableImageWithLeftCapWidth:33.0 topCapHeight:31.0] forState:UIControlStateNormal];
    fbButton.frame = CGRectMake(51, 155, 180, 31);
    fbButton.tag = 1;
    
    twitterButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [twitterButton addTarget:self action:@selector(initiateSignup:) forControlEvents:UIControlEventTouchUpInside];
    [twitterButton setBackgroundImage:[[UIImage imageNamed:@"twitter_button.png"] stretchableImageWithLeftCapWidth:33.0 topCapHeight:31.0] forState:UIControlStateNormal];
    twitterButton.frame = CGRectMake(51, 190, 180, 31);
    twitterButton.tag = 2;
    
    emailButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [emailButton addTarget:self action:@selector(initiateSignup:) forControlEvents:UIControlEventTouchUpInside];
    [emailButton setBackgroundImage:[[UIImage imageNamed:@"email_signup_button.png"] stretchableImageWithLeftCapWidth:28.0 topCapHeight:31.0] forState:UIControlStateNormal];
    emailButton.frame = CGRectMake(50, 225, 182, 31);
    emailButton.tag = 3;
    
    UILabel *fbButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, 177, 31)];
    fbButtonLabel.backgroundColor = [UIColor clearColor];
    fbButtonLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    fbButtonLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    fbButtonLabel.shadowOffset = CGSizeMake(0, -1);
    fbButtonLabel.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
    fbButtonLabel.text = @"Sign up using Facebook";
    
    UILabel *twitterButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, 177, 31)];
    twitterButtonLabel.backgroundColor = [UIColor clearColor];
    twitterButtonLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    twitterButtonLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    twitterButtonLabel.shadowOffset = CGSizeMake(0, -1);
    twitterButtonLabel.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
    twitterButtonLabel.text = @"Sign up using Twitter";
    
    UILabel *emailButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 177, 31)];
    emailButtonLabel.backgroundColor = [UIColor clearColor];
    emailButtonLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    emailButtonLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    emailButtonLabel.shadowOffset = CGSizeMake(0, -1);
    emailButtonLabel.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
    emailButtonLabel.text = @"Sign up using your email";
    
    [self.view addSubview:tipWall];
    [self.view addSubview:theBox];
    [theBox addSubview:descLabel];
    [theBox addSubview:fbButton];
    [theBox addSubview:twitterButton];
    [theBox addSubview:emailButton];
    [fbButton addSubview:fbButtonLabel];
    [twitterButton addSubview:twitterButtonLabel];
    [emailButton addSubview:emailButtonLabel];
    
    // Initialize FB permissions.
    fbUserPermissions = appDelegate.fbUserPermissions;
    appDelegate.facebook.sessionDelegate = self;
    
    [tipWall release];
    [fbButtonLabel release];
    [twitterButtonLabel release];
    [emailButtonLabel release];
    [super viewDidLoad];
}

#pragma mark Customizations when the view appears/disappears
- (void)viewWillAppear:(BOOL)animated
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate tabbarShadowMode_nobar];
    [appDelegate showTabbarShadowAnimated:YES];
    
    // Unlock the buttons.
    fbButton.enabled = YES;
    twitterButton.enabled = YES;
    emailButton.enabled = YES;
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

#pragma mark UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (actionSheet.tag == 100) { // Twitter accounts list.
        ACAccountStore *store = [[ACAccountStore alloc] init];
        ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
        
        if (buttonIndex != [twitterAccounts count]) { // Don't do shit if it's the cancel button.
            ACAccount *account = [twitterAccounts objectAtIndex:buttonIndex];
            [self initiateTwitterSignupForAccount:account];
        } else {
            [appDelegate.strobeLight deactivateStrobeLight];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // Show the network activity indicator.
            
            fbButton.enabled = YES;
            twitterButton.enabled = YES;
            emailButton.enabled = YES;
        }
        
        [store release];
    }
}

#pragma mark UIAlertViewDelegate
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
                         fbid = user.id;
                         name = user.name;
                         username = user.username;
                         email = [user objectForKey:@"email"];
                         location = [user.location objectForKey:@"name"];
                         bio = [user objectForKey:@"bio"];
                         websiteURL = [user objectForKey:@"website"];
                         userTimezone = [user objectForKey:@"timezone"];
                         
                         if (bio.length > 160) {
                             bio = [[bio substringToIndex:156] stringByAppendingString:@"..."];
                         }
                         
                         Signup_FormViewController *signupForm = [[Signup_FormViewController alloc] init];
                         self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
                         signupForm.fbid = fbid;
                         signupForm.name = name;
                         signupForm.email = email;
                         signupForm.username = username;
                         signupForm.location = location;
                         signupForm.bio = bio;
                         signupForm.websiteURL = websiteURL;
                         signupForm.userTimezone = userTimezone;
                         [self.navigationController pushViewController:signupForm animated:YES];
                         [signupForm showFieldsForConfiguration:@"facebook"];
                         [signupForm release];
                         signupForm = nil;
                         
                         // Unlock the buttons.
                         fbButton.enabled = YES;
                         twitterButton.enabled = YES;
                         emailButton.enabled = YES;
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
            emailButton.enabled = YES;
            
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
    
    // Unlock the buttons.
    fbButton.enabled = YES;
    twitterButton.enabled = YES;
    emailButton.enabled = YES;
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
    
    // Unlock the buttons.
    fbButton.enabled = YES;
    twitterButton.enabled = YES;
    emailButton.enabled = YES;
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
        fbid = [result objectForKey:@"id"];
        name = [result objectForKey:@"name"];
        username = [result objectForKey:@"username"];
        email = [result objectForKey:@"email"];
        location = [[result objectForKey:@"location"] objectForKey:@"name"];
        bio = [result objectForKey:@"bio"];
        websiteURL = [result objectForKey:@"website"];
        userTimezone = [result objectForKey:@"timezone"];
        
        if (bio.length > 160) {
            bio = [[bio substringToIndex:160] stringByAppendingString:@"..."];
        }
        
        Signup_FormViewController *signupForm = [[Signup_FormViewController alloc] init];
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        signupForm.fbid = fbid;
        signupForm.name = name;
        signupForm.email = email;
        signupForm.username = username;
        signupForm.location = location;
        signupForm.bio = bio;
        signupForm.websiteURL = websiteURL;
        signupForm.userTimezone = userTimezone;
        [self.navigationController pushViewController:signupForm animated:YES];
        [signupForm showFieldsForConfiguration:@"facebook"];
        [signupForm release];
        signupForm = nil;
        
        // Unlock the buttons.
        fbButton.enabled = YES;
        twitterButton.enabled = YES;
        emailButton.enabled = YES;
        
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
    
    // Unlock the buttons.
    fbButton.enabled = YES;
    twitterButton.enabled = YES;
    emailButton.enabled = YES;
    
    NSLog(@"Error message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSLog(@"Error code: %d", [error code]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [cancelButton release];
    [descLabel release];
    [fbButton release];
    [twitterButton release];
    [emailButton release];
    [TWTokenSecret release];
    [super dealloc];
}

@end
