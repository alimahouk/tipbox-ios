#import "RaisedTabBar.h"
#import "TipboxAppDelegate.h"

@implementation RaisedTabBar

@synthesize signupView, tipExplorerView, notifCount, notifCountShadow;

- (void)viewDidLoad
{
    [self addCenterButtonWithImage:[UIImage imageNamed:@"new_tip_button.png"]];
    signupView = [[SignupViewController alloc] initWithNibName:@"SignupView" bundle:nil];
    
    tipExplorerView = [[TipExplorerViewController alloc] initWithNibName:@"TipExplorer" bundle:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

/*- (UIView *)setupNavBar
{
	UIView *navBarView = [[UIView alloc] init];
	NSString *imageName;
	UIImage *roof = [UIImage imageNamed:@"roof_white.png"];
	UIImageView *roofView = [[UIImageView alloc] initWithImage:roof];
	notifCount = [[UILabel alloc] init];
	notifCountShadow = [[UILabel alloc] init];
	
	notifCount.text = @"12";
	notifCountShadow.text = notifCount.text;
	
	if ([notifCount.text isEqualToString:@""]) {
		imageName = @"notif_bubble_empty.png";
	} else {
		imageName = @"notif_bubble.png";
	}
	
	UIButton *notifBubbleButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	notifBubbleButton.backgroundColor = [UIColor clearColor];
	[notifBubbleButton setBackgroundImage:[[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:6.0 topCapHeight:15.0] forState:UIControlStateNormal];
	notifBubbleButton.showsTouchWhenHighlighted = YES;
	
	notifCount.backgroundColor = [UIColor clearColor];
	notifCount.textColor = [UIColor whiteColor];
	notifCount.numberOfLines = 0;
	notifCount.lineBreakMode = UILineBreakModeWordWrap;
	notifCount.font = [UIFont boldSystemFontOfSize:10];
	notifCount.textAlignment = UITextAlignmentCenter;
	
	notifCountShadow.backgroundColor = [UIColor clearColor];
	notifCountShadow.textColor = [UIColor colorWithRed:136.0/255.0 green:122.0/255.0 blue:109.0/255.0 alpha:1.0];
	notifCountShadow.numberOfLines = 0;
	notifCountShadow.lineBreakMode = UILineBreakModeWordWrap;
	notifCountShadow.font = [UIFont boldSystemFontOfSize:10];
	notifCountShadow.textAlignment = UITextAlignmentCenter;
	
	CGSize notifTxtSize = [notifCount.text sizeWithFont:[UIFont boldSystemFontOfSize:10] constrainedToSize:CGSizeMake(40, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	int labelWidth;
	
	if ([notifCount.text isEqualToString:@""]) {
		labelWidth = 24;
	} else {
		int sizeWithPadding = notifTxtSize.width + 10;
		labelWidth = MAX(sizeWithPadding, 24);
	}
	
	notifCount.frame = CGRectMake(1, 1, labelWidth, 18);
	notifCountShadow.frame = CGRectMake(1, 0, labelWidth, 18);
	notifBubbleButton.frame = CGRectMake(55, 5, labelWidth, 21);
	roofView.frame = CGRectMake(22, 3, 31, 25);
	navBarView.frame = CGRectMake(0, 0, 53 + labelWidth, 30);
	
	[notifBubbleButton addSubview:notifCountShadow];
	[notifBubbleButton addSubview:notifCount];
	[navBarView addSubview:roofView];
	[navBarView addSubview:notifBubbleButton];
	
	return navBarView;
}*/

// Create a custom UIButton and add it to the center of our tab bar.
- (void)addCenterButtonWithImage:(UIImage*)buttonImage
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
	button.frame = CGRectMake(130.0, 3.0, 60, 44);
	[button setBackgroundImage:buttonImage forState:UIControlStateNormal];
	button.showsTouchWhenHighlighted = YES;
	
	// Action for the button.
	TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
	[button addTarget:appDelegate action:@selector(SHPopupPublisher) forControlEvents:UIControlEventTouchUpInside];
	
	[self.tabBar addSubview:button];
}

- (void)dealloc
{
    [signupView release];
    [tipExplorerView release];
    [super dealloc];
}

@end
