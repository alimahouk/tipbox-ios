#import <QuartzCore/QuartzCore.h>
#import "Settings_ContactViewController.h"
#import "TipboxAppDelegate.h"
#import "WebViewController.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation Settings_ContactViewController

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

- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)send:(id)sender
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    NSString *msg = editor.text;
    msg = [msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (msg.length == 0) {
        return;
    }
    
    [editor resignFirstResponder];
    sendButton.enabled = NO;
    backButton.enabled = NO;
    editor.editable = NO;
    card.layer.masksToBounds = YES;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/contact", SH_DOMAIN]];
    
    dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest setPostValue:[global readProperty:@"name"] forKey:@"fullname"];
    [dataRequest setPostValue:[global readProperty:@"email"] forKey:@"email"];
    [dataRequest setPostValue:msg forKey:@"msg"];
    [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest setCompletionBlock:^{
        NSError *jsonError;
        responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        [appDelegate.strobeLight deactivateStrobeLight];
        
        if ([[responseData objectForKey:@"error"] intValue] == 0) {
            [UIView animateWithDuration:0.45 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                welcomeLabel.alpha = 0;
            } completion:^(BOOL finished){
                
            }];
            
            [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                card.frame = CGRectMake(11, screenHeight - 185, 298, 170);
                gratitude_overlay.layer.opacity = 1.0;
                gratitude_1.layer.opacity = 1.0;
            } completion:^(BOOL finished){
                
            }];
            
            [UIView animateWithDuration:0.3 delay:0.65 options:UIViewAnimationOptionCurveEaseIn animations:^{
                envelope_back.frame = CGRectMake(0, screenHeight - 190, 320, 26);
            } completion:^(BOOL finished){
                envelope_back.hidden = YES;
                card.hidden = YES;
                
                [UIView animateWithDuration:0.3 delay:0.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    envelope.frame = CGRectMake(0, -300, 320, 182);
                    gratitude_2.layer.opacity = 1.0;
                } completion:^(BOOL finished){
                    gratitude_keyboardTouchpad.enabled = YES;
                }];
            }];
        } else {
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
        [editor becomeFirstResponder];
        sendButton.enabled = YES;
        backButton.enabled = YES;
        editor.editable = YES;
        card.layer.masksToBounds = NO;
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:3];
        
        NSError *error = [dataRequest error];
        NSLog(@"%@", error);
    }];
    [dataRequest startAsynchronous];
}

- (void)gotoIdentity:(id)sender
{
    UIButton *identityButton = (UIButton *)sender;
    NSURL *url = [NSURL URLWithString:@""];
    WebViewController *webView = [[WebViewController alloc] 
                                  initWithNibName:@"WebView" 
                                  bundle:[NSBundle mainBundle]];
    
    if (identityButton.tag == 911) {        // Facebook
        url = [NSURL URLWithString:@"http://www.facebook.com/scapehouse"];
        [webView setTitle:@"Scapehouse on Facebook"];
    } else if (identityButton.tag == 912) { //Twitter
        url = [NSURL URLWithString:@"http://twitter.com/scapehouse"];
        [webView setTitle:@"Scapehouse on Twitter"];
    }
    
    webView.url = [url absoluteString];
    webView.hidesBottomBarWhenPushed = YES;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Contact Us" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:webView animated:YES];
	[webView release];
	webView = nil;
}

- (void)respondToTextInPub
{
	// We disable the Send button if the editor is empty.
	if (editor.text.length == 0) {
		sendButton.enabled = NO;
	} else {
		sendButton.enabled = YES;
	}
}

