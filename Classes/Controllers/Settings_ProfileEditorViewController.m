#import <QuartzCore/QuartzCore.h>
#import "Settings_ProfileEditorViewController.h"
#import "TipboxAppDelegate.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10
#define kOFFSET_FOR_KEYBOARD 60.0

@implementation Settings_ProfileEditorViewController

@synthesize userid, name, username, email, location, bio, url;

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

- (void)viewDidLoad
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    global = appDelegate.global;
    
    [self setTitle:@"Profile Editor"];
    saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(updateProfile)];
    saveButton.style = UIBarButtonItemStyleDone;
    saveButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    profileOwnerCard = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
    
    profileOwnerCardBg = [[UIView alloc] init];
    profileOwnerCardBg.layer.masksToBounds = YES;
    profileOwnerCardBg.layer.cornerRadius = 4;
    profileOwnerCardBg.layer.borderWidth = 0.5;
    profileOwnerCardBg.layer.borderColor = [UIColor whiteColor].CGColor;
    profileOwnerCardBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    
    separator_1 = [[UIView alloc] init];
    separator_2 = [[UIView alloc] init];
    separator_3 = [[UIView alloc] init];
    separator_4 = [[UIView alloc] init];
    separator_5 = [[UIView alloc] init];
    separator_1.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_red.png"]];
    separator_2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_red.png"]];
    separator_3.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_red.png"]];
    separator_4.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_red.png"]];
    separator_5.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_red.png"]];
    
    label_name = [[LPLabel alloc] init];
    label_username = [[LPLabel alloc] init];
    label_email = [[LPLabel alloc] init];
    label_location = [[LPLabel alloc] init];
    label_url = [[LPLabel alloc] init];
    label_bio = [[LPLabel alloc] init];
    label_bioNotice = [[LPLabel alloc] init];
    
    label_name.backgroundColor = [UIColor clearColor];
	label_name.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_name.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_name.numberOfLines = 1;
	label_name.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    label_name.textAlignment = UITextAlignmentRight;
    
    label_username.backgroundColor = [UIColor clearColor];
	label_username.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_username.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_username.numberOfLines = 1;
	label_username.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    label_username.textAlignment = UITextAlignmentRight;
    
    label_email.backgroundColor = [UIColor clearColor];
	label_email.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_email.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_email.numberOfLines = 1;
	label_email.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    label_email.textAlignment = UITextAlignmentRight;
    
    label_location.backgroundColor = [UIColor clearColor];
	label_location.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_location.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_location.numberOfLines = 1;
	label_location.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    label_location.textAlignment = UITextAlignmentRight;
    
    label_url.backgroundColor = [UIColor clearColor];
	label_url.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_url.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_url.numberOfLines = 1;
	label_url.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    label_url.textAlignment = UITextAlignmentRight;
    
    label_bio.backgroundColor = [UIColor clearColor];
	label_bio.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_bio.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_bio.numberOfLines = 1;
	label_bio.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    label_bio.textAlignment = UITextAlignmentRight;
    
    label_bioNotice.backgroundColor = [UIColor clearColor];
	label_bioNotice.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_bioNotice.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_bioNotice.numberOfLines = 1;
	label_bioNotice.font = [UIFont systemFontOfSize:MIN_SECONDARY_FONT_SIZE];
    
    label_name.text = @"Name";
    label_username.text = @"Username";
    label_email.text = @"Email";
    label_location.text = @"Location";
    label_url.text = @"Website";
    label_bio.text = @"Bio";
    label_bioNotice.text = @"No more than 160 characters, please!";
    
    userid = [[global readProperty:@"userid"] intValue];
    name = [global readProperty:@"name"];
    username = [global readProperty:@"username"];
    email = [global readProperty:@"email"];
    location = [global readProperty:@"location"];
    url = [global readProperty:@"url"];
    bio = [global readProperty:@"bio"];
    
    field_name = [[UITextField alloc] init];
    field_username = [[UITextField alloc] init];
    field_email = [[UITextField alloc] init];
    field_location = [[UITextField alloc] init];
    field_url = [[UITextField alloc] init];
    field_bio = [[UITextField alloc] init];
    
    label_usernameMarker = [[LPLabel alloc] init];
    label_usernameMarker.backgroundColor = [UIColor clearColor];
	label_usernameMarker.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_usernameMarker.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    label_usernameMarker.shadowOffset = CGSizeMake(0, 1);
	label_usernameMarker.numberOfLines = 1;
	label_usernameMarker.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    
    field_name.delegate = self;
    field_name.borderStyle = UITextBorderStyleNone;
    field_name.placeholder = @"This can't be blank!";
    field_name.clearButtonMode = UITextFieldViewModeWhileEditing;
    field_name.returnKeyType = UIReturnKeyDone;
    field_name.autocapitalizationType = UITextAutocapitalizationTypeWords;
    field_name.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    field_name.tag = 0;
    
    field_username.delegate = self;
    field_username.borderStyle = UITextBorderStyleNone;
    field_username.placeholder = @"This can't be blank!";
    field_username.clearButtonMode = UITextFieldViewModeWhileEditing;
    field_username.returnKeyType = UIReturnKeyDone;
    field_username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field_username.autocorrectionType = UITextAutocorrectionTypeNo;
    field_username.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    field_username.tag = 1;
    
    field_email.delegate = self;
    field_email.borderStyle = UITextBorderStyleNone;
    field_email.placeholder = @"This can't be blank!";
    field_email.clearButtonMode = UITextFieldViewModeWhileEditing;
    field_email.keyboardType = UIKeyboardTypeEmailAddress;
    field_email.returnKeyType = UIReturnKeyDone;
    field_email.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field_email.autocorrectionType = UITextAutocorrectionTypeNo;
    field_email.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    field_email.tag = 2;
    
    field_location.delegate = self;
    field_location.borderStyle = UITextBorderStyleNone;
    field_location.clearButtonMode = UITextFieldViewModeWhileEditing;
    field_location.returnKeyType = UIReturnKeyDone;
    field_location.autocapitalizationType = UITextAutocapitalizationTypeWords;
    field_location.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    field_location.tag = 3;
    
    field_url.delegate = self;
    field_url.borderStyle = UITextBorderStyleNone;
    field_url.clearButtonMode = UITextFieldViewModeWhileEditing;
    field_url.keyboardType = UIKeyboardTypeURL;
    field_url.returnKeyType = UIReturnKeyDone;
    field_url.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field_url.autocorrectionType = UITextAutocorrectionTypeNo;
    field_url.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:185.0/255.0 alpha:1.0];
    field_url.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    field_url.tag = 4;
    
    field_bio.delegate = self;
    field_bio.borderStyle = UITextBorderStyleNone;
    field_bio.clearButtonMode = UITextFieldViewModeWhileEditing;
    field_bio.returnKeyType = UIReturnKeyDone;
    field_bio.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    field_bio.tag = 5;
    
    field_name.text = name;
    label_usernameMarker.text = @"@";
    field_username.text = username;
    field_email.text = email;
    field_location.text = location;
    field_url.text = url;
    field_bio.text = bio;
    
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
    
    [errorStrip addSubview:errorStripIcon];
    [errorStrip addSubview:errorLabel];
    [scrollView addSubview:profileOwnerCard];
    [scrollView addSubview:profileOwnerCardBg];
    [profileOwnerCardBg addSubview:separator_1];
    [profileOwnerCardBg addSubview:separator_2];
    [profileOwnerCardBg addSubview:separator_3];
    [profileOwnerCardBg addSubview:separator_4];
    [profileOwnerCardBg addSubview:separator_5];
    [profileOwnerCardBg addSubview:label_name];
    [profileOwnerCardBg addSubview:label_username];
    [profileOwnerCardBg addSubview:label_email];
    [profileOwnerCardBg addSubview:label_location];
    [profileOwnerCardBg addSubview:label_url];
    [profileOwnerCardBg addSubview:label_bio];
    [profileOwnerCardBg addSubview:label_bioNotice];
    [profileOwnerCardBg addSubview:field_name];
    [profileOwnerCardBg addSubview:label_usernameMarker];
    [profileOwnerCardBg addSubview:field_username];
    [profileOwnerCardBg addSubview:field_email];
    [profileOwnerCardBg addSubview:field_location];
    [profileOwnerCardBg addSubview:field_url];
    [profileOwnerCardBg addSubview:field_bio];
    [profileOwnerCardBg addSubview:errorStrip];
    
    profileOwnerCard.frame = CGRectMake(6, 10, 308, 225);
    profileOwnerCardBg.frame = CGRectMake(9, 13, 301, 218);
    separator_1.frame = CGRectMake(9, 35, 283, 2);
    separator_2.frame = CGRectMake(9, 68, 283, 2);
    separator_3.frame = CGRectMake(9, 101, 283, 2);
    separator_4.frame = CGRectMake(9, 134, 283, 2);
    separator_5.frame = CGRectMake(9, 167, 283, 2);
    label_name.frame = CGRectMake(9, 11, 90, 16);
    label_username.frame = CGRectMake(9, 45, 90, 16);
    label_email.frame = CGRectMake(9, 78, 90, 16);
    label_location.frame = CGRectMake(9, 111, 90, 16);
    label_url.frame = CGRectMake(9, 144, 90, 16);
    label_bio.frame = CGRectMake(9, 178, 90, 16);
    label_bioNotice.frame = CGRectMake(105, 199, 180, 11);
    field_name.frame = CGRectMake(105, 9, 190, 20);
    label_usernameMarker.frame = CGRectMake(105, 45, 18, 16);
    field_username.frame = CGRectMake(117, 42, 178, 20);
    field_email.frame = CGRectMake(105, 76, 190, 20);
    field_location.frame = CGRectMake(105, 109, 190, 20);
    field_url.frame = CGRectMake(105, 142, 190, 20);
    field_bio.frame = CGRectMake(105, 175, 190, 20);
    
    [errorStripIcon release];
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

