#import <Twitter/Twitter.h>
#import "WebViewController.h"
#import "TipboxAppDelegate.h"
#import "Publisher.h"

@implementation WebViewController

@synthesize lowerToolbar, browser, backButton, forwardButton, refreshButton, url;

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

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	// Remove HUD from screen when the HUD was hidden.
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}

- (void)newTipUsingSelection
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    NSString *selection = [browser stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    
    [appDelegate navbarShadowMode_navbar];
    [appDelegate tabbarShadowMode_nobar];
    [appDelegate showNavbarShadowAnimated:YES];
    [appDelegate showTabbarShadowAnimated:YES];
    
    Publisher *pub = [[Publisher alloc] init];
    UINavigationController *publisherNavigationController = [[UINavigationController alloc] initWithRootViewController:pub];
    pub.category = -1; // Default value.
	[appDelegate.mainTabBarController presentModalViewController:publisherNavigationController animated:true];
    pub.editor.text = selection;
	[pub release];
    [publisherNavigationController release];
}

- (void)viewDidLoad
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showNavbarShadowAnimated:YES];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:URL
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:120.0];
    
    browser.delegate = self;
    [browser loadRequest:theRequest];
    
    [super viewDidLoad];
}

#pragma mark Customizations when the view appears/disappears
- (void)viewWillAppear:(BOOL)animated
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate navbarShadowMode_navbar];
    [appDelegate tabbarShadowMode_toolbar];
    [appDelegate showNavbarShadowAnimated:YES];
    [appDelegate showTabbarShadowAnimated:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count - 2] == self) { // View is disappearing because a new view controller was pushed onto the stack
        
        
    } else if ([viewControllers indexOfObject:self] == NSNotFound) { // View is disappearing because it was popped from the stack
        HUD.delegate = nil;
        browser.delegate = nil;
        [appDelegate.strobeLight deactivateStrobeLight];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    UIMenuItem *newTipItem = [[[UIMenuItem alloc] initWithTitle:@"New Tip" action:@selector(newTipUsingSelection)] autorelease];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:newTipItem, nil]];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[UIMenuController sharedMenuController] setMenuItems:nil];
    [super viewDidDisappear:animated];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (browser != nil) {
        if (action == @selector(newTipUsingSelection)) {
            return YES;
        }
    }
    
    return [super canPerformAction:action withSender:sender];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight negativeStrobeLight];
    
    if ([error code] != -999) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross_white.png"]] autorelease];
        
        // Set custom view mode.
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.dimBackground = YES;
        HUD.delegate = self;
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:3];
        
        NSLog(@"%@", error);
    }
    
    loading = NO;
    [refreshButton setImage:[UIImage imageNamed:@"browser_reload.png"]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    loading = YES;
    
    [refreshButton setImage:[UIImage imageNamed:@"browser_cancel.png"]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *theTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self setTitle:theTitle];
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight deactivateStrobeLight];
    loading = NO;
    
    [refreshButton setImage:[UIImage imageNamed:@"browser_reload.png"]];
    
    if (browser.canGoBack) {
        backButton.enabled = YES;
    } else {
        backButton.enabled = NO;
    }
    
    if (browser.canGoForward) {
        forwardButton.enabled = YES;
    } else {
        forwardButton.enabled = NO;
    }
}

#pragma mark Browser navigation
- (IBAction)goBack:(id)sender
{
    [browser goBack];
}

- (IBAction)goForward:(id)sender
{
    [browser goForward];
}

- (IBAction)reloadPage:(id)sender
{
    if (loading) {
        [browser stopLoading];
    } else {
        NSURL *URL = [NSURL URLWithString:url];
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:URL
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:120.0];
        [browser loadRequest:theRequest];
    }
}

