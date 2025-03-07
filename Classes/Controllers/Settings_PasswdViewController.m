#import <QuartzCore/QuartzCore.h>
#import "Settings_PasswdViewController.h"
#import "TipboxAppDelegate.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation Settings_PasswdViewController

@synthesize field_oldPasswd, field_changedPasswd, field_confirmedPasswd;

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
    
    [self setTitle:@"Change Password"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveNewPasswd)];
    self.navigationItem.rightBarButtonItem = saveButton;
    saveButton.enabled = NO;
    
    profileOwnerCard = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
    profileOwnerCard.frame = CGRectMake(6, 10, 308, 120);
    
    profileOwnerCardBg = [[UIView alloc] initWithFrame:CGRectMake(9, 13, 301, 113)];
    profileOwnerCardBg.layer.masksToBounds = YES;
    profileOwnerCardBg.layer.cornerRadius = 4;
    profileOwnerCardBg.layer.borderWidth = 0.5;
    profileOwnerCardBg.layer.borderColor = [UIColor whiteColor].CGColor;
    profileOwnerCardBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    
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
    
    separator_1 = [[UIView alloc] initWithFrame:CGRectMake(9, 41, 283, 2)];
    separator_2 = [[UIView alloc] initWithFrame:CGRectMake(9, 74, 283, 2)];
    
    separator_1.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_red.png"]];
    separator_2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_red.png"]];
    
    label_oldPasswd = [[LPLabel alloc] initWithFrame:CGRectMake(9, 18, 110, 16)];
    label_changedPasswd = [[LPLabel alloc] initWithFrame:CGRectMake(9, 51, 110, 16)];
    label_confirmedPasswd = [[LPLabel alloc] initWithFrame:CGRectMake(9, 84, 110, 16)];
    
    label_oldPasswd.backgroundColor = [UIColor clearColor];
	label_oldPasswd.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_oldPasswd.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_oldPasswd.numberOfLines = 1;
	label_oldPasswd.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    label_oldPasswd.textAlignment = UITextAlignmentRight;
    
    label_changedPasswd.backgroundColor = [UIColor clearColor];
	label_changedPasswd.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_changedPasswd.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_changedPasswd.numberOfLines = 1;
	label_changedPasswd.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    label_changedPasswd.textAlignment = UITextAlignmentRight;
    
    label_confirmedPasswd.backgroundColor = [UIColor clearColor];
	label_confirmedPasswd.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_confirmedPasswd.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	label_confirmedPasswd.numberOfLines = 1;
	label_confirmedPasswd.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    label_confirmedPasswd.textAlignment = UITextAlignmentRight;
    
    label_oldPasswd.text = @"Old Password";
    label_changedPasswd.text = @"New Password";
    label_confirmedPasswd.text = @"Confirm it";
    
    field_oldPasswd = [[UITextField alloc] initWithFrame:CGRectMake(125, 16, 170, 20)];
    field_changedPasswd = [[UITextField alloc] initWithFrame:CGRectMake(125, 49, 170, 20)];
    field_confirmedPasswd = [[UITextField alloc] initWithFrame:CGRectMake(125, 82, 170, 20)];
    
    field_oldPasswd.delegate = self;
    field_oldPasswd.borderStyle = UITextBorderStyleNone;
    field_oldPasswd.clearButtonMode = UITextFieldViewModeWhileEditing;
    field_oldPasswd.keyboardType = UIKeyboardTypeEmailAddress;
    field_oldPasswd.returnKeyType = UIReturnKeyNext;
    field_oldPasswd.secureTextEntry = YES;
    field_oldPasswd.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    field_oldPasswd.tag = 1;
    [field_oldPasswd becomeFirstResponder];
    
    field_changedPasswd.delegate = self;
    field_changedPasswd.borderStyle = UITextBorderStyleNone;
    field_changedPasswd.clearButtonMode = UITextFieldViewModeWhileEditing;
    field_changedPasswd.keyboardType = UIKeyboardTypeEmailAddress;
    field_changedPasswd.returnKeyType = UIReturnKeyNext;
    field_changedPasswd.secureTextEntry = YES;
    field_changedPasswd.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    field_changedPasswd.tag = 2;
    
    field_confirmedPasswd.delegate = self;
    field_confirmedPasswd.borderStyle = UITextBorderStyleNone;
    field_confirmedPasswd.clearButtonMode = UITextFieldViewModeWhileEditing;
    field_confirmedPasswd.keyboardType = UIKeyboardTypeEmailAddress;
    field_confirmedPasswd.returnKeyType = UIReturnKeyDone;
    field_confirmedPasswd.secureTextEntry = YES;
    field_confirmedPasswd.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    field_confirmedPasswd.tag = 3;
    
    // Listen for keystrokes.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToTextInFields) name:UITextFieldTextDidChangeNotification object:field_oldPasswd];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToTextInFields) name:UITextFieldTextDidChangeNotification object:field_changedPasswd];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToTextInFields) name:UITextFieldTextDidChangeNotification object:field_confirmedPasswd];
    
    [self.view addSubview:profileOwnerCard];
    [self.view addSubview:profileOwnerCardBg];
    [profileOwnerCardBg addSubview:errorStrip];
    [profileOwnerCardBg addSubview:separator_1];
    [profileOwnerCardBg addSubview:separator_2];
    [profileOwnerCardBg addSubview:label_oldPasswd];
    [profileOwnerCardBg addSubview:label_changedPasswd];
    [profileOwnerCardBg addSubview:label_confirmedPasswd];
    [profileOwnerCardBg addSubview:field_oldPasswd];
    [profileOwnerCardBg addSubview:field_changedPasswd];
    [profileOwnerCardBg addSubview:field_confirmedPasswd];
    [errorStrip addSubview:errorLabel];
    [errorStrip addSubview:errorStripIcon];
    
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
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count - 2] == self) { // View is disappearing because a new view controller was pushed onto the stack
        
    } else if ([viewControllers indexOfObject:self] == NSNotFound) { // View is disappearing because it was popped from the stack
        
    }
}

