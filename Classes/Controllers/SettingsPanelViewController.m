#import <Twitter/Twitter.h>
#import "SettingsPanelViewController.h"
#import "TipboxAppDelegate.h"
#import "MeViewController.h"
#import "Settings_AboutViewController.h"
#import "Settings_ContactViewController.h"
#import "Settings_CorporateWebViewController.h"
#import "Settings_PasswdViewController.h"
#import "Settings_ProfileEditorViewController.h"
#import "SocialConnectionsManager.h"

@implementation SettingsPanelViewController

@synthesize dataRequest, responseData, delegate, settingsTableView;
@synthesize tableContents, sortedKeys, selectedDPImage;

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

- (void)dismissSettingsPanel
{
    if (delegate && [delegate respondsToSelector:@selector(panelDidGetDismissed)]) {
        [delegate panelDidGetDismissed];
    } else {
        NSLog(@"Not Delegating. I don't know why. :/");
    } 
    
    delegate = nil;
    [self.dataRequest cancel];
    HUD.delegate = nil;
    
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    global = appDelegate.global;
    
    // Set up the nav bar.
    [self setTitle:@"Settings"];
    
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissSettingsPanel)];
    self.navigationController.navigationBar.topItem.rightBarButtonItem = doneButton;
    
    settingsTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    
    NSArray *arrTemp1 = [[NSArray alloc]
                         initWithObjects:@"Invite friends", nil];
	NSArray *arrTemp2 = [[NSArray alloc]
                         initWithObjects:@"Edit your profile", @"Manage connections", @"Change your password", @"Change your picture", nil];
	NSArray *arrTemp3 = [[NSArray alloc]
                         initWithObjects:@"About us", @"Get in touch", @"Privacy Policy", @"Terms & Conditions", nil];
    NSArray *arrTemp4 = [[NSArray alloc]
                         initWithObjects:@"Logout", nil];
	NSDictionary *temp =[[NSDictionary alloc]
                         initWithObjectsAndKeys:arrTemp1, @"1", arrTemp2, 
                         @"2", arrTemp3, @"3", arrTemp4, @"4", nil];
    
	self.tableContents = temp;
	self.sortedKeys =[[self.tableContents allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    dpPicker = [[UIImagePickerController alloc] init];
    dpPicker.delegate = self;
    
	[arrTemp1 release];
	[arrTemp2 release];
	[arrTemp3 release];
    [arrTemp4 release];
    [temp release];
    [super viewDidLoad];
}

#pragma mark Customizations when the view appears/disappears
- (void)viewWillAppear:(BOOL)animated
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:162/255.0 green:165/255.0 blue:152/255.0 alpha:1.0];
    [appDelegate tabbarShadowMode_nobar];
    [appDelegate navbarShadowMode_navbar];
    [appDelegate showNavbarShadowAnimated:YES];
    [appDelegate showTabbarShadowAnimated:YES];
    [super viewWillAppear:animated];
}

#pragma mark Table Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sortedKeys count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	NSArray *listData =[self.tableContents objectForKey:
                        [self.sortedKeys objectAtIndex:section]];
	return [listData count];
}

- (CGFloat)tableView:(UITableView *)table heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 50.0;
    } else {
        return 10.0;
    }
}

