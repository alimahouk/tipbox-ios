#import <QuartzCore/QuartzCore.h>
#import "Signup_FormViewController.h"
#import "TipboxAppDelegate.h"
#import "SignupViewController.h"
#import "Intro_TutorialViewController.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation Signup_FormViewController

@synthesize dataRequest, responseData, field_name, field_email, field_username, field_passwd, field_confirmedPasswd;
@synthesize fbid, twitterid, twitterUsername, TWTokenSecret, name, email, username, picHash, passwd, passwdConfirmed;
@synthesize location, bio, websiteURL, userTimezone;

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

- (void)viewDidLoad
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // Hide the network activity indicator shown in the previous view.
    // Set up the nav bar.
    [self setTitle:@"Join Tipbox"];
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    global = appDelegate.global;
    
    nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered  target:self action:@selector(createAccount)];
    self.navigationItem.rightBarButtonItem = nextButton;
    nextButton.enabled = NO;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    
    profileOwnerCard = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
    profileOwnerCard.hidden = YES;
    
    profileOwnerCardBg = [[UIView alloc] init];
    profileOwnerCardBg.layer.masksToBounds = YES;
    profileOwnerCardBg.layer.cornerRadius = 4;
    profileOwnerCardBg.layer.borderWidth = 0.5;
    profileOwnerCardBg.layer.borderColor = [UIColor whiteColor].CGColor;
    profileOwnerCardBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    profileOwnerCardBg.hidden = YES;
    
    errorStrip = [[UIView alloc] initWithFrame:CGRectMake(0, -35, 301, 34)];
    errorStrip.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:173.0/255.0 blue:173.0/255.0 alpha:0.4];
    errorStrip.layer.borderWidth = 0.7;
    errorStrip.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:143.0/255.0 blue:143.0/255.0 alpha:1.0].CGColor;
    
    UIImageView *errorStripIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"attention.png"]];
    errorStripIcon.frame = CGRectMake(7, 3, 29, 30);
    
    errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 8, 258, 20)];
    errorLabel.backgroundColor = [UIColor clearColor];
    errorLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    errorLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    errorLabel.shadowOffset = CGSizeMake(0, 1);
    errorLabel.numberOfLines = 1;
    errorLabel.minimumFontSize = 8.;
    errorLabel.adjustsFontSizeToFitWidth = YES;
    errorLabel.font = [UIFont fontWithName:@"Georgia" size:MIN_MAIN_FONT_SIZE];
    
    separator_1 = [[UIView alloc] init];
    separator_2 = [[UIView alloc] init];
    separator_3 = [[UIView alloc] init];
    separator_4 = [[UIView alloc] init];
    separator_1.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_red.png"]];
    separator_2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_red.png"]];
    separator_3.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_red.png"]];
    separator_4.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_red.png"]];
    
    label_notice = [[LPLabel alloc] initWithFrame:CGRectMake(105, 11, 180, 11)];
    label_name = [[LPLabel alloc] init];
    label_email = [[LPLabel alloc] init];
    label_username = [[LPLabel alloc] init];
    label_passwd = [[LPLabel alloc] init];
    label_confirmedPasswd = [[LPLabel alloc] init];
    
    label_notice.backgroundColor = [UIColor clearColor];
	label_notice.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_notice.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_notice.numberOfLines = 1;
	label_notice.font = [UIFont systemFontOfSize:MIN_SECONDARY_FONT_SIZE];
    
    label_name.backgroundColor = [UIColor clearColor];
	label_name.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_name.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_name.numberOfLines = 1;
	label_name.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    label_name.textAlignment = UITextAlignmentRight;
    
    label_email.backgroundColor = [UIColor clearColor];
	label_email.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_email.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_email.numberOfLines = 1;
	label_email.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    label_email.textAlignment = UITextAlignmentRight;
    
    label_username.backgroundColor = [UIColor clearColor];
	label_username.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_username.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_username.numberOfLines = 1;
	label_username.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    label_username.textAlignment = UITextAlignmentRight;
    
    label_passwd.backgroundColor = [UIColor clearColor];
	label_passwd.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_passwd.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_passwd.numberOfLines = 1;
	label_passwd.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    label_passwd.textAlignment = UITextAlignmentRight;
    
    label_confirmedPasswd.backgroundColor = [UIColor clearColor];
	label_confirmedPasswd.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_confirmedPasswd.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_confirmedPasswd.numberOfLines = 1;
	label_confirmedPasswd.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    label_confirmedPasswd.textAlignment = UITextAlignmentRight;
    
    label_notice.text = @"Just a few more details, please!";
    label_name.text = @"Name";
    label_email.text = @"Email";
    label_username.text = @"Username";
    label_passwd.text = @"Password";
    label_confirmedPasswd.text = @"Confirm it";
    
    field_name = [[UITextField alloc] init];
    field_email = [[UITextField alloc] init];
    field_username = [[UITextField alloc] init];
    field_passwd = [[UITextField alloc] init];
    field_confirmedPasswd = [[UITextField alloc] init];
    
    label_usernameMarker = [[LPLabel alloc] init];
    label_usernameMarker.backgroundColor = [UIColor clearColor];
	label_usernameMarker.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_usernameMarker.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_usernameMarker.numberOfLines = 1;
	label_usernameMarker.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    
    field_name.delegate = self;
    field_name.borderStyle = UITextBorderStyleNone;
    field_name.placeholder = @"Your name";
    field_name.clearButtonMode = UITextFieldViewModeWhileEditing;
    field_name.returnKeyType = UIReturnKeyNext;
    field_name.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field_name.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    field_name.tag = 1;
    field_email.delegate = self;
    field_email.borderStyle = UITextBorderStyleNone;
    field_email.placeholder = @"Your email";
    field_email.clearButtonMode = UITextFieldViewModeWhileEditing;
    field_email.keyboardType = UIKeyboardTypeEmailAddress;
    field_email.returnKeyType = UIReturnKeyNext;
    field_email.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field_email.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    field_email.tag = 2;
    field_username.delegate = self;
    field_username.borderStyle = UITextBorderStyleNone;
    field_username.placeholder = @"Choose a username";
    field_username.clearButtonMode = UITextFieldViewModeWhileEditing;
    field_username.returnKeyType = UIReturnKeyNext;
    field_username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field_username.autocorrectionType = UITextAutocorrectionTypeNo;
    field_username.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    field_username.tag = 3;
    label_usernameMarker.text = @"@";
    field_passwd.delegate = self;
    field_passwd.borderStyle = UITextBorderStyleNone;
    field_passwd.placeholder = @"Choose a password";
    field_passwd.clearButtonMode = UITextFieldViewModeWhileEditing;
    field_passwd.returnKeyType = UIReturnKeyNext;
    field_passwd.secureTextEntry = YES;
    field_passwd.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    field_passwd.tag = 4;
    field_confirmedPasswd.delegate = self;
    field_confirmedPasswd.borderStyle = UITextBorderStyleNone;
    field_confirmedPasswd.placeholder = @"Confirm password";
    field_confirmedPasswd.clearButtonMode = UITextFieldViewModeWhileEditing;
    field_confirmedPasswd.returnKeyType = UIReturnKeyDone;
    field_confirmedPasswd.secureTextEntry = YES;
    field_confirmedPasswd.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    field_confirmedPasswd.tag = 5;
    
    // Listen for keystrokes.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToTextInFields) name:UITextFieldTextDidChangeNotification object:field_name];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToTextInFields) name:UITextFieldTextDidChangeNotification object:field_email];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToTextInFields) name:UITextFieldTextDidChangeNotification object:field_username];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToTextInFields) name:UITextFieldTextDidChangeNotification object:field_passwd];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToTextInFields) name:UITextFieldTextDidChangeNotification object:field_confirmedPasswd];
    
    underKeyboardLoadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(93, 282, 20, 20)];
    underKeyboardLoadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    underKeyboardLoadingIndicator.hidden = YES;
    
    underKeyboardLoadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 285, 320, 16)];
    underKeyboardLoadingLabel.backgroundColor = [UIColor clearColor];
	underKeyboardLoadingLabel.textColor = [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
	underKeyboardLoadingLabel.font = [UIFont fontWithName:@"Georgia-Italic" size:14];
    underKeyboardLoadingLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    underKeyboardLoadingLabel.shadowOffset = CGSizeMake(0, 1);
    underKeyboardLoadingLabel.textAlignment = UITextAlignmentCenter;
    underKeyboardLoadingLabel.text = @"Please wait...";
    underKeyboardLoadingLabel.hidden = YES;
    
    [self.view addSubview:underKeyboardLoadingLabel];
    [self.view addSubview:underKeyboardLoadingIndicator];
    [self.view addSubview:profileOwnerCard];
    [self.view addSubview:profileOwnerCardBg];
    [errorStrip addSubview:errorStripIcon];
    [errorStrip addSubview:errorLabel];
    [profileOwnerCardBg addSubview:errorStrip];
    [profileOwnerCardBg addSubview:label_notice];
    [profileOwnerCardBg addSubview:separator_1];
    [profileOwnerCardBg addSubview:separator_2];
    [profileOwnerCardBg addSubview:separator_3];
    [profileOwnerCardBg addSubview:separator_4];
    [profileOwnerCardBg addSubview:label_name];
    [profileOwnerCardBg addSubview:label_email];
    [profileOwnerCardBg addSubview:label_username];
    [profileOwnerCardBg addSubview:label_passwd];
    [profileOwnerCardBg addSubview:label_confirmedPasswd];
    [profileOwnerCardBg addSubview:field_name];
    [profileOwnerCardBg addSubview:field_email];
    [profileOwnerCardBg addSubview:label_usernameMarker];
    [profileOwnerCardBg addSubview:field_username];
    [profileOwnerCardBg addSubview:field_passwd];
    [profileOwnerCardBg addSubview:field_confirmedPasswd];
    
    [errorStripIcon release];
    [super viewDidLoad];
}

