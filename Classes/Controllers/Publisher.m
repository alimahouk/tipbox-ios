#import <QuartzCore/QuartzCore.h>
#import "Publisher.h"
#import "SCAppUtils.h"
#import "Publisher_DataEntry.h"
#import "EGOImageView.h"
#import "TipboxAppDelegate.h"
#import "SocialConnectionsManager.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation Publisher

@synthesize editor, fbShareButton, twitterShareButton;
@synthesize topicButtonLabel, locationManager, category, subcategory, topic, topicid;
@synthesize selectedSubcategory, selectedCategoryButtonIcon;
@synthesize selectedCategoryButtonTitle, selectedCategoryButtonSubtitle;

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

- (void)showCategoryView
{    
    Publisher_DataEntry *dataEntryView = [[Publisher_DataEntry alloc] init];
	
    dataEntryView.configuration = @"cat";
    dataEntryView.category = category;
    dataEntryView.subcategory = subcategory;
    dataEntryView.selectedSubcategory = selectedSubcategory;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"New Tip" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:dataEntryView animated:YES];
	[dataEntryView release];
    dataEntryView = nil;
}

- (void)showTopicSearchView
{
    Publisher_DataEntry *dataEntryView = [[Publisher_DataEntry alloc] init];
	
    dataEntryView.configuration = @"topic";
    dataEntryView.topic = topic;
    dataEntryView.topicid = topicid;
    dataEntryView.category = category;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"New Tip" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:dataEntryView animated:YES];
	[dataEntryView release];
    dataEntryView = nil;
}