- (void)respondToTextInFields
{
    if (field_oldPasswd.text.length == 0 || field_changedPasswd.text.length == 0 || field_confirmedPasswd.text.length == 0) {
        saveButton.enabled = NO;
    } else {
        saveButton.enabled = YES;
    }
}

#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1) {
        [field_changedPasswd becomeFirstResponder];
        return NO;
    } else if (textField.tag == 2) {
        [field_confirmedPasswd becomeFirstResponder];
        return NO;
    } else {
        if (field_oldPasswd.text.length > 0 && field_changedPasswd.text.length > 0 && field_confirmedPasswd.text.length > 0) {
            [self saveNewPasswd];
        } else {
            return NO; 
        }
        
        return YES;
    }
}

- (void)saveNewPasswd
{
    label_oldPasswd.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_changedPasswd.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    label_confirmedPasswd.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    
    if (field_oldPasswd.text.length < 6) {
        [self showErrorStripWithError:@"Your old password should be at least 6 characters long!"];
        label_oldPasswd.textColor = [UIColor redColor];
        [field_oldPasswd becomeFirstResponder];
        
        return;
    }
    
    if (field_changedPasswd.text.length < 6) {
        [self showErrorStripWithError:@"Your new password should be at least 6 characters long!"];
        label_changedPasswd.textColor = [UIColor redColor];
        [field_changedPasswd becomeFirstResponder];
        
        return;
    }
    
    if (![field_changedPasswd.text isEqualToString:field_confirmedPasswd.text]) {
        [self showErrorStripWithError:@"Whoa! Your passwords don't match!"];
        label_changedPasswd.textColor = [UIColor redColor];
        label_confirmedPasswd.textColor = [UIColor redColor];
        [field_changedPasswd becomeFirstResponder];
        
        return;
    }
    
    field_oldPasswd.enabled = NO;
    field_changedPasswd.enabled = NO;
    field_confirmedPasswd.enabled = NO;
    saveButton.enabled = NO;
    [field_oldPasswd resignFirstResponder];
    [field_changedPasswd resignFirstResponder];
    [field_confirmedPasswd resignFirstResponder];
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    
    NSURL *apiurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/changepassword", SH_DOMAIN]];
    
    dataRequest = [[ASIFormDataRequest requestWithURL:apiurl] retain];
    [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest setPostValue:[global readProperty:@"username"] forKey:@"username"];
    [dataRequest setPostValue:field_oldPasswd.text forKey:@"oldPass"];
    [dataRequest setPostValue:field_changedPasswd.text forKey:@"newPass"];
    [dataRequest setPostValue:field_confirmedPasswd.text forKey:@"newPassConfirm"];
    [dataRequest setCompletionBlock:^{
        NSError *jsonError;
        responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData objectForKey:@"error"] intValue] == 0) {
            [appDelegate.strobeLight affirmativeStrobeLight];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [appDelegate.strobeLight negativeStrobeLight];
            field_oldPasswd.enabled = YES;
            field_changedPasswd.enabled = YES;
            field_confirmedPasswd.enabled = YES;
            
            if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
            
            NSDictionary *errorMsgs = [responseData objectForKey:@"errormsg"];
            NSString *errorMsg = @"";
            
            if ([[errorMsgs objectForKey:@"PwdLenErr"] intValue] == 1) {
                errorMsg = @"Your new password should be at least 6 characters long!";
                label_changedPasswd.textColor = [UIColor redColor];
                [field_changedPasswd becomeFirstResponder];
            } else if ([[errorMsgs objectForKey:@"PwdMatchErr"] intValue] == 1) {
                errorMsg = @"Whoa! Your passwords don't match!";
                label_oldPasswd.textColor = [UIColor redColor];
                [field_oldPasswd becomeFirstResponder];
            } else if ([[errorMsgs objectForKey:@"PwdOldErr"] intValue] == 1) {
                errorMsg = @"Your old password is incorrect!";
                label_changedPasswd.textColor = [UIColor redColor];
                label_confirmedPasswd.textColor = [UIColor redColor];
                [field_changedPasswd becomeFirstResponder];
            }
            
            [self showErrorStripWithError:errorMsg];
        }
        
        saveButton.enabled = NO;
        
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
        saveButton.enabled = NO;
        
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
    profileOwnerCard.frame = CGRectMake(6, 10, 308, 154);
    profileOwnerCardBg.frame = CGRectMake(9, 13, 301, 147);
    separator_1.frame = CGRectMake(9, 75, 283, 2);
    separator_2.frame = CGRectMake(9, 108, 283, 2);
    label_oldPasswd.frame = CGRectMake(9, 52, 110, 16);
    label_changedPasswd.frame = CGRectMake(9, 85, 110, 16);
    label_confirmedPasswd.frame = CGRectMake(9, 118, 110, 16);
    field_oldPasswd.frame = CGRectMake(125, 50, 170, 20);
    field_changedPasswd.frame = CGRectMake(125, 83, 170, 20);
    field_confirmedPasswd.frame = CGRectMake(125, 116, 170, 20);
    
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [saveButton release];
    [errorStrip release];
    [errorLabel release];
    [profileOwnerCard release];
    [profileOwnerCardBg release];
    [separator_1 release];
    [separator_2 release];
    [label_oldPasswd release];
    [label_changedPasswd release];
    [label_confirmedPasswd release];
    [field_oldPasswd release];
    [field_changedPasswd release];
    [field_confirmedPasswd release];
    [super dealloc];
}


@end