- (void)viewDidLoad
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    global = appDelegate.global;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    [self setTitle:@"Contact Us"];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    
    UIImageView *navbarShadow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"nav_bar_shadow.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0]];
    navbarShadow.frame = CGRectMake(0, 20, 320, 20);
    
    envelope = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"envelope.png"]];
    envelope.frame = CGRectMake(0, screenHeight - 190, 320, 182);
    
    envelope_back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"envelope_back.png"]];
    envelope_back.frame = CGRectMake(0, screenHeight - 198, 320, 26);
    
    UILabel *senderInfo = [[UILabel alloc] initWithFrame:CGRectMake(23, 15, 200, 13)];
    senderInfo.backgroundColor = [UIColor clearColor];
    senderInfo.textColor = [UIColor colorWithRed:50.0/255.0 green:72.0/255.0 blue:110.0/255.0 alpha:1.0];
    senderInfo.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    senderInfo.numberOfLines = 1;
    senderInfo.minimumFontSize = 8.;
    senderInfo.adjustsFontSizeToFitWidth = YES;
    senderInfo.font = [UIFont fontWithName:@"Georgia" size:MIN_SECONDARY_FONT_SIZE];
    senderInfo.text = [NSString stringWithFormat:@"From %@", [global readProperty:@"name"]];
    
    card = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
    card.frame = CGRectMake(11, 30, 298, 183);
    card.opaque = YES;
    card.userInteractionEnabled = YES;
    
    cardBgTexture = [CALayer layer];
    cardBgTexture.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]].CGColor;
    cardBgTexture.frame = CGRectMake(4, 4, 290, 175);
    cardBgTexture.opaque = YES;
    [cardBgTexture setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)]; // Sets the co-ordinates right.
    
    LPLabel *viewTitle = [[LPLabel alloc] initWithFrame:CGRectMake(0, 17, 290, 20)];
    viewTitle.backgroundColor = [UIColor clearColor];
    viewTitle.textColor = [UIColor colorWithRed:138.0/255.0 green:138.0/255.0 blue:138.0/255.0 alpha:1.0];
    viewTitle.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    viewTitle.numberOfLines = 1;
    viewTitle.minimumFontSize = 8.;
    viewTitle.adjustsFontSizeToFitWidth = YES;
    viewTitle.textAlignment = UITextAlignmentCenter;
    viewTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MAIN_FONT_SIZE];
    viewTitle.text = @"Contact Us";
    
    UIImage *buttonBg_normal = [[UIImage imageNamed:@"envelope_button_white.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
    UIImage *buttonBg_highlighted = [[UIImage imageNamed:@"envelope_button_white_pressed.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:buttonBg_normal forState:UIControlStateNormal];
    [backButton setBackgroundImage:buttonBg_highlighted forState:UIControlStateHighlighted];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithRed:138.0/255.0 green:138.0/255.0 blue:138.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [backButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
    backButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    backButton.frame = CGRectMake(10, 10, 70, 30);
    
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setBackgroundImage:buttonBg_normal forState:UIControlStateNormal];
    [sendButton setBackgroundImage:buttonBg_highlighted forState:UIControlStateHighlighted];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithRed:138.0/255.0 green:138.0/255.0 blue:138.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:225.0/255.0 alpha:1.0] forState:UIControlStateDisabled];
    [sendButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
    sendButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    sendButton.frame = CGRectMake(219, 10, 70, 30);
    sendButton.enabled = NO;
    
    CALayer *detailsSeparator = [CALayer layer];
    detailsSeparator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"solid_line_red.png"]].CGColor;
    detailsSeparator.frame = CGRectMake(10, 45, 278, 2);
    detailsSeparator.opaque = YES;
    [detailsSeparator setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
    
    editor = [[UITextView alloc] initWithFrame:CGRectMake(4, 47, 288, 100)];
    editor.backgroundColor = [UIColor clearColor];
    editor.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    editor.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    editor.tag = 911;
    editor.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToTextInPub) name:UITextViewTextDidChangeNotification object:editor]; // Listen for keystrokes (editor).
    
    pubUpperShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_upper_shadow.png"]];
    pubUpperShadow.frame = CGRectMake(11, 46, 288, 16);
    pubUpperShadow.layer.opacity = 0.0;
    
    pubLowerShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_bottom_shadow.png"]];
    pubLowerShadow.frame = CGRectMake(4, 129, 301, 17);
    pubLowerShadow.layer.opacity = 0.0;
    
    topicStrip = [CALayer layer];
    topicStrip.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor;
    topicStrip.borderWidth = 0.7;
    topicStrip.borderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
    topicStrip.frame = CGRectMake(4, 146, 290, 33);
    topicStrip.opaque = YES;
    
    externIdentityButton_fb = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [externIdentityButton_fb setBackgroundImage:[UIImage imageNamed:@"share_facebook_off.png"] forState:UIControlStateNormal];
    [externIdentityButton_fb setBackgroundImage:[UIImage imageNamed:@"share_facebook_on.png"] forState:UIControlStateHighlighted];
    [externIdentityButton_fb addTarget:self action:@selector(gotoIdentity:) forControlEvents:UIControlEventTouchUpInside];
    externIdentityButton_fb.showsTouchWhenHighlighted = YES;
    externIdentityButton_fb.tag = 911;
    externIdentityButton_fb.frame = CGRectMake(259, 146, 34, 34);
    
    externIdentityButton_twitter = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [externIdentityButton_twitter setBackgroundImage:[UIImage imageNamed:@"share_twitter_off.png"] forState:UIControlStateNormal];
    [externIdentityButton_twitter setBackgroundImage:[UIImage imageNamed:@"share_twitter_on.png"] forState:UIControlStateHighlighted];
    [externIdentityButton_twitter addTarget:self action:@selector(gotoIdentity:) forControlEvents:UIControlEventTouchUpInside];
    externIdentityButton_twitter.showsTouchWhenHighlighted = YES;
    externIdentityButton_twitter.tag = 912;
    externIdentityButton_twitter.frame = CGRectMake(231, 146, 34, 34);
    
    welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 220, 280, 32)];
    welcomeLabel.backgroundColor = [UIColor clearColor];
    welcomeLabel.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
    welcomeLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    welcomeLabel.numberOfLines = 0;
    welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    welcomeLabel.text = @"If you have a question, a comment, or just wanna say hi, go ahead! We personally read all messages.";
    
    gratitude_keyboardTouchpad = [UIButton buttonWithType:UIButtonTypeCustom];
    [gratitude_keyboardTouchpad addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    gratitude_keyboardTouchpad.frame = CGRectMake(0, 20, 320, 460);
    gratitude_keyboardTouchpad.enabled = NO;
    
    gratitude_overlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gratitude_overlay.png"]];
    gratitude_overlay.frame = CGRectMake(0, 0, 320, 460);
    gratitude_overlay.layer.opacity = 0.0;
    
    gratitude_1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gratitude_1.png"]];
    gratitude_1.frame = CGRectMake(0, 0, 320, 204);
    gratitude_1.layer.opacity = 0.0;
    
    gratitude_2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gratitude_2.png"]];
    gratitude_2.frame = CGRectMake(0, 204, 320, 256);
    gratitude_2.layer.opacity = 0.0;
    
    [editor becomeFirstResponder];
    
    [self.view addSubview:gratitude_keyboardTouchpad];
    [self.view addSubview:welcomeLabel];
    [self.view addSubview:envelope_back];
    [self.view addSubview:card];
    [self.view addSubview:envelope];
    [self.view addSubview:navbarShadow];
    [gratitude_keyboardTouchpad addSubview:gratitude_1];
    [gratitude_keyboardTouchpad addSubview:gratitude_2];
    [gratitude_keyboardTouchpad addSubview:gratitude_overlay];
    [envelope addSubview:senderInfo];
    [card.layer addSublayer:cardBgTexture];
    [card addSubview:backButton];
    [card addSubview:sendButton];
    [card addSubview:viewTitle];
    [card.layer addSublayer:detailsSeparator];
    [card addSubview:editor];
    [card addSubview:pubUpperShadow];
    [card addSubview:pubLowerShadow];
    [card.layer addSublayer:topicStrip];
    [card addSubview:externIdentityButton_fb];
    [card addSubview:externIdentityButton_twitter];
    
    [navbarShadow release];
    [senderInfo release];
    [viewTitle release];
    [super viewDidLoad];
}