#pragma mark Customizations when the view appears/disappears
- (void)viewWillDisappear:(BOOL)animated
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count - 2] == self) { // View is disappearing because a new view controller was pushed onto the stack
        
        
    } else if ([viewControllers indexOfObject:self] == NSNotFound) { // View is disappearing because it was popped from the stack
        // We hide the navbar shadow, and deactivate the strobe light (in case it was activated).
        TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.strobeLight deactivateStrobeLight];
    }
}

- (void)showFieldsForConfiguration:(NSString *)configuration
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight deactivateStrobeLight];
    
    formConfiguration = configuration;
    field_name.text = name;
    field_username.text = username;
    
    if ([configuration isEqualToString:@"facebook"]) {
        label_email.hidden = YES;
        field_email.hidden = YES;
        profileOwnerCard.frame = CGRectMake(6, 7, 308, 137);
        profileOwnerCardBg.frame = CGRectMake(9, 10, 301, 130);
        separator_1.frame = CGRectMake(9, 57, 283, 2);
        separator_2.frame = CGRectMake(9, 90, 283, 2);
        label_username.frame = CGRectMake(9, 33, 90, 16);
        label_passwd.frame = CGRectMake(9, 66, 90, 16);
        label_confirmedPasswd.frame = CGRectMake(9, 99, 90, 16);
        label_usernameMarker.frame = CGRectMake(105, 33, 18, 16);
        field_username.frame = CGRectMake(117, 31, 178, 20);
        field_passwd.frame = CGRectMake(105, 64, 190, 20);
        field_confirmedPasswd.frame = CGRectMake(105, 97, 190, 20);
        
        [field_username becomeFirstResponder];
    } else if ([configuration isEqualToString:@"twitter"]) {
        label_email.hidden = NO;
        field_email.hidden = NO;
        
        profileOwnerCard.frame = CGRectMake(6, 7, 308, 172);
        profileOwnerCardBg.frame = CGRectMake(9, 10, 301, 165);
        separator_1.frame = CGRectMake(9, 57, 283, 2);
        separator_2.frame = CGRectMake(9, 90, 283, 2);
        separator_3.frame = CGRectMake(9, 123, 283, 2);
        label_email.frame = CGRectMake(9, 33, 90, 16);
        label_username.frame = CGRectMake(9, 67, 90, 16);
        label_passwd.frame = CGRectMake(9, 100, 90, 16);
        label_confirmedPasswd.frame = CGRectMake(9, 133, 90, 16);
        field_email.frame = CGRectMake(105, 31, 190, 20);
        label_usernameMarker.frame = CGRectMake(105, 67, 18, 16);
        field_username.frame = CGRectMake(117, 65, 178, 20);
        field_passwd.frame = CGRectMake(105, 98, 190, 20);
        field_confirmedPasswd.frame = CGRectMake(105, 131, 190, 20);
        
        [field_email becomeFirstResponder];
    } else {
        label_email.hidden = NO;
        field_email.hidden = NO;
        
        profileOwnerCard.frame = CGRectMake(6, 7, 308, 205);
        profileOwnerCardBg.frame = CGRectMake(9, 10, 301, 198);
        separator_1.frame = CGRectMake(9, 57, 283, 2);
        separator_2.frame = CGRectMake(9, 90, 283, 2);
        separator_3.frame = CGRectMake(9, 123, 283, 2);
        separator_4.frame = CGRectMake(9, 156, 283, 2);
        label_name.frame = CGRectMake(9, 33, 90, 16);
        label_email.frame = CGRectMake(9, 67, 90, 16);
        label_username.frame = CGRectMake(9, 100, 90, 16);
        label_passwd.frame = CGRectMake(9, 133, 90, 16);
        label_confirmedPasswd.frame = CGRectMake(9, 166, 90, 16);
        field_name.frame = CGRectMake(105, 31, 190, 20);
        field_email.frame = CGRectMake(105, 65, 190, 20);
        label_usernameMarker.frame = CGRectMake(105, 101, 18, 16);
        field_username.frame = CGRectMake(117, 98, 178, 20);
        field_passwd.frame = CGRectMake(105, 131, 190, 20);
        field_confirmedPasswd.frame = CGRectMake(105, 164, 190, 20);
        
        [field_name becomeFirstResponder];
    }
    
    profileOwnerCard.hidden = NO;
    profileOwnerCardBg.hidden = NO;
}