- (IBAction)showBrowserOptions:(id)sender
{
    NSString *selection = [browser stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    
    if (selection.length > 0) {
        if ([MFMessageComposeViewController canSendText]) {
            browserOptions = [[UIActionSheet alloc] 
                              initWithTitle:url
                              delegate:self
                              cancelButtonTitle:@"Cancel" 
                              destructiveButtonTitle:nil 
                              otherButtonTitles:@"Open in Safari", @"Copy Link", @"Mail Link", @"Tweet", @"Message", @"New Tip Using Selection", nil];
        } else {
            browserOptions = [[UIActionSheet alloc] 
                              initWithTitle:url
                              delegate:self
                              cancelButtonTitle:@"Cancel" 
                              destructiveButtonTitle:nil 
                              otherButtonTitles:@"Open in Safari", @"Copy Link", @"Mail Link", @"Tweet", @"New Tip Using Selection", nil];
        }
    } else {
        if ([MFMessageComposeViewController canSendText]) {
            browserOptions = [[UIActionSheet alloc] 
                              initWithTitle:url
                              delegate:self
                              cancelButtonTitle:@"Cancel" 
                              destructiveButtonTitle:nil 
                              otherButtonTitles:@"Open in Safari", @"Copy Link", @"Mail Link", @"Tweet", @"Message", nil];
        } else {
            browserOptions = [[UIActionSheet alloc] 
                              initWithTitle:url
                              delegate:self
                              cancelButtonTitle:@"Cancel" 
                              destructiveButtonTitle:nil 
                              otherButtonTitles:@"Open in Safari", @"Copy Link", @"Mail Link", @"Tweet", nil];
        }
    }
    
	browserOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    browserOptions.tag = 100;
	[browserOptions showFromToolbar:lowerToolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (actionSheet.tag == 100) { // Browser options
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        
        if (buttonIndex == 0) {                                                     // Open in Safari
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else if (buttonIndex == 1) {                                              // Copy Link
            pasteboard.string = url;
        } else if (buttonIndex == 2) {                                              // Mail Link
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            
            NSString *emailBody = [NSString stringWithFormat:@"<a href='%@'>%@</a> <em style='color:#777;'>(via @<a href=\"http://twitter.com\">Scapehouse</a>)</em>", url, url]; // Fill out the email body text.
            [picker setSubject:url];
            [picker setMessageBody:emailBody isHTML:YES]; // Depends. Mostly YES, unless you want to send it as plain text (boring).
            
            picker.navigationBar.tintColor = [UIColor colorWithRed:162/255.0 green:165/255.0 blue:152/255.0 alpha:1.0];
            
            [appDelegate navbarShadowMode_navbar];
            [appDelegate tabbarShadowMode_nobar];
            [self presentModalViewController:picker animated:YES];
            [picker release];
        } else if (buttonIndex == 3) {                                                  // Tweet
            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init]; // Create the tweet sheet.
            [tweetSheet setInitialText:@"#Tipbox (by @Scapehouse)"];
            [tweetSheet addURL:[NSURL URLWithString:url]];
            
            tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result) { // Set a blocking handler for the tweet sheet.
                dispatch_async(dispatch_get_main_queue(), ^{            
                    [self dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                });
            };
            
            // Show the tweet sheet!
            [self presentModalViewController:tweetSheet animated:YES];
            [tweetSheet release];
        } else if (buttonIndex == 4 && [MFMessageComposeViewController canSendText]) {  // Message
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate = self;
            
            NSString *messageBody = [NSString stringWithFormat:@"Check this out: %@ (by @Scapehouse)", url]; // Fill out the body text.
            [picker setBody:messageBody];
            
            picker.navigationBar.tintColor = [UIColor colorWithRed:162/255.0 green:165/255.0 blue:152/255.0 alpha:1.0];
            
            [appDelegate navbarShadowMode_navbar];
            [appDelegate tabbarShadowMode_nobar];
            [self presentModalViewController:picker animated:YES];
            [picker release];
        } else if ((buttonIndex == 5 && actionSheet.numberOfButtons == 7) || (buttonIndex == 4 && actionSheet.numberOfButtons == 6)) { // New Tip Using Selection
            [self newTipUsingSelection];
        }
        
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [lowerToolbar release];
    [browser release];
    [backButton release];
    [forwardButton release];
    [refreshButton release];
    [browserOptions release];
    [super dealloc];
}


@end