- (CGFloat)tableView:(UITableView *)table heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return 40.0;
    } else {
        return 10.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 44.0)];
        NSNumber *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CWBuildNumber"];
        
        // Add the label
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, -18.0, 300.0, 90.0)];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.opaque = NO;
        //headerLabel.text = [NSString stringWithFormat:@"❤ Tipbox %@ (Build %@), by Scapehouse.", APP_VERSION, buildNumber];
        headerLabel.text = [NSString stringWithFormat:@"❤ Tipbox 1.1, by Scapehouse."];
        headerLabel.textColor = [UIColor colorWithRed:76.0/255.0 green:86.0/255.0 blue:108.0/255.0 alpha:1.0];
        headerLabel.font = [UIFont systemFontOfSize:16];
        headerLabel.shadowColor = [UIColor whiteColor];
        headerLabel.shadowOffset = CGSizeMake(0, 1);
        headerLabel.numberOfLines = 0;
        headerLabel.textAlignment = UITextAlignmentCenter;
        [headerView addSubview:headerLabel];
        
        [headerLabel release];  
        
        return [headerView autorelease];
    } else {
       return nil; 
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 44.0)];
        //headerView.contentMode = UIViewContentModeScaleToFill;
        
        // Add the label
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, -25, 300, 90)];
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.opaque = NO;
        footerLabel.text = @"Be Original.";
        footerLabel.textColor = [UIColor colorWithRed:76.0/255.0 green:86.0/255.0 blue:108.0/255.0 alpha:1.0];
        footerLabel.font = [UIFont fontWithName:@"Georgia" size:16];
        footerLabel.shadowColor = [UIColor whiteColor];
        footerLabel.shadowOffset = CGSizeMake(0, 1);
        footerLabel.numberOfLines = 0;
        footerLabel.textAlignment = UITextAlignmentCenter;
        [footerView addSubview:footerLabel];
        
        [footerLabel release];  
        
        return [footerView autorelease];
    } else {
        return nil; 
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"SimpleTableIdentifier";
    
	NSArray *listData =[self.tableContents objectForKey:
                        [self.sortedKeys objectAtIndex:[indexPath section]]];
    
	UITableViewCell *cell = [tableView
                              dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
        
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:CellIdentifier] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // Set the accessory type.
	}
    
	cell.textLabel.text = [listData objectAtIndex:[indexPath row]];
    
    // Customization. I hide the accessory for the buttons that don't push new view controllers:
    // # "Change your picture" button
    // # "Logout" button
	if ((indexPath.section == 0 && indexPath.row == 0) || (indexPath.section == 1 && indexPath.row == 3) || (indexPath.section == 3 && indexPath.row == 0)) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	/*NSArray *listData =[self.tableContents objectForKey:
                        [self.sortedKeys objectAtIndex:indexPath.section]];
	NSString *rowValue = [listData objectAtIndex:indexPath.row];
	NSString *message = [[NSString alloc] initWithFormat:rowValue];*/
    
    if (indexPath.section == 0 && indexPath.row == 0) { // Invite friends.
        
        UIActionSheet *invitationOptions;
        
        if ([MFMessageComposeViewController canSendText]) {
            invitationOptions = [[UIActionSheet alloc] 
                                 initWithTitle:@"Invite your friends!" 
                                 delegate:self
                                 cancelButtonTitle:@"Cancel" 
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:@"Invite via Text", @"Invite via Email", @"Invite via Facebook", @"Invite via Twitter", nil];
        } else {
            invitationOptions = [[UIActionSheet alloc] 
                                 initWithTitle:@"Invite your friends!" 
                                 delegate:self
                                 cancelButtonTitle:@"Cancel" 
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:@"Invite via Email", @"Invite via Facebook", @"Invite via Twitter", nil];
        }
        
        invitationOptions.tag = 1;
        invitationOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
        [invitationOptions showFromTabBar:appDelegate.mainTabBarController.tabBar];
        [invitationOptions release];
        
    } else if (indexPath.section == 1 && indexPath.row == 0) { // Edit profile.
        
        Settings_ProfileEditorViewController *profileEditorView = [[Settings_ProfileEditorViewController alloc] 
                                                        initWithNibName:@"Settings_ProfileEditorView" 
                                                        bundle:[NSBundle mainBundle]];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:profileEditorView animated:YES];
        [profileEditorView release];
        profileEditorView = nil;
        
    } else if (indexPath.section == 1 && indexPath.row == 1) { // Manage connections.
        
        SocialConnectionsManager *connectionsManager = [[SocialConnectionsManager alloc] init];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:connectionsManager animated:YES];
        [connectionsManager release];
        connectionsManager = nil;
        
    } else if (indexPath.section == 1 && indexPath.row == 2) { // Change password.
        
        Settings_PasswdViewController *passwdView = [[Settings_PasswdViewController alloc] 
                                                     initWithNibName:@"Settings_PasswdView" 
                                                     bundle:[NSBundle mainBundle]];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:passwdView animated:YES];
        [passwdView release];
        passwdView = nil;
        
    } else if (indexPath.section == 1 && indexPath.row == 3) { // Change picture.
            
        [self showUserPicOptions];
            
    } else if (indexPath.section == 2 && indexPath.row == 0) { // About us.
        
        Settings_AboutViewController *aboutView = [[Settings_AboutViewController alloc] 
                                                        initWithNibName:@"Settings_AboutView" 
                                                        bundle:[NSBundle mainBundle]];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:aboutView animated:YES];
        [aboutView release];
        aboutView = nil;
        
    } else if (indexPath.section == 2 && indexPath.row == 1) { // Get in touch.
        
        Settings_ContactViewController *aboutView = [[Settings_ContactViewController alloc] init];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:aboutView animated:YES];
        [aboutView release];
        aboutView = nil;
        
    } else if (indexPath.section == 2 && indexPath.row == 2) { // Privacy policy.
        
        NSString *url = [NSString stringWithFormat:@"http://%@/corporate/privacy", SH_DOMAIN];
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:60.0];
        
        Settings_CorporateWebViewController *webView = [[Settings_CorporateWebViewController alloc] 
                                      initWithNibName:@"Settings_CorporateWebView" 
                                      bundle:[NSBundle mainBundle]];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [webView setTitle:@"Privacy Policy"];
        [self.navigationController pushViewController:webView animated:YES];
        [webView.browser loadRequest:theRequest];
        [webView release];
        webView.url = url;
        webView = nil;
        
    } else if (indexPath.section == 2 && indexPath.row == 3) { // TOS.
        
        NSString *url = [NSString stringWithFormat:@"http://%@/corporate/tos", SH_DOMAIN];
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:60.0];
        
        Settings_CorporateWebViewController *webView = [[Settings_CorporateWebViewController alloc] 
                                                        initWithNibName:@"Settings_CorporateWebView" 
                                                        bundle:[NSBundle mainBundle]];
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [webView setTitle:@"Terms & Conditions"];
        [self.navigationController pushViewController:webView animated:YES];
        [webView.browser loadRequest:theRequest];
        [webView release];
        webView.url = url;
        webView = nil;
        
    } else if (indexPath.section == 3 && indexPath.row == 0) { // Logout.
        
        UIAlertView *logoutAlert = [[UIAlertView alloc]
                                    initWithTitle:@"Logout?"
                                    message:@"Are you sure you want to log out?" delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    otherButtonTitles:@"Logout", nil];
        [logoutAlert show];
        [logoutAlert release];
        
    }
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (actionSheet.tag == 1) { // Friend invitation options.
        
        // Check if the device can send texts, as this will affect the button indices.
        if ([MFMessageComposeViewController canSendText]) {
            if (buttonIndex == 0) { // Invite via Text.
                MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
                picker.messageComposeDelegate = self;
                
                NSString *messageBody = @"Check out Tipbox. It's tip sharing, reinvented for your iPhone. http://scapehouse.com"; // Fill out the email body text.
                [picker setBody:messageBody];
                
                picker.navigationBar.tintColor = [UIColor colorWithRed:162/255.0 green:165/255.0 blue:152/255.0 alpha:1.0];
                
                [appDelegate navbarShadowMode_navbar];
                [appDelegate tabbarShadowMode_nobar];
                [self presentModalViewController:picker animated:YES];
                [picker release];
            } else if (buttonIndex == 1) { // Invite via Email.
                MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                picker.mailComposeDelegate = self;
                
                NSString *emailBody = @"Check out Tipbox. It's tip sharing, reinvented for your iPhone. http://scapehouse.com"; // Fill out the email body text.
                [picker setSubject:[NSString stringWithFormat:@"Tipbox"]];
                [picker setMessageBody:emailBody isHTML:YES]; // Depends. Mostly YES, unless you want to send it as plain text (boring).
                
                picker.navigationBar.tintColor = [UIColor colorWithRed:162/255.0 green:165/255.0 blue:152/255.0 alpha:1.0];
                
                [appDelegate navbarShadowMode_navbar];
                [appDelegate tabbarShadowMode_nobar];
                [self presentModalViewController:picker animated:YES];
                [picker release];
            } else if (buttonIndex == 2) { // Invite via Facebook.
                NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               @"It's tip sharing, reinvented for your iPhone.",  @"message",
                                               @"Check this out!", @"notification_text",
                                               nil];
                
                [appDelegate.facebook dialog:@"apprequests"
                                  andParams:params
                                andDelegate:self];
            } else if (buttonIndex == 3) { // Invite via Twitter.
                TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init]; // Create the tweet sheet.
                [tweetSheet setInitialText:@"Check out #Tipbox. It's tip sharing, reinvented for your iPhone. (via @Scapehouse)"];
                [tweetSheet addURL:[NSURL URLWithString:@"http://scapehouse.com"]];
                
                tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result) { // Set a blocking handler for the tweet sheet.
                    dispatch_async(dispatch_get_main_queue(), ^{            
                        [self dismissViewControllerAnimated:YES completion:^{
                            
                        }];
                    });
                };
                
                // Show the tweet sheet!
                [self presentModalViewController:tweetSheet animated:YES];
            }
        } else {
            if (buttonIndex == 0) { // Invite via Email.
                MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                picker.mailComposeDelegate = self;
                
                NSString *emailBody = [NSString stringWithFormat:@"Check out Tipbox. It's tip sharing, reinvented for your iPhone. <a href=\"http://scapehouse.com\">http://scapehouse.com</a>"]; // Fill out the email body text.
                [picker setSubject:[NSString stringWithFormat:@"Tipbox"]];
                [picker setMessageBody:emailBody isHTML:YES]; // Depends. Mostly YES, unless you want to send it as plain text (boring).
                
                picker.navigationBar.barStyle = UIBarStyleBlackOpaque;
                
                [appDelegate navbarShadowMode_navbar];
                [appDelegate tabbarShadowMode_nobar];
                [self presentModalViewController:picker animated:YES];
                [picker release];
            } else if (buttonIndex == 1) { // Invite via Facebook.
                NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               @"It's tip sharing, reinvented for your iPhone.",  @"message",
                                               @"Check this out!", @"notification_text",
                                               nil];
                
                [appDelegate.facebook dialog:@"apprequests"
                                   andParams:params
                                 andDelegate:self];
            } else if (buttonIndex == 2) { // Invite via Twitter.
                TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init]; // Create the tweet sheet.
                [tweetSheet setInitialText:@"Check out #Tipbox. It's tip sharing, reinvented for your iPhone. (via @Scapehouse)"];
                [tweetSheet addURL:[NSURL URLWithString:@"http://scapehouse.com"]];
                
                tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result) { // Set a blocking handler for the tweet sheet.
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:YES completion:^{
                            
                        }];
                    });
                };
                
                // Show the tweet sheet!
                [self presentModalViewController:tweetSheet animated:YES];
            }
        }
        
    } else if (actionSheet.tag == 2) { // Profile pic options
        BOOL fbConnected = [[global readProperty:@"fbConnected"] boolValue];
        BOOL twitterConnected = [[global readProperty:@"twitterConnected"] boolValue];
        
        if (buttonIndex == 0) { // Delete DP.
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/deletepicture", SH_DOMAIN]];
            
            dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
            [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
            [dataRequest setCompletionBlock:^{
                NSError *jsonError;
                responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
                
                if ([[responseData objectForKey:@"error"] intValue] == 0) {
                    [global writeValue:@"" forProperty:@"userPicHash"];
                    
                    HUD = [[MBProgressHUD alloc] initWithView:self.view];
                    [self.view addSubview:HUD];
                    
                    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_white.png"]] autorelease];
                    HUD.mode = MBProgressHUDModeCustomView; // Set custom view mode.
                    HUD.dimBackground = YES;
                    HUD.delegate = self;
                    
                    [HUD show:YES];
                    [HUD hide:YES afterDelay:2];
                    
                    [appDelegate.strobeLight deactivateStrobeLight];
                } else {
                    NSLog(@"Could not delete DP!\nError:\n%@", dataRequest.responseString);
                    [appDelegate.strobeLight negativeStrobeLight];
                    
                    if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                        [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
                    }
                }
            }];
            [dataRequest setFailedBlock:^{
                HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:HUD];
                
                HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
                
                // Set custom view mode.
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.dimBackground = YES;
                HUD.delegate = self;
                HUD.labelText = @"Could not connect!";
                
                [appDelegate.strobeLight negativeStrobeLight];
                
                [HUD show:YES];
                [HUD hide:YES afterDelay:3];
                
                NSError *error = [dataRequest error];
                NSLog(@"%@", error);
            }];
            [dataRequest startAsynchronous];
        }
        
        // Run check for iOS devices with no cameras!
        // If the device has no camera, we won't show the "Take Photo" button, so watch out!
        // Depending on the connected social profiles, the import options will vary as well.
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            if (buttonIndex == 1) {
                dpPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                dpPicker.modalPresentationStyle = UIModalPresentationFullScreen;
                [appDelegate hideNavbarShadowAnimated:YES];
                [self presentModalViewController:dpPicker animated:YES];
            } else if (buttonIndex == 2) {
                dpPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentModalViewController:dpPicker animated:YES];
            } else if (buttonIndex == 3) {
                if (fbConnected) {
                    // Import from FB.
                    [self importFBDP];
                } else if (twitterConnected) {
                    // Import from Twitter.
                    [self importTWTDP];
                }
            } else if (buttonIndex == 4 && twitterConnected) {
                // Import from Twitter.
                [self importTWTDP];
            }
        } else {
            if (buttonIndex == 1) {
                dpPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentModalViewController:dpPicker animated:YES];
            } else if (buttonIndex == 2) {
                if (fbConnected) {
                    // Import from FB.
                    [self importFBDP];
                } else if (twitterConnected) {
                    // Import from Twitter.
                    [self importTWTDP];
                }
            } else if (buttonIndex == 3) {
                if (fbConnected && twitterConnected) {
                    // Import from Twitter.
                    [self importTWTDP];
                }
            }
        }
    } else if (actionSheet.tag == 3) { // Twitter account list.
        ACAccountStore *store = [[ACAccountStore alloc] init];
        ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
        
        if (buttonIndex != [twitterAccounts count]) { // Don't do shit if it's the cancel button.
            ACAccount *account = [twitterAccounts objectAtIndex:buttonIndex];
            [self initiateTwitterDPImportForAccount:account];
        } else {
            [appDelegate.strobeLight deactivateStrobeLight];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // Show the network activity indicator.
        }
        
        [store release];
    }
}