- (void)enableFields
{
    nextButton.enabled = YES;
    field_name.enabled = YES;
    field_email.enabled = YES;
    field_username.enabled = YES;
    field_passwd.enabled = YES;
    field_confirmedPasswd.enabled = YES;
    underKeyboardLoadingLabel.hidden = YES;
    underKeyboardLoadingIndicator.hidden = YES;
    [underKeyboardLoadingIndicator stopAnimating];
    [field_username becomeFirstResponder];
}

- (void)disableFields
{
    nextButton.enabled = NO;
    field_name.enabled = NO;
    field_email.enabled = NO;
    field_username.enabled = NO;
    field_passwd.enabled = NO;
    field_confirmedPasswd.enabled = NO;
    underKeyboardLoadingLabel.hidden = NO;
    underKeyboardLoadingIndicator.hidden = NO;
    [underKeyboardLoadingIndicator startAnimating];
    [field_email resignFirstResponder];
    [field_username resignFirstResponder];
    [field_passwd resignFirstResponder];
}

- (void)createAccount
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [field_name resignFirstResponder];
    [field_username resignFirstResponder];
    [field_email resignFirstResponder];
    [field_passwd resignFirstResponder];
    [field_confirmedPasswd resignFirstResponder];
    
    [self disableFields];
    
    label_name.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_email.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_username.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_passwd.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_confirmedPasswd.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    
    name = field_name.text;
    username = field_username.text;
    passwd = field_passwd.text;
    passwdConfirmed = field_confirmedPasswd.text;
    
    // Fixing and cleaning up the data before sending it off.
    // Trimming whitespace around the strings.
    username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    username = [username stringByReplacingOccurrencesOfString:@" " withString:@""];  // Trim any whitespace inside the string.
    field_username.text = username;
    
    if (![formConfiguration isEqualToString:@"facebook"]) {
        email = field_email.text;
        email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        email = [email stringByReplacingOccurrencesOfString:@" " withString:@""];
        field_email.text = email;
    }
    
    // EXCEEDING LIMITS
    if (name.length > 50) {
        [self showErrorStripWithError:@"Your name exceeds 50 characters! Too long."];
        [self enableFields];
        [field_name becomeFirstResponder];
        label_name.textColor = [UIColor redColor];
        return;
    }
    
    if (username.length > 15) {
        [self showErrorStripWithError:@"Your username exceeds 15 characters! Better fix that!"];
        [self enableFields];
        [field_username becomeFirstResponder];
        label_username.textColor = [UIColor redColor];
        return;
    }
    
    if (email.length > 255) {
        [self showErrorStripWithError:@"Your email exceeds 255 characters! Better fix that!"];
        [self enableFields];
        [field_email becomeFirstResponder];
        label_email.textColor = [UIColor redColor];
        return;
    }
    
    // BELOW LIMITS
    if (name.length < 2) {
        [self showErrorStripWithError:@"Your name should be at least 2 characters long!"];
        [self enableFields];
        [field_name becomeFirstResponder];
        label_name.textColor = [UIColor redColor];
        return;
    }
    
    if (username.length < 2) {
        [self showErrorStripWithError:@"Your username should be at least 2 characters long!"];
        [self enableFields];
        [field_username becomeFirstResponder];
        label_username.textColor = [UIColor redColor];
        return;
    }
    
    if (passwd.length < 6) {
        [self showErrorStripWithError:@"Your password should be at least 6 characters long!"];
        [self enableFields];
        [field_passwd becomeFirstResponder];
        label_passwd.textColor = [UIColor redColor];
        return;
    }
    
    // Non-matching passwords.
    if (![passwd isEqualToString:passwdConfirmed]) {
        [self showErrorStripWithError:@"Whoa! Your passwords don't match!"];
        [self enableFields];
        [field_passwd becomeFirstResponder];
        label_passwd.textColor = [UIColor redColor];
        label_confirmedPasswd.textColor = [UIColor redColor];
        return;
    }
    
    [appDelegate.strobeLight activateStrobeLight];
    
    NSString *FBTokenExp = [NSString stringWithFormat:@"%f", [appDelegate.facebook.expirationDate timeIntervalSince1970]];
    
    NSURL *apiurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/signup", SH_DOMAIN]];
    
    dataRequest = [[ASIFormDataRequest requestWithURL:apiurl] retain];
    [dataRequest setPostValue:name forKey:@"fullname"];
    [dataRequest setPostValue:username forKey:@"username"];
    [dataRequest setPostValue:email forKey:@"email"];
    [dataRequest setPostValue:passwd forKey:@"password"];
    [dataRequest setPostValue:passwdConfirmed forKey:@"passwordConfirm"];
    [dataRequest setPostValue:appDelegate.device_token forKey:@"deviceToken"];
    
    if ([formConfiguration isEqualToString:@"email"]) {
        [dataRequest setPostValue:@"email" forKey:@"signupType"];
    } else {
        if ([formConfiguration isEqualToString:@"facebook"]) {
            [dataRequest setPostValue:appDelegate.FBToken forKey:@"fbToken"];
            [dataRequest setPostValue:FBTokenExp forKey:@"fbTokenExp"];
            [dataRequest setPostValue:fbid forKey:@"fbid"];
            [dataRequest setPostValue:@"fb" forKey:@"signupType"];
        } else if ([formConfiguration isEqualToString:@"twitter"]) {
            [dataRequest setPostValue:appDelegate.TWToken forKey:@"twtToken"];
            [dataRequest setPostValue:TWTokenSecret forKey:@"twtTokenSec"];
            [dataRequest setPostValue:twitterid forKey:@"twtid"];
            [dataRequest setPostValue:twitterUsername forKey:@"twtUsername"];
            [dataRequest setPostValue:picHash forKey:@"twtPic"];
            [dataRequest setPostValue:bio forKey:@"twtBio"];
            [dataRequest setPostValue:@"twt" forKey:@"signupType"];
        }
        
        // Secondary data.
        [dataRequest setPostValue:location forKey:@"location"];
        [dataRequest setPostValue:websiteURL forKey:@"url"];
        [dataRequest setPostValue:userTimezone forKey:@"timezone"];
    }
    
    [dataRequest setCompletionBlock:^{
        NSError *jsonError;
        responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        NSLog(@"%@", responseData);
        if ([[responseData objectForKey:@"error"] intValue] == 0) {
            // Store essential data locally.
            [global writeValue:[responseData objectForKey:@"responce"] forProperty:@"token"]; // Store the generated token.
            [global writeValue:name forProperty:@"name"];
            [global writeValue:username forProperty:@"username"];
            [global writeValue:name forProperty:@"email"];
            
            if ([formConfiguration isEqualToString:@"facebook"]) {
                [global writeValue:@"YES" forProperty:@"fbConnected"];
            } else if ([formConfiguration isEqualToString:@"twitter"]) {
                [global writeValue:@"YES" forProperty:@"twitterConnected"];
            }
            
            // Refresh the variable.
            appDelegate.SHToken = [global readProperty:@"token"];
            
            Intro_TutorialViewController *tutorial = [[Intro_TutorialViewController alloc] init];
            [self.navigationController pushViewController:tutorial animated:YES];
            [tutorial release];
            tutorial = nil;
            
            [appDelegate.strobeLight deactivateStrobeLight];
        } else {
            [appDelegate.strobeLight negativeStrobeLight];
            [self enableFields];
            
            NSDictionary *errorMsgs = [responseData objectForKey:@"errormsg"];
            NSString *errorMsg = @"";
            
            if ([[errorMsgs objectForKey:@"fbExsitsErr"] intValue] == 1) {
                errorMsg = @"An account already exists with this Facebook account!";
                [field_username becomeFirstResponder];
            }
            
            if ([[errorMsgs objectForKey:@"twtExsitsErr"] intValue] == 1) {
                errorMsg = @"An account already exists with this Twitter account!";
                label_email.textColor = [UIColor redColor];
                [field_email becomeFirstResponder];
            } else if ([[errorMsgs objectForKey:@"fullnameErr"] intValue] == 1) {
                errorMsg = @"That's an invalid name!";
                label_name.textColor = [UIColor redColor];
                [field_name becomeFirstResponder];
            } else if ([[errorMsgs objectForKey:@"emailExistsErr"] intValue] == 1) {
                errorMsg = @"That email's already in use!";
                label_email.textColor = [UIColor redColor];
            } else if ([[errorMsgs objectForKey:@"emailErr"] intValue] == 1) {
                errorMsg = @"That's an invalid email!";
                label_email.textColor = [UIColor redColor];
                [field_email becomeFirstResponder];
            } else if ([[errorMsgs objectForKey:@"usernameExistsErr"] intValue] == 1) {
                errorMsg = @"Nope! That username's taken!";
                label_username.textColor = [UIColor redColor];
                [field_username becomeFirstResponder];
            } else if ([[errorMsgs objectForKey:@"usernameErr"] intValue] == 1) {
                errorMsg = @"That's an invalid username!";
                label_username.textColor = [UIColor redColor];
                [field_username becomeFirstResponder];
            } else if ([[errorMsgs objectForKey:@"passwordErr"] intValue] == 1) {
                errorMsg = @"That password is invalid!";
                label_passwd.textColor = [UIColor redColor];
                [field_passwd becomeFirstResponder];
            } else if ([[errorMsgs objectForKey:@"passwordConfirmErr"] intValue] == 1) {
                errorMsg = @"Whoa! Your passwords don't match!";
                label_passwd.textColor = [UIColor redColor];
                label_confirmedPasswd.textColor = [UIColor redColor];
                [field_confirmedPasswd becomeFirstResponder];
            }
            
            [self showErrorStripWithError:errorMsg];
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
        
        TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.strobeLight negativeStrobeLight];
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:3];
        
        NSError *error = [dataRequest error];
        NSLog(@"%@", error);
    }];
    [dataRequest startAsynchronous];
}