- (void)viewWillDisappear:(BOOL)animated
{
    // Unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count - 2] == self) { // View is disappearing because a new view controller was pushed onto the stack
        
        
    } else if ([viewControllers indexOfObject:self] == NSNotFound) { // View is disappearing because it was popped from the stack
        
    }
}

#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    saveButton.enabled = YES;
    activeTextField = textField;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification *)aNotification
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    scrollView.frame = CGRectMake(0, 0, 320, screenHeight - 64 - kbSize.height);
    scrollView.contentSize = CGSizeMake(320, screenHeight - 237);
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    scrollView.frame = CGRectMake(0, 0, 320, screenHeight - 64);
    scrollView.contentSize = CGSizeMake(320, screenHeight - 64);
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)enableFields
{
    field_email.enabled = YES;
    field_username.enabled = YES;
    field_location.enabled = YES;
    field_url.enabled = YES;
    field_bio.enabled = YES;
}

- (void)disableFields
{
    field_email.enabled = NO;
    field_username.enabled = NO;
    field_location.enabled = NO;
    field_url.enabled = NO;
    field_bio.enabled = NO;
    [activeTextField resignFirstResponder];
}

- (void)updateProfile
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    saveButton.enabled = NO;
    [self disableFields];
    
    label_name.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_username.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_email.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_location.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_url.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_bio.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    
    name = field_name.text;
    username = field_username.text;
    email = field_email.text;
    location = field_location.text;
    url = field_url.text;
    bio = field_bio.text;
    
    // Fixing and cleaning up the data before sending it off.
    // Trimming whitespace around the strings.
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    username = [username stringByReplacingOccurrencesOfString:@" " withString:@""]; // Trim any whitespace inside the string.
    email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    email = [email stringByReplacingOccurrencesOfString:@" " withString:@""];
    location = [location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
    bio = [bio stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    field_name.text = name;
    field_username.text = username;
    field_email.text = email;
    field_location.text = location;
    field_url.text = url;
    field_bio.text = bio;
    
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"] && ![url hasPrefix:@"ftp://"] && ![url hasPrefix:@"ftps://"] && url.length > 0) {
        url = [NSString stringWithFormat:@"http://%@", url];
        field_url.text = url;
    }
    
    // EXCEEDING LIMITS
    if (name.length > 50) {
        [self showErrorStripWithError:@"Your name exceeds 50 characters! Better fix that!"];
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
    
    if (location.length > 160 && activeTextField.tag == 3) {
        location = [location substringToIndex:160];
        label_location.textColor = [UIColor colorWithRed:255.0/255.0 green:159.0/255.0 blue:26.0/255.0 alpha:1.0];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Location is too long!"
                              message:@"That's a pretty long location! Might wanna shorten it to something less than 160 characters." delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    if (url.length > 100 && activeTextField.tag == 4) {
        url = [url substringToIndex:100];
        label_url.textColor = [UIColor colorWithRed:255.0/255.0 green:159.0/255.0 blue:26.0/255.0 alpha:1.0];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Website address is too long!"
                              message:@"Keep it simple (as in no more than 100 characters)! " delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    if (bio.length > 160 && activeTextField.tag == 5) {
        bio = [bio substringToIndex:160];
        label_bio.textColor = [UIColor colorWithRed:255.0/255.0 green:159.0/255.0 blue:26.0/255.0 alpha:1.0];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Bio is too long!"
                              message:@"Your bio exceeds 160 characters! Just sayin'!" delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
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
    
    if (location.length > 160 && activeTextField.tag == 3) {
        location = [location substringToIndex:160];
        label_location.textColor = [UIColor colorWithRed:255.0/255.0 green:159.0/255.0 blue:26.0/255.0 alpha:1.0];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Location is too long!"
                              message:@"That's a pretty long location! Might wanna shorten it to something less than 160 characters." delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    if (url.length > 100 && activeTextField.tag == 4) {
        url = [url substringToIndex:100];
        label_url.textColor = [UIColor colorWithRed:255.0/255.0 green:159.0/255.0 blue:26.0/255.0 alpha:1.0];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Website address is too long!"
                              message:@"Keep it simple (as in no more than 100 characters)! " delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    if (bio.length > 160 && activeTextField.tag == 5) {
        bio = [bio substringToIndex:160];
        label_bio.textColor = [UIColor colorWithRed:255.0/255.0 green:159.0/255.0 blue:26.0/255.0 alpha:1.0];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Bio is too long!"
                              message:@"Your bio exceeds 160 characters! Just sayin'!" delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    if (name.length != 0 && username.length != 0 && email.length != 0) {
        [appDelegate.strobeLight activateStrobeLight];
        
        NSURL *apiurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/editprofile", SH_DOMAIN]];
        
        dataRequest = [[ASIFormDataRequest requestWithURL:apiurl] retain];
        [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
        [dataRequest setPostValue:name forKey:@"fullname"];
        [dataRequest setPostValue:username forKey:@"username"];
        [dataRequest setPostValue:email forKey:@"email"];
        [dataRequest setPostValue:location forKey:@"location"];
        [dataRequest setPostValue:url forKey:@"website"];
        [dataRequest setPostValue:bio forKey:@"bio"];
        [dataRequest setCompletionBlock:^{
            NSError *jsonError;
            responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
            
            [self enableFields]; // Re-enable the fields.
            
            if ([[responseData objectForKey:@"error"] intValue] == 0) {
                [global writeValue:name forProperty:@"name"];
                [global writeValue:username forProperty:@"username"];
                [global writeValue:email forProperty:@"email"];
                [global writeValue:location forProperty:@"location"];
                [global writeValue:url forProperty:@"url"];
                
                if (bio.length > 160) {
                    bio = [bio stringByAppendingString:@"..."];
                }
                
                [global writeValue:bio forProperty:@"bio"];
                
                [appDelegate.strobeLight affirmativeStrobeLight];
            } else {
                [appDelegate.strobeLight negativeStrobeLight];
                
                NSDictionary *errorMsgs = [responseData objectForKey:@"errormsg"];
                NSString *errorMsg = @"";
                
                if ([[errorMsgs objectForKey:@"fullnameErr"] intValue] == 1) {
                    errorMsg = @"That's an invalid name!";
                    label_name.textColor = [UIColor redColor];
                    [field_name becomeFirstResponder];
                } else if ([[errorMsgs objectForKey:@"usernameExistsErr"] intValue] == 1) {
                    errorMsg = @"That username's already taken!";
                    label_username.textColor = [UIColor redColor];
                    [field_username becomeFirstResponder];
                } else if ([[errorMsgs objectForKey:@"usernameErr"] intValue] == 1) {
                    errorMsg = @"That's an invalid username!";
                    label_username.textColor = [UIColor redColor];
                    [field_username becomeFirstResponder];
                } else if ([[errorMsgs objectForKey:@"emailExistsErr"] intValue] == 1) {
                    errorMsg = @"That email's already in use!";
                    label_email.textColor = [UIColor redColor];
                    [field_email becomeFirstResponder];
                } else if ([[errorMsgs objectForKey:@"emailErr"] intValue] == 1) {
                    errorMsg = @"That's an invalid email!";
                    label_email.textColor = [UIColor redColor];
                    [field_email becomeFirstResponder];
                }
                
                saveButton.enabled = YES;
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
    } else {
        
    }
}

- (void)showErrorStripWithError:(NSString *)error
{
    errorLabel.text = error;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    errorStrip.frame = CGRectMake(0, 0, 301, 34);
    profileOwnerCard.frame = CGRectMake(6, 10, 308, 259);
    profileOwnerCardBg.frame = CGRectMake(9, 13, 301, 252);
    separator_1.frame = CGRectMake(9, 69, 283, 2);
    separator_2.frame = CGRectMake(9, 102, 283, 2);
    separator_3.frame = CGRectMake(9, 135, 283, 2);
    separator_4.frame = CGRectMake(9, 168, 283, 2);
    separator_5.frame = CGRectMake(9, 201, 283, 2);
    label_name.frame = CGRectMake(9, 45, 90, 16);
    label_username.frame = CGRectMake(9, 79, 90, 16);
    label_email.frame = CGRectMake(9, 112, 90, 16);
    label_location.frame = CGRectMake(9, 145, 90, 16);
    label_url.frame = CGRectMake(9, 179, 90, 16);
    label_bio.frame = CGRectMake(9, 212, 90, 16);
    label_bioNotice.frame = CGRectMake(105, 233, 180, 11);
    field_name.frame = CGRectMake(105, 43, 190, 20);
    label_usernameMarker.frame = CGRectMake(105, 79, 18, 16);
    field_username.frame = CGRectMake(117, 77, 178, 20);
    field_email.frame = CGRectMake(105, 110, 190, 20);
    field_location.frame = CGRectMake(105, 143, 190, 20);
    field_url.frame = CGRectMake(105, 176, 190, 20);
    field_bio.frame = CGRectMake(105, 209, 190, 20);
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [saveButton release];
    [scrollView release];
    [label_name release];
    [label_username release];
    [label_email release];
    [label_location release];
    [label_url release];
    [label_bio release];
    [label_bioNotice release];
    [field_name release];
    [field_username release];
    [field_email release];
    [field_location release];
    [field_url release];
    [field_bio release];
    [label_usernameMarker release];
    [profileOwnerCard release];
    [profileOwnerCardBg release];
    [separator_1 release];
    [separator_2 release];
    [separator_3 release];
    [separator_4 release];
    [separator_5 release];
    [errorStrip release];
    [errorLabel release];
    [super dealloc];
}


@end
