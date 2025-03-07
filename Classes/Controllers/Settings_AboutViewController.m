#import <QuartzCore/QuartzCore.h>
#import "Settings_AboutViewController.h"
#import "TipboxAppDelegate.h"
#import "WebViewController.h"
#import "MeViewController.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation Settings_AboutViewController

@synthesize scrollView;

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

- (void)viewDidLoad
{
    [self setTitle:@"About Us"];
    scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    [scrollView setContentSize:CGSizeMake(320, 510)];
    
    CALayer *dottedDivider = [CALayer layer];
    dottedDivider.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_grey.png"]].CGColor;
    dottedDivider.opaque = YES;
    [dottedDivider setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
    dottedDivider.frame = CGRectMake(0, 473, 320, 2);
    
    [scrollView.layer addSublayer:dottedDivider];
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

- (IBAction)gotoIdentity:(id)sender
{
    UIButton *link = (UIButton *)sender;
    targetIdentity = link.tag;
    socialLinks = [[UIActionSheet alloc] 
                   initWithTitle:@"Social Media Profiles" 
                   delegate:self
                   cancelButtonTitle:@"Cancel" 
                   destructiveButtonTitle:nil 
                   otherButtonTitles:@"Facebook", @"Twitter", @"Tipbox", nil];
    socialLinks.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [socialLinks showFromTabBar:appDelegate.mainTabBarController.tabBar];
}

- (IBAction)rateApp:(id)sender
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8", appDelegate.SHAppid]];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSURL *url = [NSURL URLWithString:@""];
    WebViewController *webView = [[WebViewController alloc] 
                                  initWithNibName:@"WebView" 
                                  bundle:[NSBundle mainBundle]];
    
    if (buttonIndex == 0) {
        if (targetIdentity == 1) {        // Facebook: akay64
            url = [NSURL URLWithString:@"http://www.facebook.com/akay64"];
            [webView setTitle:@"Facebook"];
        } else if (targetIdentity == 2) { // Facebook: MachOSX
            url = [NSURL URLWithString:@"http://www.facebook.com/MachOSX"];
            [webView setTitle:@"Facebook"];
        } else if (targetIdentity == 3) { // Facebook: LaDyiaNova
            url = [NSURL URLWithString:@"http://www.facebook.com/LaDyiaNova"];
            [webView setTitle:@"Facebook"];
        }
    } else if (buttonIndex == 1) {
        if (targetIdentity == 1) {        // @akay_64
            url = [NSURL URLWithString:@"http://twitter.com/akay_64"];
            [webView setTitle:@"Twitter"];
        } else if (targetIdentity == 2) { // @MachOSX
            url = [NSURL URLWithString:@"http://twitter.com/MachOSX"];
            [webView setTitle:@"Twitter"];
        } else if (targetIdentity == 3) { // @LaDyiaNova
            url = [NSURL URLWithString:@"http://twitter.com/LaDyiaNova"];
            [webView setTitle:@"Twitter"];
        }
    }
    
    if (buttonIndex == 0 || buttonIndex == 1) { // Facebook/Twitter (i.e. external links).        
        webView.url = [url absoluteString];
        webView.hidesBottomBarWhenPushed = YES;
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"About Us" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:webView animated:YES];
        
    } else if (buttonIndex == 2) { // Tipbox profiles.
        NSString *username = @"";
        
        if (targetIdentity == 1) {        // @akay64
            username = @"akay64";
        } else if (targetIdentity == 2) { // @MachOSX
            username = @"MachOSX";
        } else if (targetIdentity == 3) { // @LaDyiaNova
            username = @"LaDyiaNova";
        }
        
        MeViewController *profileView = [[MeViewController alloc] 
                                         initWithNibName:@"MeView" 
                                         bundle:[NSBundle mainBundle]];
        
        profileView.isCurrentUser = NO;
        profileView.profileOwnerUsername = username;
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"About Us" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:profileView animated:YES];
        [profileView release];
        profileView = nil;
    }
    
    [webView release];
    webView = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [scrollView release];
    [socialLinks release];
    [super dealloc];
}


@end