- (void)showErrorStripWithError:(NSString *)error
{
    errorLabel.text = error;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    
    errorStrip.frame = CGRectMake(0, 0, 301, 34);
    label_notice.hidden = YES;
    
    if ([formConfiguration isEqualToString:@"facebook"]) {
        profileOwnerCard.frame = CGRectMake(6, 7, 308, 155);
        profileOwnerCardBg.frame = CGRectMake(9, 10, 301, 148);
        separator_1.frame = CGRectMake(9, 75, 283, 2);
        separator_2.frame = CGRectMake(9, 108, 283, 2);
        label_username.frame = CGRectMake(9, 52, 90, 16);
        label_passwd.frame = CGRectMake(9, 84, 90, 16);
        label_confirmedPasswd.frame = CGRectMake(9, 117, 90, 16);
        label_usernameMarker.frame = CGRectMake(105, 51, 18, 16);
        field_username.frame = CGRectMake(117, 49, 178, 20);
        field_passwd.frame = CGRectMake(105, 82, 190, 20);
        field_confirmedPasswd.frame = CGRectMake(105, 115, 190, 20);
    } else if ([formConfiguration isEqualToString:@"twitter"]) {
        profileOwnerCard.frame = CGRectMake(6, 7, 308, 190);
        profileOwnerCardBg.frame = CGRectMake(9, 10, 301, 183);
        separator_1.frame = CGRectMake(9, 75, 283, 2);
        separator_2.frame = CGRectMake(9, 108, 283, 2);
        separator_3.frame = CGRectMake(9, 141, 283, 2);
        label_email.frame = CGRectMake(9, 51, 90, 16);
        label_username.frame = CGRectMake(9, 84, 90, 16);
        label_passwd.frame = CGRectMake(9, 117, 90, 16);
        label_confirmedPasswd.frame = CGRectMake(9, 151, 90, 16);
        field_email.frame = CGRectMake(105, 49, 190, 20);
        label_usernameMarker.frame = CGRectMake(105, 84, 18, 16);
        field_username.frame = CGRectMake(117, 82, 178, 20);
        field_passwd.frame = CGRectMake(105, 115, 190, 20);
        field_confirmedPasswd.frame = CGRectMake(105, 148, 190, 20);
    } else {
        profileOwnerCard.frame = CGRectMake(6, 7, 308, 214);
        profileOwnerCardBg.frame = CGRectMake(9, 10, 301, 207);
        separator_1.frame = CGRectMake(9, 66, 283, 2);
        separator_2.frame = CGRectMake(9, 99, 283, 2);
        separator_3.frame = CGRectMake(9, 132, 283, 2);
        separator_4.frame = CGRectMake(9, 166, 283, 2);
        label_name.frame = CGRectMake(9, 42, 90, 16);
        label_email.frame = CGRectMake(9, 76, 90, 16);
        label_username.frame = CGRectMake(9, 109, 90, 16);
        label_passwd.frame = CGRectMake(9, 143, 90, 16);
        label_confirmedPasswd.frame = CGRectMake(9, 176, 90, 16);
        field_name.frame = CGRectMake(105, 40, 190, 20);
        field_email.frame = CGRectMake(105, 74, 190, 20);
        label_usernameMarker.frame = CGRectMake(105, 110, 18, 16);
        field_username.frame = CGRectMake(117, 107, 178, 20);
        field_passwd.frame = CGRectMake(105, 140, 190, 20);
        field_confirmedPasswd.frame = CGRectMake(105, 173, 190, 20);
    }
    
    [UIView commitAnimations];
}