#pragma mark Dismiss message composer
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultSent:
            break;
        case MessageComposeResultFailed:
            break;
            
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Status" message:@"Sending Failed - Unknown Error"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
            
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark Dismiss mail composer
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
            
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Status" message:@"Sending Failed - Unknown Error"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
            
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showUserPicOptions
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIActionSheet *dpOptions;
    BOOL fbConnected = [[global readProperty:@"fbConnected"] boolValue];
    BOOL twitterConnected = [[global readProperty:@"twitterConnected"] boolValue];
    
    // Run checks for iOS devices with no cameras!
    // If the device has no camera, we won't show the "Take Photo" button, so watch out!
    // Depending on the connected social profiles, the import options will vary as well.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (fbConnected && twitterConnected) {
            dpOptions = [[UIActionSheet alloc] 
                         initWithTitle:@"Change your picture" 
                         delegate:self
                         cancelButtonTitle:@"Cancel" 
                         destructiveButtonTitle:@"Remove Current Picture" 
                         otherButtonTitles:@"Photo from Camera", @"Photo from Library", @"Import from Facebook", @"Import from Twitter", nil];
        } else if (fbConnected) {
            dpOptions = [[UIActionSheet alloc] 
                         initWithTitle:@"Change your picture" 
                         delegate:self
                         cancelButtonTitle:@"Cancel" 
                         destructiveButtonTitle:@"Remove Current Picture" 
                         otherButtonTitles:@"Photo from Camera", @"Photo from Library", @"Import from Facebook", nil];
        } else if (twitterConnected) {
            dpOptions = [[UIActionSheet alloc] 
                         initWithTitle:@"Change your picture" 
                         delegate:self
                         cancelButtonTitle:@"Cancel" 
                         destructiveButtonTitle:@"Remove Current Picture" 
                         otherButtonTitles:@"Photo from Camera", @"Photo from Library", @"Import from Twitter", nil];
        } else {
            dpOptions = [[UIActionSheet alloc] 
                         initWithTitle:@"Change your picture" 
                         delegate:self
                         cancelButtonTitle:@"Cancel" 
                         destructiveButtonTitle:@"Remove Current Picture" 
                         otherButtonTitles:@"Photo from Camera", @"Photo from Library", nil];
        }
    } else {
        if (fbConnected && twitterConnected) {
            dpOptions = [[UIActionSheet alloc] 
                         initWithTitle:@"Change your picture" 
                         delegate:self
                         cancelButtonTitle:@"Cancel" 
                         destructiveButtonTitle:@"Remove Current Picture" 
                         otherButtonTitles:@"Photo from Library", @"Import from Facebook", @"Import from Twitter", nil];
        } else if (fbConnected) {
            dpOptions = [[UIActionSheet alloc] 
                         initWithTitle:@"Change your picture" 
                         delegate:self
                         cancelButtonTitle:@"Cancel" 
                         destructiveButtonTitle:@"Remove Current Picture" 
                         otherButtonTitles:@"Photo from Library", @"Import from Facebook", nil];
        } else if (twitterConnected) {
            dpOptions = [[UIActionSheet alloc] 
                         initWithTitle:@"Change your picture" 
                         delegate:self
                         cancelButtonTitle:@"Cancel" 
                         destructiveButtonTitle:@"Remove Current Picture" 
                         otherButtonTitles:@"Photo from Library", @"Import from Twitter", nil];
        } else {
            dpOptions = [[UIActionSheet alloc] 
                         initWithTitle:@"Change your picture" 
                         delegate:self
                         cancelButtonTitle:@"Cancel" 
                         destructiveButtonTitle:@"Remove Current Picture" 
                         otherButtonTitles:@"Photo from Library", nil];
        }
    }
    
    dpOptions.tag = 2;
    dpOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [dpOptions showFromTabBar:appDelegate.mainTabBarController.tabBar];
    [dpOptions release];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showNavbarShadowAnimated:YES];
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    selectedDPImage = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.dimBackground = YES;
    HUD.delegate = self;
    [HUD show:YES];
    
    [appDelegate showNavbarShadowAnimated:YES];
    
    // Get Image
    NSData *imageData = UIImageJPEGRepresentation(selectedDPImage, 0.5);
    
    // Return if there is no image
    if (imageData != nil) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/uploadpicture", SH_DOMAIN]];
        
        dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
        [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
        [dataRequest setData:imageData withFileName:@"imageFile.jpg" andContentType:@"image/jpeg" forKey:@"imageFile"]; 
        [dataRequest setCompletionBlock:^{
            NSError *jsonError;
            responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if ([[responseData objectForKey:@"error"] intValue] == 0) {
                [HUD hide:YES];
                [appDelegate.strobeLight affirmativeStrobeLight];
                [global writeValue:[self.responseData objectForKey:@"responce"] forProperty:@"userPicHash"];
            } else {
                NSLog(@"Could not import FBDP!\nError:\n%@", dataRequest.responseString);
                [appDelegate.strobeLight negativeStrobeLight];
                
                if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
                }
            }
        }];
        [dataRequest setFailedBlock:^{
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
            
            // Set custom view mode.
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.dimBackground = YES;
            HUD.delegate = self;
            HUD.labelText = @"Could not connect!";
            
            [appDelegate.strobeLight negativeStrobeLight];
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:3];
            
            NSError *error = [dataRequest error];
            NSLog(@"%@", error);
        }];
        [dataRequest startAsynchronous];
    }
}