- (void)todoListTapped
{
    if (category == -1 || subcategory == -1) {
        [self showCategoryView];
        return;
    }
    
    if (self.topic.length == 0) {
        [self showTopicSearchView];
        return;
    }
    
    if (editor.text.length == 0) {
        [pubScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [editor becomeFirstResponder];
        return;
    }
}

- (void)respondToTextInPub
{
    NSString *editorTxt = editor.text;
    editorTxt = [editorTxt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (editorTxt.length > 0) {
        todoList_4.image = [UIImage imageNamed:@"tip_todo_4_done.png"];
    } else {
        todoList_4.image = [UIImage imageNamed:@"tip_todo_4.png"];
    }
    
    /*NSRegularExpression *whitespaceRegex = [NSRegularExpression
                                            regularExpressionWithPattern:@"\\s{2,}"
                                            options:0
                                            error:NULL];
    
    NSArray *allWhitespace = [whitespaceRegex matchesInString:editorTxt options:0 range:NSMakeRange(0, editorTxt.length)];
    
    for (NSTextCheckingResult *whitespaceMatch in allWhitespace) {
        NSString *whitespace = [editorTxt substringWithRange:whitespaceMatch.range];
        NSLog(@"'%@'", whitespace);
        editorTxt = [editorTxt stringByReplacingOccurrencesOfString:whitespace withString:@" "];
    }*/
    
    // Update the char counter.
    int charLimit = 200;
    charsLeft = charLimit - editorTxt.length;
    
    NSRegularExpression *urlRegex = [NSRegularExpression 
                                     regularExpressionWithPattern:@"(?i)\\b((?:https?://|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))" 
                                     options:0 
                                     error:NULL];
    
    NSArray *allLinks = [urlRegex matchesInString:editorTxt options:0 range:NSMakeRange(0, editorTxt.length)];
    
    // For every link, subtract 20 from the char limit.
    for (NSTextCheckingResult *urlMatch in allLinks) {
        NSString *link = [editorTxt substringWithRange:urlMatch.range];
        
        if (link.length > 20) {
            charsLeft += link.length - 20;
        }
        
    }
    
    if (charsLeft < 0) {
        charChounter.textColor = [UIColor redColor]; // Some visual feedback to indicate that you're going over the limit.
    } else {
        charChounter.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    }
    
    charChounter.text = [NSString stringWithFormat:@"%d", charsLeft];
}

#pragma mark UITextViewDelegate methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    editorPlaceholder.hidden = YES;
    [pubScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
    if (editor.text.length == 0) {
        editorPlaceholder.hidden = NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)postTip:(id)sender
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *tipTxt = editor.text;
    NSString *topic_truncated = self.topic;
    int postToFB, postToTwt;
    
    [editor resignFirstResponder];
    
    if (category != -1 && subcategory != -1 && tipTxt.length > 0 && topic_truncated.length == 0) {
        [pubScrollView setContentOffset:CGPointMake(0, -150) animated:YES];
        
        // If only the topic is missing, make the topic strip pulsate to attract attention to it.
        // This'll make users familiar with the button in case they missed it.
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        [pulseAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [pulseAnimation setFromValue:(id)[UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor];
        [pulseAnimation setToValue:(id)[UIColor colorWithRed:254.0/255.0 green:118.0/255.0 blue:118.0/255.0 alpha:1.0].CGColor];
        [pulseAnimation setAutoreverses:YES];
        [pulseAnimation setDuration:0.5];
        [pulseAnimation setRepeatCount:4];
        [topicStrip addAnimation:pulseAnimation forKey:nil];
    }
    
    // Cases where we don't post. Instead, we show the todo list.
    if (category == -1 || subcategory == -1 || topic_truncated.length == 0 || tipTxt.length == 0) {
        [pubScrollView setContentOffset:CGPointMake(0, -150) animated:YES];
        return;
    }
    
    if (self.topic.length > 32) {
        topic_truncated = [self.topic substringToIndex:32];
    }
    
    if (fbShareButton.activated) {
        postToFB = 1;
    } else {
        postToFB = 0;
    }
    
    if (twitterShareButton.activated) {
        postToTwt = 1;
    } else {
        postToTwt = 0;
    }
    
    [tip setObject:appDelegate.SHToken forKey:@"token"];
    [tip setObject:tipTxt forKey:@"content"];
    [tip setObject:[NSNumber numberWithInt:topicid] forKey:@"topicid"];
    [tip setObject:topic_truncated forKey:@"topicContent"];
    [tip setObject:[NSNumber numberWithInt:subcategory] forKey:@"catid"];
    [tip setObject:[NSNumber numberWithFloat:currentLocation.longitude] forKey:@"location_long"];
    [tip setObject:[NSNumber numberWithFloat:currentLocation.latitude] forKey:@"location_lat"];
    [tip setObject:[NSNumber numberWithInt:postToFB] forKey:@"fbPost"];
    [tip setObject:[NSNumber numberWithInt:postToTwt] forKey:@"twtPost"];
    
    if (charsLeft >= 0) {
        if (charsLeft > 155) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Tip is too short!"
                                  message:@"Hmmm! That tip looks too short to be actually useful. Add a few more details!" delegate:self
                                  cancelButtonTitle:@"Back"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else {
            [appDelegate postTip:tip];
            appDelegate.mainTabBarController.tabBar.hidden = NO;
            [self dismissModalViewControllerAnimated:YES];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Tip is too long!"
                              message:@"Your tip exceeds 200 characters! Go back and edit it?" delegate:self
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:@"Continue", nil];
        alert.tag = 1;
        [alert show];
        [alert release];
    }
}

- (void)dismissPublisher:(id)sender
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // We dismiss the publisher if the user didn't enter any text, otherwise we display a confirmation alert.
    if ((editor.text.length == 0)) {
        appDelegate.mainTabBarController.tabBar.hidden = NO;
        [appDelegate showNavbarShadowAnimated:YES];
        [self dismissModalViewControllerAnimated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Discard Tip"
                              message:@"Are you sure you want to cancel? You entered some text." delegate:self
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:@"Discard Tip", nil];
        alert.tag = 0;
        [alert show];
        [alert release];
    }
}

- (void)activateFb
{
    if (![[global readProperty:@"fbConnected"] boolValue]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Facebook"
                              message:@"You're not currently connected to Facebook. Connect now?" delegate:self
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:@"Connect", nil];
        alert.tag = 2;
        [alert show];
        [alert release];
        
        return;
    }
    
    if (fbShareButton.activated) {
        [fbShareButton setBackgroundImage:[UIImage imageNamed:@"share_facebook_off.png"] forState:UIControlStateNormal];
        fbShareButton.activated = NO;
    } else {
        [fbShareButton setBackgroundImage:[UIImage imageNamed:@"share_facebook_on.png"] forState:UIControlStateNormal];
        fbShareButton.activated = YES;
    }
}

- (void)activateTwitter
{
    if (![[global readProperty:@"twitterConnected"] boolValue]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Twitter"
                              message:@"You're not currently connected to Twitter. Connect now?" delegate:self
                              cancelButtonTitle:@"Back"
                              otherButtonTitles:@"Connect", nil];
        alert.tag = 2;
        [alert show];
        [alert release];
        
        return;
    }
    
    if (twitterShareButton.activated) {
        [twitterShareButton setBackgroundImage:[UIImage imageNamed:@"share_twitter_off.png"] forState:UIControlStateNormal];
        twitterShareButton.activated = NO;
    } else {
        [twitterShareButton setBackgroundImage:[UIImage imageNamed:@"share_twitter_on.png"] forState:UIControlStateNormal];
        twitterShareButton.activated = YES;
    }
}

- (void)viewDidLoad
{
    selectedSubcategory = -1;
    subcategory = -1;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    global = appDelegate.global;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    // Set up the nav bar.
    [SCAppUtils customizeNavigationController:self.navigationController];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:192.0/255.0 green:133.0/255.0 blue:87.0/255.0 alpha:1.0];
    [self setTitle:@"New Tip"];
    
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissPublisher:)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = cancelButton;
    
    postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(postTip:)];
    self.navigationController.navigationBar.topItem.rightBarButtonItem = postButton;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToTextInPub) name:UITextViewTextDidChangeNotification object:editor]; // Listen for keystrokes (editor).
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    tip = [[NSMutableDictionary alloc] init];
    
    pubScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, screenHeight - 20)];
    pubScrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    pubScrollView.contentSize = CGSizeMake(320, screenHeight - 19);
    pubScrollView.scrollsToTop = NO;
    pubScrollView.opaque = YES;
    
    CALayer *dottedDivider_todoList = [CALayer layer];
    dottedDivider_todoList.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_grey.png"]].CGColor;
    dottedDivider_todoList.frame = CGRectMake(0, 40, 320, 2);
    dottedDivider_todoList.opaque = YES;
    [dottedDivider_todoList setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
    
    todoList_title = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tip_todo_list_title.png"]];
    todoList_title.frame = CGRectMake(5, 15, 113, 15);
    todoList_title.opaque = YES;
    
    todoList_1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tip_todo_1.png"]];
    todoList_1.frame = CGRectMake(0, 55, 320, 15);
    todoList_1.opaque = YES;
    
    todoList_2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tip_todo_2.png"]];
    todoList_2.frame = CGRectMake(0, 75, 320, 15);
    todoList_2.opaque = YES;
    
    todoList_3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tip_todo_3.png"]];
    todoList_3.frame = CGRectMake(0, 95, 320, 15);
    todoList_3.opaque = YES;
    
    todoList_4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tip_todo_4.png"]];
    todoList_4.frame = CGRectMake(0, 115, 320, 15);
    todoList_4.opaque = YES;
    
    todoList_5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tip_todo_5.png"]];
    todoList_5.frame = CGRectMake(0, 135, 320, 15);
    todoList_5.opaque = YES;
    
    UIButton *todoListContainer = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [todoListContainer addTarget:self action:@selector(todoListTapped) forControlEvents:UIControlEventTouchUpInside];
    todoListContainer.frame = CGRectMake(0, -150, 320, 150);
    
    card = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
    card.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    card.frame = CGRectMake(6, 10, 308, screenHeight - 297);
    card.opaque = YES;
    card.userInteractionEnabled = YES;
    
    cardBgTexture = [CALayer layer];
    cardBgTexture.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]].CGColor;
    cardBgTexture.frame = CGRectMake(4, 4, 300, screenHeight - 305);
    cardBgTexture.opaque = YES;
    [cardBgTexture setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)]; // Sets the co-ordinates right.
    
    UIImage *userThmbnlOverlay = [[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:3.0];
    UIImageView *userThmbnlOverlayView = [[UIImageView alloc] initWithImage:userThmbnlOverlay];
    userThmbnlOverlayView.frame = CGRectMake(9, 10, 36, 36);
    
    EGOImageView *userThmbnl = [[EGOImageView alloc] initWithFrame:CGRectMake(12, 12, 30, 30)];
    NSString *profilePicPath = [NSString stringWithFormat:@"http://%@/userphotos/%d/profile/m_%@.jpg", SH_DOMAIN, [[global readProperty:@"userid"] intValue], [global readProperty:@"userPicHash"]];
	userThmbnl.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
    userThmbnl.imageURL = [NSURL URLWithString:profilePicPath];
    userThmbnl.layer.shouldRasterize = YES;
    userThmbnl.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    LPLabel *storyActor = [[LPLabel alloc] initWithFrame:CGRectMake(52, 11, 185, 20)];
    storyActor.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    storyActor.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    storyActor.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    storyActor.shadowOffset = CGSizeMake(0, 1);
    storyActor.numberOfLines = 1;
    storyActor.minimumFontSize = 8.;
    storyActor.adjustsFontSizeToFitWidth = YES;
    storyActor.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
    storyActor.opaque = YES;
    
    LPLabel *usernameLabel = [[LPLabel alloc] initWithFrame:CGRectMake(52, 29, 185, 20)];
    usernameLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    usernameLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    usernameLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    usernameLabel.numberOfLines = 1;
    usernameLabel.minimumFontSize = 8.;
    usernameLabel.adjustsFontSizeToFitWidth = YES;
    usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    usernameLabel.opaque = YES;
    
    charChounter = [[LPLabel alloc] initWithFrame:CGRectMake(249, 20, 50, 20)];
    charChounter.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    charChounter.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    charChounter.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    charChounter.numberOfLines = 1;
    charChounter.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
    charChounter.textAlignment = UITextAlignmentRight;
    charChounter.text = @"200";
    charChounter.opaque = YES;
    
    CALayer *detailsSeparator = [CALayer layer];
    detailsSeparator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"solid_line_red.png"]].CGColor;
    detailsSeparator.frame = CGRectMake(10, 53, 288, 2);
    detailsSeparator.opaque = YES;
    [detailsSeparator setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
    
    editor = [[UITextView alloc] initWithFrame:CGRectMake(4, 56, 298, screenHeight - 391)];
    editor.backgroundColor = [UIColor clearColor];
    editor.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    editor.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    editor.returnKeyType = UIReturnKeyDone;
    editor.tag = 911;
    editor.delegate = self;
    
    editorPlaceholder = [[LPLabel alloc] initWithFrame:CGRectMake(8, 10, 200, 19)];
    editorPlaceholder.backgroundColor = [UIColor clearColor];
    editorPlaceholder.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    editorPlaceholder.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    editorPlaceholder.shadowOffset = CGSizeMake(0, 1);
    editorPlaceholder.numberOfLines = 1;
    editorPlaceholder.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    editorPlaceholder.text = @"Leave your tip here...";
    
    pubUpperShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_upper_shadow.png"]];
    pubUpperShadow.frame = CGRectMake(11, 54, 288, 16);
    pubUpperShadow.layer.opacity = 0.0;
    
    pubLowerShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pub_bottom_shadow.png"]];
    pubLowerShadow.frame = CGRectMake(4, card.bounds.size.height - 52, 301, 17);
    pubLowerShadow.layer.opacity = 0.0;
    
    fbShareButton = [[ToggleButton alloc] initWithFrame:CGRectMake(271, card.bounds.size.height - 37, 34, 34)];
    [fbShareButton setBackgroundImage:[UIImage imageNamed:@"share_facebook_off.png"] forState:UIControlStateNormal];
    fbShareButton.showsTouchWhenHighlighted = YES;
    fbShareButton.activated = NO;
    
    twitterShareButton = [[ToggleButton alloc] initWithFrame:CGRectMake(243, card.bounds.size.height - 37, 34, 34)];
    [twitterShareButton setBackgroundImage:[UIImage imageNamed:@"share_twitter_off.png"] forState:UIControlStateNormal];
    twitterShareButton.showsTouchWhenHighlighted = YES;
    twitterShareButton.activated = NO;
    
    [fbShareButton addTarget:self action:@selector(activateFb) forControlEvents:UIControlEventTouchUpInside];
    [twitterShareButton addTarget:self action:@selector(activateTwitter) forControlEvents:UIControlEventTouchUpInside];
    
    topicStrip = [CALayer layer];
    topicStrip.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor;
    topicStrip.borderWidth = 0.7;
    topicStrip.borderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
    topicStrip.frame = CGRectMake(4, card.bounds.size.height - 37, 300, 33);
    topicStrip.opaque = YES;
    
    topicButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    topicButton.showsTouchWhenHighlighted = YES;
    [topicButton addTarget:self action:@selector(showTopicSearchView) forControlEvents:UIControlEventTouchUpInside];
    topicButton.frame = CGRectMake(4, card.bounds.size.height - 37, 237, 33);
    
	topicButtonIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_bar_topics.png"]];
    topicButtonIconView.frame = CGRectMake(7, 1, 30, 30);
	
	topicButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 7, 194, 19)];
    topicButtonLabel.backgroundColor = [UIColor clearColor];
    topicButtonLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    topicButtonLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    topicButtonLabel.shadowOffset = CGSizeMake(0, 1);
    topicButtonLabel.numberOfLines = 1;
    topicButtonLabel.minimumFontSize = 8.;
    topicButtonLabel.adjustsFontSizeToFitWidth = YES;
    topicButtonLabel.font = [UIFont fontWithName:@"Georgia" size:MIN_MAIN_FONT_SIZE];
    topicButtonLabel.text = self.topic;
    
    CALayer *categorySelectionDivider = [CALayer layer];
    categorySelectionDivider.backgroundColor = [UIColor colorWithRed:199/255.0 green:199/255.0 blue:199/255.0 alpha:1.0].CGColor;
    categorySelectionDivider.frame = CGRectMake(0, 0, 320, 1);
    
    UIImageView *selectedCategoryButtonUpperShadow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"nav_bar_shadow.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0]];
    selectedCategoryButtonUpperShadow.frame = CGRectMake(0, 1, 320, 20);
    
    selectedCategoryButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    selectedCategoryButton.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    [selectedCategoryButton addTarget:self action:@selector(showCategoryView) forControlEvents:UIControlEventTouchUpInside];
    [selectedCategoryButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    selectedCategoryButton.frame = CGRectMake(0, screenHeight - 279, 320, 400);
    selectedCategoryButton.opaque = YES;
    selectedCategoryButton.tag = 0;
    
    selectedCategoryButtonIcon = [[UIImageView alloc] init];
    selectedCategoryButtonIcon.frame = CGRectMake(20, 90, 30, 30);
    
    selectedCategoryButtonTitle = [[LPLabel alloc] initWithFrame:CGRectMake(70, 83, 240, 20)];
    selectedCategoryButtonTitle.backgroundColor = [UIColor clearColor];
    selectedCategoryButtonTitle.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    selectedCategoryButtonTitle.font = [UIFont boldSystemFontOfSize:16];
    selectedCategoryButtonTitle.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    selectedCategoryButtonTitle.shadowOffset = CGSizeMake(0, 1);
    selectedCategoryButtonTitle.numberOfLines = 1;
    selectedCategoryButtonTitle.minimumFontSize = 8.;
    selectedCategoryButtonTitle.adjustsFontSizeToFitWidth = YES;
    selectedCategoryButtonTitle.text = @"";
    
    selectedCategoryButtonSubtitle = [[LPLabel alloc] initWithFrame:CGRectMake(70, 98, 240, 33)];
    selectedCategoryButtonSubtitle.backgroundColor = [UIColor clearColor];
    selectedCategoryButtonSubtitle.textColor = [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
    selectedCategoryButtonSubtitle.font = [UIFont systemFontOfSize:16];
    selectedCategoryButtonSubtitle.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    selectedCategoryButtonSubtitle.shadowOffset = CGSizeMake(0, 1);
    selectedCategoryButtonSubtitle.numberOfLines = 1;
    selectedCategoryButtonSubtitle.minimumFontSize = 8.;
    selectedCategoryButtonSubtitle.adjustsFontSizeToFitWidth = YES;
    selectedCategoryButtonSubtitle.text = @"";
    
    storyActor.text = [global readProperty:@"name"];
    usernameLabel.text = [NSString stringWithFormat:@"@%@", [global readProperty:@"username"]];
    
    [self.view addSubview:pubScrollView];
    [pubScrollView addSubview:todoListContainer];
    [todoListContainer.layer addSublayer:dottedDivider_todoList];
    [todoListContainer addSubview:todoList_title];
    [todoListContainer addSubview:todoList_1];
    [todoListContainer addSubview:todoList_2];
    [todoListContainer addSubview:todoList_3];
    [todoListContainer addSubview:todoList_4];
    [todoListContainer addSubview:todoList_5];
    [pubScrollView addSubview:card];
    [card.layer addSublayer:cardBgTexture];
    [card addSubview:userThmbnlOverlayView];
    [card addSubview:userThmbnl];
    [card addSubview:storyActor];
    [card addSubview:usernameLabel];
    [card addSubview:charChounter];
    [card.layer addSublayer:detailsSeparator];
    [card addSubview:editor];
    [card addSubview:pubUpperShadow];
    [card addSubview:pubLowerShadow];
    [card.layer addSublayer:topicStrip];
    [card addSubview:topicButton];
    [card addSubview:fbShareButton];
    [card addSubview:twitterShareButton];
    [editor addSubview:editorPlaceholder];
    [pubScrollView addSubview:selectedCategoryButton];
    [selectedCategoryButton addSubview:selectedCategoryButtonUpperShadow];
    [selectedCategoryButton.layer addSublayer:categorySelectionDivider];
    [selectedCategoryButton addSubview:selectedCategoryButtonIcon];
    [selectedCategoryButton addSubview:selectedCategoryButtonTitle];
    [selectedCategoryButton addSubview:selectedCategoryButtonSubtitle];
    [topicButton addSubview:topicButtonIconView];
    [topicButton addSubview:topicButtonLabel];
    
    if (category == 0) {
        selectedCategoryButtonIcon.image = [UIImage imageNamed:@"pub_category_thing.png"];
        selectedCategoryButtonTitle.text = @"Thing";
        [editor becomeFirstResponder];
    } else if (category == 1) {
        selectedCategoryButtonIcon.image = [UIImage imageNamed:@"pub_category_place.png"];
        selectedCategoryButtonTitle.text = @"Place";
        [editor becomeFirstResponder];
    } else if (category == 2) {
        subcategory = 40;
        
        selectedCategoryButtonIcon.image = [UIImage imageNamed:@"pub_category_idea.png"];
        selectedCategoryButtonTitle.text = @"Idea";
        [editor becomeFirstResponder];
    } else if (category == -1) { // Blank publisher.
        selectedCategoryButtonIcon.image = [UIImage imageNamed:@"pub_category_unknown.png"];
        selectedCategoryButtonTitle.text = @"Choose a category...";
        selectedCategoryButtonSubtitle.text = @"E.g. Are you talking about \"Apple\" the company or the fruit?";
        
        if (self.topic.length == 0) {
            topicButtonLabel.text = @"What's this tip about?";
        }
    }
    
    [todoListContainer release];
    [userThmbnl release];
    [userThmbnlOverlayView release];
    [storyActor release];
    [usernameLabel release];
    [selectedCategoryButtonUpperShadow release];
    [super viewDidLoad];
}

#pragma mark Customizations when the view appears/disappears
- (void)viewWillAppear:(BOOL)animated
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate navbarShadowMode_navbar];
    [appDelegate tabbarShadowMode_nobar];
    [appDelegate showNavbarShadowAnimated:YES];
    [appDelegate showTabbarShadowAnimated:YES];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (category != -1) {
        todoList_1.image = [UIImage imageNamed:@"tip_todo_1_done.png"];
    } else {
        todoList_1.image = [UIImage imageNamed:@"tip_todo_1.png"];
    }
    
    if (subcategory != -1) {
        todoList_2.image = [UIImage imageNamed:@"tip_todo_2_done.png"];
    } else {
        todoList_2.image = [UIImage imageNamed:@"tip_todo_2.png"];
    }
    
    if (self.topic.length > 0) {
        todoList_3.image = [UIImage imageNamed:@"tip_todo_3_done.png"];
    } else {
        todoList_3.image = [UIImage imageNamed:@"tip_todo_3.png"];
    }
    
    if (editor.text.length > 0) {
        todoList_4.image = [UIImage imageNamed:@"tip_todo_4_done.png"];
    } else {
        todoList_4.image = [UIImage imageNamed:@"tip_todo_4.png"];
    }
    
    [super viewDidAppear:animated];
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