#pragma mark Customizations when the view appears/disappears
- (void)viewWillAppear:(BOOL)animated
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBounds.size.height;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    [self.navigationController.view setFrame:CGRectMake(0, 0, 320, screenHeight + 20)];
    appDelegate.strobeLight.frame = CGRectMake(0, 11, 320, 20);
    
    [appDelegate tabbarShadowMode_nobar];
    [appDelegate navbarShadowMode_navbar];
    [appDelegate hideNavbarShadowAnimated:YES];
    [appDelegate showTabbarShadowAnimated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [self.navigationController.view setFrame:CGRectMake(0, 0, 320, screenHeight)];
    [appDelegate.strobeLight deactivateStrobeLight];
     appDelegate.strobeLight.frame = CGRectMake(0, 54, 320, 20);
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

#pragma mark UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 911) { // Editor
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.bounds;
        CGSize size = scrollView.contentSize;
        UIEdgeInsets inset = scrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        
        if (y >= h) { // For the lower shadow.
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.2];
            pubLowerShadow.alpha = 0.0;
            [UIView commitAnimations];
        } else {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.2];
            pubLowerShadow.alpha = 1.0;
            [UIView commitAnimations];
        }
        
        if (scrollView.contentOffset.y > 0) { // For the upper shadow.
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.2];
            pubUpperShadow.alpha = 1.0;
            [UIView commitAnimations];
        } else {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.2];
            pubUpperShadow.alpha = 0.0;
            [UIView commitAnimations];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    global = nil;
    HUD.delegate = nil;
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [envelope release];
    [envelope_back release];
    [card release];
    [editor release];
    [pubUpperShadow release];
    [pubLowerShadow release];
    [externIdentityButton_fb release];
    [externIdentityButton_twitter release];
    [welcomeLabel release];
    [gratitude_overlay release];
    [gratitude_1 release];
    [gratitude_2 release];
    [super dealloc];
}


@end