- (void)importFBDP
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.dimBackground = YES;
    HUD.delegate = self;
    [HUD show:YES];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/importfbpic", SH_DOMAIN]];
    
    dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest setCompletionBlock:^{
        NSError *jsonError;
        responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData objectForKey:@"error"] intValue] == 0) {
            [HUD hide:YES];
            [appDelegate.strobeLight affirmativeStrobeLight];
            [global writeValue:[self.responseData objectForKey:@"responce"] forProperty:@"userPicHash"];
        } else {
            NSLog(@"Could not import FBDP!\nError:\n%@", dataRequest.responseString);
            
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
            
            // Set custom view mode.
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.dimBackground = YES;
            HUD.delegate = self;
            HUD.labelText = @"Error importing photo!";
            
            [appDelegate.strobeLight negativeStrobeLight];
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:3];
            
            if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
    }];
    [dataRequest setFailedBlock:^{
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
        
        // Set custom view mode.
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.dimBackground = YES;
        HUD.delegate = self;
        HUD.labelText = @"Could not connect!";
        
        [appDelegate.strobeLight negativeStrobeLight];
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:3];
        
        NSError *error = [dataRequest error];
        NSLog(@"%@", error);
    }];
    [dataRequest startAsynchronous];
}

- (void)importTWTDP
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    
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
            
            [appDelegate.strobeLight deactivateStrobeLight];
        } else {
            // Grab the available accounts
            NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
            
            if ([twitterAccounts count] == 1) {
                // Use the first account.
                ACAccount *account = [twitterAccounts objectAtIndex:0];
                [self initiateTwitterDPImportForAccount:account];
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
                    accountList.tag = 3;
                    [accountList showFromTabBar:appDelegate.mainTabBarController.tabBar];
                    [accountList release];
                });
            }
        }
    }];
}