#pragma mark -
#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation.coordinate;
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusAuthorized || ![CLLocationManager locationServicesEnabled]) {
        currentLocation = CLLocationCoordinate2DMake(9999, 9999);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    currentLocation = CLLocationCoordinate2DMake(9999, 9999);
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        if (buttonIndex == 1) { // Dismiss Publisher
            TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate showNavbarShadowAnimated:YES];
            appDelegate.mainTabBarController.tabBar.hidden = NO;
            [self dismissModalViewControllerAnimated:YES];
        }
    } else if (alertView.tag == 1) {
        if (buttonIndex == 1) { // Go ahead with posting truncated tip.
            TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.mainTabBarController.tabBar.hidden = NO;
            [appDelegate showNavbarShadowAnimated:YES];
            
            
            // NOTE: We need to take into account all the long links,
            // because they only count as 20 chars in that case.
            // This next block is truly a crown jewel.
            NSRegularExpression *urlRegex = [NSRegularExpression 
                                             regularExpressionWithPattern:@"(?i)\\b((?:https?://|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))" 
                                             options:0 
                                             error:NULL];
            
            NSArray *allLinks = [urlRegex matchesInString:editor.text options:0 range:NSMakeRange(0, editor.text.length)];
            int linkLen = 0;
            int linkBoundary = 180;
            int actualLimit = 200;
            
            // For every link, subtract 20 from the char limit.
            for (NSTextCheckingResult *urlMatch in allLinks) {
                NSString *link = [editor.text substringWithRange:urlMatch.range];
                int linkIndex = urlMatch.range.location;
                
                if (link.length > 20) {
                    if (linkIndex < linkBoundary + linkLen) {
                        linkLen += link.length;
                        
                        if (linkBoundary > 0) {
                            linkBoundary -= 20;
                            actualLimit -= 20;
                        }
                    }
                }
            }
            
            int index = linkLen + actualLimit;
            [tip setObject:[editor.text substringToIndex:index] forKey:@"content"]; // Add padding for each shortened link.
            
            [appDelegate postTip:tip];
            [self dismissModalViewControllerAnimated:YES];
        }
    } else if (alertView.tag == 2) { // Current user not connected to Facebook.
        if (buttonIndex == 1) {
            SocialConnectionsManager *connectionsManager = [[SocialConnectionsManager alloc] init];
            
            self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"New Tip" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
            [self.navigationController pushViewController:connectionsManager animated:YES];
            [connectionsManager release];
            connectionsManager = nil;
        }
    }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [pubScrollView release];
    [editor release];
    [editorPlaceholder release];
    [pubUpperShadow release];
    [pubLowerShadow release];
    [cancelButton release];
    [postButton release];
    [fbShareButton release];
    [twitterShareButton release];
    [charChounter release];
    [card release];
    [topicButton release];
    [topicButtonIconView release];
    [topicButtonLabel release];
    [selectedCategoryButton release];
    [selectedCategoryButtonIcon release];
    [selectedCategoryButtonTitle release];
    [selectedCategoryButtonSubtitle release];
    [locationManager release];
    [tip release];
    [todoList_title release];
    [todoList_1 release];
    [todoList_2 release];
    [todoList_3 release];
    [todoList_4 release];
    [todoList_5 release];
    [super dealloc];
}


@end