#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1) {
        [field_email becomeFirstResponder];
    } else if (textField.tag == 2) {
        [field_username becomeFirstResponder];
    } else if (textField.tag == 3) {
        [field_passwd becomeFirstResponder];
    } else if (textField.tag == 4) {
        [field_confirmedPasswd becomeFirstResponder];
    } else {
        if (field_name.text.length != 0 && field_username.text.length != 0 && field_passwd.text.length != 0) {
            
            if (field_email.hidden) {
                [self createAccount];
            } else {
                if (field_email.text.length != 0) {
                    [self createAccount];
                } else {
                    [field_email becomeFirstResponder];
                }
            }
        }
        
    }
    
    return NO;
}

- (void)respondToTextInFields
{
    if (field_email.hidden) {
        if (field_username.text.length == 0 || field_passwd.text.length == 0 || field_confirmedPasswd.text.length == 0) {
            nextButton.enabled = NO;
        } else {
            nextButton.enabled = YES;
        }
    } else {
        if (field_name.text.length == 0 || field_email.text.length == 0 || field_username.text.length == 0 || field_passwd.text.length == 0 || field_confirmedPasswd.text.length == 0) {
            nextButton.enabled = NO;
        } else {
            nextButton.enabled = YES;
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [nextButton release];
    [profileOwnerCard release];
    [profileOwnerCardBg release];
    [errorStrip release];
    [errorLabel release];
    [label_notice release];
    [separator_1 release];
    [separator_2 release];
    [separator_3 release];
    [separator_4 release];
    [label_name release];
    [label_email release];
    [label_username release];
    [label_passwd release];
    [label_confirmedPasswd release];
    [label_usernameMarker release];
    [field_name release];
    [field_email release];
    [field_username release];
    [field_passwd release];
    [field_confirmedPasswd release];
    [underKeyboardLoadingLabel release];
    [underKeyboardLoadingIndicator release];
    [super dealloc];
}


@end