- (void)initiateTwitterDPImportForAccount:(ACAccount *)account
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.dimBackground = YES;
    HUD.delegate = self;
    [HUD show:YES];
    
    // Now make an authenticated request to our endpoint.
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] retain];
    [params setObject:account.username forKey:@"screen_name"];
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
             
             NSLog(@"%@", error);
         } else {
             NSError *jsonError;
             NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:responseData_twitter options:NSJSONReadingMutableLeaves error:&jsonError];
             
             if (userData) {
                 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/importtwtpic", SH_DOMAIN]];
                 
                 dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
                 [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
                 [dataRequest setPostValue:[userData objectForKey:@"profile_image_url"] forKey:@"twtPic"];
                 
                 [dataRequest setCompletionBlock:^{
                     NSError *jsonError;
                     responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
                     
                     if ([[responseData objectForKey:@"error"] intValue] == 0) {
                         [HUD hide:YES];
                         [appDelegate.strobeLight affirmativeStrobeLight];
                         [global writeValue:[self.responseData objectForKey:@"responce"] forProperty:@"userPicHash"];
                     } else {
                         NSLog(@"Could not import TWTDP!\nError:\n%@", dataRequest.responseString);
                         
                         HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
                         
                         // Set custom view mode.
                         HUD.mode = MBProgressHUDModeCustomView;
                         HUD.dimBackground = YES;
                         HUD.delegate = self;
                         HUD.labelText = @"Error importing photo!";
                         
                         [appDelegate.strobeLight negativeStrobeLight];
                         
                         [HUD show:YES];
                         [HUD hide:YES afterDelay:3];
                         
                         if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                             [self.navigationController popToRootViewControllerAnimated:YES];
                             [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
                         }
                     }
                 }];
                 [dataRequest setFailedBlock:^{
                     HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
                     
                     // Set custom view mode.
                     HUD.mode = MBProgressHUDModeCustomView;
                     HUD.dimBackground = YES;
                     HUD.delegate = self;
                     HUD.labelText = @"Could not connect!";
                     
                     [appDelegate.strobeLight negativeStrobeLight];
                     
                     [HUD show:YES];
                     [HUD hide:YES afterDelay:3];
                     
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
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (buttonIndex == 1) {
        [self dismissSettingsPanel];
        [appDelegate logout];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [doneButton release];
    [tableContents release];
	[sortedKeys release];
    [dpPicker release];
    [selectedDPImage release];
    [super dealloc];
}

@end
