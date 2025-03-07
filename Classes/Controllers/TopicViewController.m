#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import "TopicViewController.h"
#import "TipboxAppDelegate.h"
#import "TipViewController.h"
#import "WebViewController.h"
#import "MeViewController.h"
#import "FollowerListViewController.h"
#import "Publisher.h"
#import "ReportViewController.h"
#import "EGOImageView.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation TopicViewController

@synthesize topicName, viewTopicid, userFollowsTopic;

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

- (void)followTopic
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    [appDelegate.strobeLight activateStrobeLight];
    followTopicButton.enabled = NO;
    
    NSURL *apiurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/followtopic", SH_DOMAIN]];
    
    dataRequest_child = [ASIFormDataRequest requestWithURL:apiurl];
    [dataRequest_child setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest_child setPostValue:[NSNumber numberWithInt:viewTopicid] forKey:@"topicid"];
    [dataRequest_child setCompletionBlock:^{
        NSError *jsonError;
        responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        NSString *HUDImageName;
        
        if ([[responseData_child objectForKey:@"error"] intValue] == 0) {
            if (userFollowsTopic) {
                HUDImageName = @"cross_white.png";
                HUD.labelText = @"Unfollowed";
                userFollowsTopic = NO;
                followTopicButton.title = @"Follow";
                followerCount--;
            } else {
                HUDImageName = @"check_white.png";
                HUD.labelText = @"Following";
                userFollowsTopic = YES;
                followTopicButton.title = @"Unfollow";
                followerCount++;
            }
            
            followCountButtonTitle.text = [NSString stringWithFormat:@"%d FOLLOWER%@", followerCount, followerCount == 1 ? @"" : @"S"];
            followTopicButton.enabled = YES;
            
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:HUDImageName]] autorelease];
            HUD.mode = MBProgressHUDModeCustomView; // Set custom view mode.
            HUD.dimBackground = YES;
            HUD.delegate = self;
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:2];
            [appDelegate.strobeLight deactivateStrobeLight];
        } else {
            NSLog(@"Follow error!");
            
            if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
        
    }];
    [dataRequest_child setFailedBlock:^{
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
        
        followTopicButton.enabled = YES; // Enable ze button.
        
        NSError *error = [dataRequest_child error];
        NSLog(@"%@", error);
    }];
    [dataRequest_child startAsynchronous];
}

- (void)getTopicInfo
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    followTopicButton.enabled = NO;
    
    NSURL *apiurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/gettopicinfo", SH_DOMAIN]];
    
    dataRequest_child = [ASIFormDataRequest requestWithURL:apiurl];
    [dataRequest_child setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest_child setPostValue:[NSNumber numberWithInt:viewTopicid] forKey:@"topicid"];
    [dataRequest_child setCompletionBlock:^{
        NSError *jsonError;
        responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData_child objectForKey:@"error"] intValue] == 0 && ![[NSNull null] isEqual:[responseData_child objectForKey:@"responce"]]) {
            NSDictionary *responce = [responseData_child objectForKey:@"responce"];
            
            topicName = [[responce objectForKey:@"content"] retain];
            topicCreationDate_relative = [[responce objectForKey:@"relativeTime"] retain];
            topicCreationDate_actual = [[responce objectForKey:@"time"] retain];
            userFollowsTopic = [[[responce objectForKey:@"followsTopic"] retain] boolValue];
            followerCount = [[[responce objectForKey:@"followCount"] retain] intValue];
            tipCount = [[[responce objectForKey:@"tipCount"] retain] intValue];
            topicCreatorUsername = [[responce objectForKey:@"topicCreatorUsername"] retain];
            topicCreatorUserid = [[[responce objectForKey:@"userid"] retain] intValue];
            followers = [[responce objectForKey:@"followers"] retain];
            
            if ([followers count] > 0) {
                followCountButton.enabled = YES;
                [self setUpFacemash];
            } else {
                followCountButton.enabled = NO;
            }
            
            if ([[NSNull null] isEqual:[responce objectForKey:@"genius"]]) {
                geniusUserid = 0;
                geniusNameLabel.hidden = YES;
                geniusUsernameLabel.hidden = YES;
                userThmbnlOverlayView.hidden = YES;
                userThmbnl.hidden = YES;
                emptyGeniusLabel.hidden = NO;
                geniusStripChevron.hidden = YES;
                geniusButton.enabled = YES;
                [geniusButton removeTarget:self action:@selector(gotoGenius) forControlEvents:UIControlEventTouchUpInside];
                [geniusButton addTarget:self action:@selector(createTipOnTopic_noCat) forControlEvents:UIControlEventTouchUpInside];
            } else {
                geniusName = [[responce objectForKey:@"fullname"] retain];
                geniusUsername = [[responce objectForKey:@"username"] retain];
                geniusPicHash = [[responce objectForKey:@"pichash"] retain];
                geniusUserid = [[[responce objectForKey:@"genius"] retain] intValue];
                
                geniusNameLabel.hidden = NO;
                geniusUsernameLabel.hidden = NO;
                userThmbnlOverlayView.hidden = NO;
                userThmbnl.hidden = NO;
                emptyGeniusLabel.hidden = YES;
                geniusStripChevron.hidden = NO;
                geniusButton.enabled = YES;
                [geniusButton removeTarget:self action:@selector(createTipOnTopic_noCat) forControlEvents:UIControlEventTouchUpInside];
                [geniusButton addTarget:self action:@selector(gotoGenius) forControlEvents:UIControlEventTouchUpInside];
                
                geniusNameLabel.text = geniusName;
                geniusUsernameLabel.text = [NSString stringWithFormat:@"@%@", geniusUsername];
                
                NSString *profilePicPath = [NSString stringWithFormat:@"http://%@/userphotos/%d/profile/m_%@.jpg", SH_DOMAIN, geniusUserid, geniusPicHash];
                userThmbnl.imageURL = [NSURL URLWithString:profilePicPath];
            }
            
            topicCreationDateLabel.text = [NSString stringWithFormat:@"Created %@ by", topicCreationDate_relative];
            topicCreatorLabel.text = [NSString stringWithFormat:@"@%@", topicCreatorUsername];
            followCountButtonTitle.text = [NSString stringWithFormat:@"%d FOLLOWER%@", followerCount, followerCount == 1 ? @"" : @"S"];
            feedTitle.text = [NSString stringWithFormat:@"%d TIP%@", tipCount, tipCount == 1 ? @"" : @"S"];
            
            CGSize topicCreationDateSize = [topicCreationDateLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE] constrainedToSize:CGSizeMake(250, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
            CGSize topicCreatorSize = [topicCreatorLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE] constrainedToSize:CGSizeMake(61, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
            
            topicCreationDateLabel.frame = CGRectMake(9, 17, topicCreationDateSize.width, 13);
            topicCreatorButton.frame = CGRectMake(topicCreationDateSize.width + 10, 17, topicCreatorSize.width + 4, 17);
            topicCreatorLabel.frame = CGRectMake(2, 2, topicCreatorSize.width, 13);
            
            [self setTitle:topicName];
            followTopicButton.enabled = YES;
            
            if (userFollowsTopic) {
                followTopicButton.title = @"Unfollow";
            } else {
                followTopicButton.title = @"Follow";
            }
            
            [self downloadTimeline:@"gettipsbytopicid" batch:batchNo];
        } else {
            NSLog(@"Error getting topic info!");
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Topic Error!"
                                  message:@"Dang! Seems like this topic no longer exists." delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            alert.tag = 0;
            [alert show];
            [alert release];
            
            if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
        
    }];
    [dataRequest_child setFailedBlock:^{
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
        [self performSelector:@selector(doneLoadingTableViewData)];
        
        [loadMoreCell hideEndMarker];
        [loadMoreCell.button setTitle:@"Could not connect!" forState:UIControlStateDisabled];
        loadMoreCell.buttonTxtShadow.text = @"Could not connect!";
        loadMoreCell.userInteractionEnabled = NO;
        loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:3];
        
        NSError *error = [dataRequest_child error];
        NSLog(@"%@", error);
    }];
    [dataRequest_child startAsynchronous];
}

- (void)gotoFollowerList
{
    FollowerListViewController *followerListView = [[FollowerListViewController alloc] 
                                     initWithNibName:@"FollowerListView" 
                                     bundle:[NSBundle mainBundle]];
    
    followerListView.topicid = viewTopicid;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:topicName style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:followerListView animated:YES];
	[followerListView release];
	followerListView = nil;
}

- (void)gotoGenius
{
    MeViewController *profileView = [[MeViewController alloc] 
                                     initWithNibName:@"MeView" 
                                     bundle:[NSBundle mainBundle]];
    
    profileView.isCurrentUser = NO;
    profileView.profileOwnerUsername = geniusUsername;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:topicName style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:profileView animated:YES];
	[profileView release];
	profileView = nil;
}

- (void)gotoTopicCreator
{
    MeViewController *profileView = [[MeViewController alloc] 
                                     initWithNibName:@"MeView" 
                                     bundle:[NSBundle mainBundle]];
    
    profileView.isCurrentUser = NO;
    profileView.profileOwnerUsername = topicCreatorUsername;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:topicName style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:profileView animated:YES];
	[profileView release];
	profileView = nil;
}

- (void)createTipOnTopic_noCat
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    appDelegate.mainTabBarController.tabBar.hidden = YES;
    [appDelegate navbarShadowMode_navbar];
    [appDelegate tabbarShadowMode_nobar];
    [appDelegate showNavbarShadowAnimated:YES];
    [appDelegate showTabbarShadowAnimated:YES];
    
    Publisher *pub = [[Publisher alloc] init];
    UINavigationController *publisherNavigationController = [[UINavigationController alloc] initWithRootViewController:pub];
    pub.category = -1; // Default value.
    pub.topicid = viewTopicid;
    pub.topic = topicName;
    [appDelegate.mainTabBarController presentModalViewController:publisherNavigationController animated:true];
	[pub release];
    [publisherNavigationController release];
}

- (void)viewDidLoad
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showNavbarShadowAnimated:YES];
    
    [self setTitle:topicName];
    followTopicButton = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStyleBordered target:self action:@selector(followTopic)];
    self.navigationItem.rightBarButtonItem = followTopicButton;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    
    selectedIndexes = [[NSMutableDictionary alloc] init];
    feedEntries = [[NSMutableArray alloc] init];
    global = appDelegate.global;
    feed_targetid = viewTopicid;
    
    followTopicButton.title = @"Follow";
    tipCount = 0;
    geniusUserid = 0;
    
    if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] 
                             initWithFrame:CGRectMake(0, 0 - timelineFeed.bounds.size.height, self.view.frame.size.width, timelineFeed.bounds.size.height)];
		refreshHeaderView.delegate = self;
		[timelineFeed addSubview:refreshHeaderView];
	}
    
    [self getTopicInfo];
    
    topicCreationDateLabel = [[UILabel alloc] init];
    topicCreationDateLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
	topicCreationDateLabel.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
    topicCreationDateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    topicCreationDateLabel.shadowOffset = CGSizeMake(0, 1);
	topicCreationDateLabel.numberOfLines = 1;
    topicCreationDateLabel.minimumFontSize = 8.;
    topicCreationDateLabel.adjustsFontSizeToFitWidth = YES;
	topicCreationDateLabel.font = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
    topicCreationDateLabel.opaque = YES;
    
    topicCreatorLabel = [[UILabel alloc] init];
    topicCreatorLabel.backgroundColor = [UIColor clearColor];
    topicCreatorLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:185.0/255.0 alpha:1.0];
    topicCreatorLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    topicCreatorLabel.shadowOffset = CGSizeMake(0, 1);
    topicCreatorLabel.numberOfLines = 1;
    topicCreatorLabel.minimumFontSize = 8.;
    topicCreatorLabel.adjustsFontSizeToFitWidth = YES;
    topicCreatorLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    
    topicCreatorButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    topicCreatorButton.layer.masksToBounds = YES;
    topicCreatorButton.layer.cornerRadius = 4;
    topicCreatorButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    [topicCreatorButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [topicCreatorButton addTarget:self action:@selector(gotoTopicCreator) forControlEvents:UIControlEventTouchUpInside];
    
    dottedDivider = [[UIView alloc] init];
    dottedDivider.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_grey.png"]];
    dottedDivider.frame = CGRectMake(0, 43, 320, 2);
    dottedDivider.opaque = YES;
    
    followCountButtonIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small_grey_user.png"]];
    followCountButtonIconView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    followCountButtonIconView.frame = CGRectMake(9, 61, 14, 14);
    followCountButtonIconView.opaque = YES;
    
    followCountButtonTitle = [[UILabel alloc] initWithFrame:CGRectMake(28, 64, 287, 10)];
    followCountButtonTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
	followCountButtonTitle.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
    followCountButtonTitle.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    followCountButtonTitle.shadowOffset = CGSizeMake(0, 1);
	followCountButtonTitle.numberOfLines = 1;
    followCountButtonTitle.minimumFontSize = 8.;
    followCountButtonTitle.adjustsFontSizeToFitWidth = YES;
	followCountButtonTitle.font = [UIFont boldSystemFontOfSize:MIN_SECONDARY_FONT_SIZE];
    followCountButtonTitle.text = @"0 FOLLOWERS";
    followCountButtonTitle.opaque = YES;
    
    followCountButtonBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
    followCountButtonBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    followCountButtonBg.frame = CGRectMake(9, 82, 301, 43);
    followCountButtonBg.opaque = YES;
    followCountButtonBg.userInteractionEnabled = YES;
    
    followCountButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    followCountButton.frame = CGRectMake(4, 4, 293, 35);
    followCountButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    [followCountButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [followCountButton addTarget:self action:@selector(gotoFollowerList) forControlEvents:UIControlEventTouchUpInside];
    followCountButton.enabled = NO;
    
    facemashFrame_1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beige_user_icon_overlay_small.png"]];
    facemashFrame_2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beige_user_icon_overlay_small.png"]];
    facemashFrame_3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beige_user_icon_overlay_small.png"]];
    facemashFrame_4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beige_user_icon_overlay_small.png"]];
    facemashFrame_5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beige_user_icon_overlay_small.png"]];
    facemashFrame_6 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beige_user_icon_overlay_small.png"]];
    facemashFrame_7 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beige_user_icon_overlay_small.png"]];
    facemashFrame_8 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beige_user_icon_overlay_small.png"]];
    facemashFrame_9 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beige_user_icon_overlay_small.png"]];
    
    facemashFrame_1.frame = CGRectMake(5, 5, 25, 26);
    facemashFrame_2.frame = CGRectMake(35, 5, 25, 26);
    facemashFrame_3.frame = CGRectMake(65, 5, 25, 26);
    facemashFrame_4.frame = CGRectMake(95, 5, 25, 26);
    facemashFrame_5.frame = CGRectMake(125, 5, 25, 26);
    facemashFrame_6.frame = CGRectMake(155, 5, 25, 26);
    facemashFrame_7.frame = CGRectMake(185, 5, 25, 26);
    facemashFrame_8.frame = CGRectMake(215, 5, 25, 26);
    facemashFrame_9.frame = CGRectMake(245, 5, 25, 26);
    
    facemash_1 = [[EGOImageView alloc] initWithFrame:CGRectMake(1, 1, 23, 24)];
    facemash_1.layer.masksToBounds = YES;
    facemash_1.layer.cornerRadius = 2;
    facemash_1.layer.shouldRasterize = YES;
    facemash_1.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    facemash_2 = [[EGOImageView alloc] initWithFrame:CGRectMake(1, 1, 23, 24)];
    facemash_2.layer.masksToBounds = YES;
    facemash_2.layer.cornerRadius = 2;
    facemash_2.layer.shouldRasterize = YES;
    facemash_2.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    facemash_3 = [[EGOImageView alloc] initWithFrame:CGRectMake(1, 1, 23, 24)];
    facemash_3.layer.masksToBounds = YES;
    facemash_3.layer.cornerRadius = 2;
    facemash_3.layer.shouldRasterize = YES;
    facemash_3.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    facemash_4 = [[EGOImageView alloc] initWithFrame:CGRectMake(1, 1, 23, 24)];
    facemash_4.layer.masksToBounds = YES;
    facemash_4.layer.cornerRadius = 2;
    facemash_4.layer.shouldRasterize = YES;
    facemash_4.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    facemash_5 = [[EGOImageView alloc] initWithFrame:CGRectMake(1, 1, 23, 24)];
    facemash_5.layer.masksToBounds = YES;
    facemash_5.layer.cornerRadius = 2;
    facemash_5.layer.shouldRasterize = YES;
    facemash_5.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    facemash_6 = [[EGOImageView alloc] initWithFrame:CGRectMake(1, 1, 23, 24)];
    facemash_6.layer.masksToBounds = YES;
    facemash_6.layer.cornerRadius = 2;
    facemash_6.layer.shouldRasterize = YES;
    facemash_6.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    facemash_7 = [[EGOImageView alloc] initWithFrame:CGRectMake(1, 1, 23, 24)];
    facemash_7.layer.masksToBounds = YES;
    facemash_7.layer.cornerRadius = 2;
    facemash_7.layer.shouldRasterize = YES;
    facemash_7.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    facemash_8 = [[EGOImageView alloc] initWithFrame:CGRectMake(1, 1, 23, 24)];
    facemash_8.layer.masksToBounds = YES;
    facemash_8.layer.cornerRadius = 2;
    facemash_8.layer.shouldRasterize = YES;
    facemash_8.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    facemash_9 = [[EGOImageView alloc] initWithFrame:CGRectMake(1, 1, 23, 24)];
    facemash_9.layer.masksToBounds = YES;
    facemash_9.layer.cornerRadius = 2;
    facemash_9.layer.shouldRasterize = YES;
    facemash_9.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    followCountStripChevron = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feed_chevron_grey.png"]];
    followCountStripChevron.frame = CGRectMake(282, 13, 10, 17);
    
    geniusButtonIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genius_star.png"]];
    geniusButtonIconView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    geniusButtonIconView.frame = CGRectMake(9, 135, 14, 14);
    geniusButtonIconView.opaque = YES;
    
    geniusButtonTitle = [[UILabel alloc] initWithFrame:CGRectMake(28, 139, 287, 10)];
    geniusButtonTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
	geniusButtonTitle.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
    geniusButtonTitle.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    geniusButtonTitle.shadowOffset = CGSizeMake(0, 1);
	geniusButtonTitle.numberOfLines = 1;
    geniusButtonTitle.minimumFontSize = 8.;
    geniusButtonTitle.adjustsFontSizeToFitWidth = YES;
	geniusButtonTitle.font = [UIFont boldSystemFontOfSize:MIN_SECONDARY_FONT_SIZE];
    geniusButtonTitle.text = @"GENIUS";
    geniusButtonTitle.opaque = YES;
    
    geniusButtonBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
    geniusButtonBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    geniusButtonBg.frame = CGRectMake(9, 155, 301, 50);
    geniusButtonBg.opaque = YES;
    geniusButtonBg.userInteractionEnabled = YES;
    
    geniusButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    geniusButton.frame = CGRectMake(4, 4, 293, 42);
    geniusButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    [geniusButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    geniusButton.enabled = NO;
    
    userThmbnl = [[EGOImageView alloc] initWithFrame:CGRectMake(9, 9, 30, 30)];
    userThmbnl.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
    userThmbnl.opaque = YES;
    userThmbnl.layer.shouldRasterize = YES;
    userThmbnl.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    UIImage *userThmbnlOverlay = [[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:3.0];
    userThmbnlOverlayView = [[UIImageView alloc] initWithImage:userThmbnlOverlay];
    userThmbnlOverlayView.frame = CGRectMake(6, 7, 36, 36);
    
    geniusNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 7, 258, 20)];
    geniusNameLabel.backgroundColor = [UIColor clearColor];
    geniusNameLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    geniusNameLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    geniusNameLabel.shadowOffset = CGSizeMake(0, 1);
    geniusNameLabel.numberOfLines = 1;
    geniusNameLabel.minimumFontSize = 8.;
    geniusNameLabel.adjustsFontSizeToFitWidth = YES;
    geniusNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
    geniusNameLabel.text = @"Loading...";
    
    geniusUsernameLabel = [[LPLabel alloc] initWithFrame:CGRectMake(48, 25, 258, 20)];
    geniusUsernameLabel.backgroundColor = [UIColor clearColor];
    geniusUsernameLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    geniusUsernameLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    geniusUsernameLabel.numberOfLines = 1;
    geniusUsernameLabel.minimumFontSize = 8.;
    geniusUsernameLabel.adjustsFontSizeToFitWidth = YES;
    geniusUsernameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    geniusUsernameLabel.text = @"";
    
    emptyGeniusLabel = [[LPLabel alloc] initWithFrame:CGRectMake(10, 7, 287, 38)];
    emptyGeniusLabel.backgroundColor = [UIColor clearColor];
    emptyGeniusLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    emptyGeniusLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    emptyGeniusLabel.numberOfLines = 0;
    emptyGeniusLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    emptyGeniusLabel.text = @"There's no genius in this topic yet. Leave a tip here and it could be you!";
    emptyGeniusLabel.opaque = YES;
    emptyGeniusLabel.hidden = YES;
    
    geniusStripChevron = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feed_chevron_grey.png"]];
    geniusStripChevron.frame = CGRectMake(279, 17, 10, 17);
    
    feedTitleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small_grey_bulb.png"]];
    feedTitleIconView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    feedTitleIconView.frame = CGRectMake(9, 223, 14, 14);
    feedTitleIconView.opaque = YES;
    
    feedTitle = [[UILabel alloc] initWithFrame:CGRectMake(28, 226, 287, 10)];
    feedTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
	feedTitle.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
    feedTitle.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    feedTitle.shadowOffset = CGSizeMake(0, 1);
	feedTitle.numberOfLines = 1;
    feedTitle.minimumFontSize = 8.;
    feedTitle.adjustsFontSizeToFitWidth = YES;
	feedTitle.font = [UIFont boldSystemFontOfSize:MIN_SECONDARY_FONT_SIZE];
    feedTitle.text = @"0 TIPS";
    feedTitle.opaque = YES;
    
    tableHeader = [[UIView alloc] init];
    tableHeader.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    tableHeader.opaque = YES;
    timelineFeed.tableHeaderView = tableHeader;
    
    [tableHeader addSubview:topicCreationDateLabel];
    [tableHeader addSubview:topicCreatorButton];
    [tableHeader addSubview:dottedDivider];
    [tableHeader addSubview:followCountButtonIconView];
    [tableHeader addSubview:followCountButtonTitle];
    [tableHeader addSubview:followCountButtonBg];
    [topicCreatorButton addSubview:topicCreatorLabel];
    [followCountButtonBg addSubview:followCountButton];
    [followCountButton addSubview:facemashFrame_1];
    [followCountButton addSubview:facemashFrame_2];
    [followCountButton addSubview:facemashFrame_3];
    [followCountButton addSubview:facemashFrame_4];
    [followCountButton addSubview:facemashFrame_5];
    [followCountButton addSubview:facemashFrame_6];
    [followCountButton addSubview:facemashFrame_7];
    [followCountButton addSubview:facemashFrame_8];
    [followCountButton addSubview:facemashFrame_9];
    [facemashFrame_1 addSubview:facemash_1];
    [facemashFrame_2 addSubview:facemash_2];
    [facemashFrame_3 addSubview:facemash_3];
    [facemashFrame_4 addSubview:facemash_4];
    [facemashFrame_5 addSubview:facemash_5];
    [facemashFrame_6 addSubview:facemash_6];
    [facemashFrame_7 addSubview:facemash_7];
    [facemashFrame_8 addSubview:facemash_8];
    [facemashFrame_9 addSubview:facemash_9];
    [followCountButtonBg addSubview:followCountStripChevron];
    [tableHeader addSubview:geniusButtonIconView];
    [tableHeader addSubview:geniusButtonTitle];
    [tableHeader addSubview:geniusButtonBg];
    [geniusButtonBg addSubview:geniusButton];
    [geniusButtonBg addSubview:userThmbnlOverlayView];
    [geniusButtonBg addSubview:userThmbnl];
    [geniusButtonBg addSubview:geniusNameLabel];
    [geniusButtonBg addSubview:geniusUsernameLabel];
    [geniusButtonBg addSubview:geniusNameLabel];
    [geniusButtonBg addSubview:geniusUsernameLabel];
    [geniusButtonBg addSubview:emptyGeniusLabel];
    [geniusButtonBg addSubview:geniusStripChevron];
    [tableHeader addSubview:feedTitleIconView];
    [tableHeader addSubview:feedTitle];
    
    CGRect tableHeaderFrame = timelineFeed.tableHeaderView.frame;
	tableHeaderFrame.size.height = 232;
	timelineFeed.tableHeaderView.frame = tableHeaderFrame;
	timelineFeed.tableHeaderView = tableHeader;
    
    [super viewDidLoad];
}

#pragma mark Customizations when the view appears/disappears
- (void)viewWillAppear:(BOOL)animated
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.mainTabBarController.tabBar.hidden) {
        [appDelegate tabbarShadowMode_nobar];
    } else {
        [appDelegate tabbarShadowMode_tabbar];
    }
    
    [appDelegate navbarShadowMode_navbar];
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
        [appDelegate.strobeLight deactivateStrobeLight];
        
        if ([[viewControllers objectAtIndex:0] isKindOfClass:[Publisher class]]) {
            [appDelegate navbarShadowMode_searchbar];
        }
    }
}

#pragma mark Timeline delegate methods
- (void)timelineDidFinishDownloading
{
    timelineDidDownload = YES;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight deactivateStrobeLight];
    [self performSelector:@selector(doneLoadingTableViewData)];
    [timelineFeed reloadData];
}

- (void)timelineFailedToDownload
{	
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
    [self performSelector:@selector(doneLoadingTableViewData)];
    
    timelineDidDownload = NO;
    
    [loadMoreCell hideEndMarker];
    [loadMoreCell.button setTitle:@"Could not connect!" forState:UIControlStateDisabled];
    loadMoreCell.buttonTxtShadow.text = @"Could not connect!";
    loadMoreCell.userInteractionEnabled = NO;
    loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
	
    [HUD show:YES];
	[HUD hide:YES afterDelay:3];
}

#pragma mark UITableViewDataSource
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f
#define CELL_COLLAPSED_HEIGHT 87
#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Add an object to the end of the array for the "Load more..." table cell.
    return [feedEntries count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Special cases:
	// 1: if search results count == 0, display a giant blank UITableViewCell, and disable user interaction.
	// 2: if last cell, display the "Load more" search results UITableViewCell.
    
    UITableViewCell *assembledCell;
    int lastIndex = [feedEntries count] - 1;
    
    if (indexPath.row == [feedEntries count]) { // Special Case 2		
		static NSString *CellIdentifier = @"LoadMoreCell";
		loadMoreCell = (LoadMoreCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
		if (loadMoreCell == nil) {
            loadMoreCell = [[[LoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            loadMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
            loadMoreCell.frame = CGRectMake(0, 0, 320, loadMoreCell.frame.size.height);
            [loadMoreCell.button addTarget:self action:@selector(loadMoreFeedEntries) forControlEvents:UIControlEventTouchUpInside];
		}
		
        if (!timelineDidDownload) {
            [loadMoreCell hideEndMarker];
            [loadMoreCell.button setTitle:@"Loading..." forState:UIControlStateDisabled];
            loadMoreCell.buttonTxtShadow.text = @"Loading...";
            loadMoreCell.userInteractionEnabled = NO;
            loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
        } else {
            if (endOfFeed) {
                [loadMoreCell showEndMarker];
            } else {
                [loadMoreCell hideEndMarker];
                [loadMoreCell.button setTitle:@"Load more" forState:UIControlStateNormal];
                loadMoreCell.buttonTxtShadow.text = @"Load more";
                loadMoreCell.userInteractionEnabled = YES;
                loadMoreCell.button.enabled = YES; // Then don't forget to re-enable it!
            }
        }
        
		assembledCell = loadMoreCell;
		
	} else if (indexPath.row <= lastIndex && timelineDidDownload == YES) {
        static NSString *CellIdentifier = @"TimelineCell";
        timelineCell = (TipCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        BOOL isSelected = [self cellIsSelected:indexPath];
        
        if (timelineCell == nil) {
            timelineCell = [[[TipCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            timelineCell.frame = CGRectMake(0, 0, 320, timelineCell.frame.size.height);
            isSelected = NO;
            
            [timelineCell.tipCardView.facemash_1 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
            [timelineCell.tipCardView.facemash_2 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
            [timelineCell.tipCardView.facemash_3 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
            [timelineCell.tipCardView.facemash_4 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
            [timelineCell.tipCardView.facemash_5 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
            [timelineCell.tipCardView.facemash_6 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
            [timelineCell.tipCardView.facemash_7 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
            [timelineCell.tipCardView.markUsefulButton addTarget:self action:@selector(markUseful:) forControlEvents:UIControlEventTouchUpInside];
            [timelineCell.tipCardView.pane_gotoTipButton addTarget:self action:@selector(gotoTip:) forControlEvents:UIControlEventTouchUpInside];
            [timelineCell.tipCardView.pane_gotoUserButton addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
            [timelineCell.tipCardView.pane_tipOptionsButton addTarget:self action:@selector(showMoreTipOptions:) forControlEvents:UIControlEventTouchUpInside];
            [timelineCell.tipCardView.pane_shareButton addTarget:self action:@selector(showTipSharingOptions:) forControlEvents:UIControlEventTouchUpInside];
            [timelineCell.tipCardView.pane_deleteButton addTarget:self action:@selector(showTipDeletionOptions:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        timelineCell.tipCardView.isSelected = isSelected;
        timelineCell.tipCardView.rowNumber = indexPath.row;
        [timelineCell.tipCardView populateViewWithContent:[self.feedEntries objectAtIndex:indexPath.row]];
        
        assembledCell = timelineCell;
    }
    
    return assembledCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    CGFloat height;
    int lastIndex = [feedEntries count] - 1;
    
    if ([feedEntries count] > 0 && indexPath.row <= lastIndex && timelineDidDownload == YES) {
        NSMutableDictionary *tip = [feedEntries objectAtIndex:indexPath.row];
        int tipUserid = [[tip objectForKey:@"userid"] intValue];
        NSString *content = [tip objectForKey:@"content"];
        
        CGSize tipTxtSize;
        
        // Since the mark button is hidden, we might as well use up that otherwise wasted space. ;)
        if ([[global readProperty:@"userid"] intValue] == tipUserid) {
            tipTxtSize = [content sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(288, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        } else {
            tipTxtSize = [content sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(253, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        }
        
        if ([self cellIsSelected:indexPath]) {
            height = MAX(tipTxtSize.height + 255, 60);
        } else {
            height = MAX(tipTxtSize.height + 203 - CELL_COLLAPSED_HEIGHT, 60);
        }
    } else {
        height = 50;
    }
	
	return height + (CELL_CONTENT_MARGIN * 2);
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
    int lastIndex = [feedEntries count] - 1;
    
    if ([self.feedEntries count] > 0 && indexPath.row <= lastIndex) {
        // NIFTY SHORTCUT (BELOW): Double-tap a tip to directly go to the tip view without bringing up the action card.
        // checking for double taps here
        if (tapCount == 1 && tapTimer != nil && tappedRow == indexPath.row) {
            // Double tap - Put double tap code here.
            [tapTimer invalidate];
            tapTimer = nil;
            
            doubleTapRow = tappedRow;
            
            TipCell *targetCell = (TipCell *)[tableView cellForRowAtIndexPath:indexPath];
            [targetCell.tipCardView.pane_gotoTipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            
            tapCount = 0;
            tappedRow = -1;
        } else if (tapCount == 0) {
            // This is the first tap. If there is no tap till tapTimer is fired, it's a single tap.
            tapCount = 1;
            tappedRow = indexPath.row;
            tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self 
                                                      selector:@selector(tapTimerFired:) 
                                                      userInfo:nil repeats:NO];
        } else if (tappedRow != indexPath.row) {
            // tap on new row
            tapCount = 0;
            if (tapTimer != nil) {
                [tapTimer invalidate];
                tapTimer = nil;
            }
        }
    }
}

- (void)tapTimerFired:(NSTimer *)aTimer
{
    // Timer fired! There was a single tap on indexPath.row = tappedRow.
    // Do something here with tappedRow.
    if (tapTimer != nil) {
        NSIndexPath *indexPath_tappedRow = [NSIndexPath indexPathForRow:tappedRow inSection:0];
        NSIndexPath *indexPath_lastTappedRow = [NSIndexPath indexPathForRow:lastTappedRow inSection:0];
        
        TipCell *cell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath_tappedRow];
        [cell collapseCell];
        
        // Toggle 'selected' state
        BOOL isSelected = ![self cellIsSelected:[NSIndexPath indexPathForRow:tappedRow inSection:0]];
        
        // Store cell 'selected' state keyed on indexPath
        NSNumber *selectedIndex = [NSNumber numberWithBool:isSelected];
        [selectedIndexes setObject:selectedIndex forKey:[NSIndexPath indexPathForRow:tappedRow inSection:0]];
		cell.tipCardView.isSelected = isSelected;
        
        if (lastTappedRow != tappedRow) { // Collapse any other cell (unless if it's the same one, this will cause fuckage).
            TipCell *oldCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath_lastTappedRow];
            
            NSNumber *oldIndex = [NSNumber numberWithBool:FALSE];
            [selectedIndexes setObject:oldIndex forKey:indexPath_lastTappedRow];
            
            if (indexPath_lastTappedRow.row != [feedEntries count]) { // We don't want it sending wrong messages to the "Load more" cell.
                [oldCell collapseCell];
                oldCell.tipCardView.isSelected = FALSE;
            }
        }
        
        // This is where the magic happens...
        [timelineFeed beginUpdates];
        [timelineFeed endUpdates];
        
        if (lastTappedRow == tappedRow) {
            lastTappedRow = -1;
        } else {
            lastTappedRow = tappedRow;
        }
        
        tapCount = 0;
        tappedRow = -1;
    }
}

- (void)didSwipeTableViewCell:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint swipeLocation = [gestureRecognizer locationInView:timelineFeed];
        NSIndexPath *swipedIndexPath = [timelineFeed indexPathForRowAtPoint:swipeLocation];
        int lastIndex = [feedEntries count] - 1;
        
        if ([feedEntries count] > 0 && swipedIndexPath.row <= lastIndex && timelineDidDownload == YES) {
            TipCell *targetCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:swipedIndexPath];
            [targetCell.tipCardView.pane_gotoTipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)loadMoreFeedEntries
{
    [loadMoreCell.button setTitle:@"Loading..." forState:UIControlStateDisabled];
    loadMoreCell.buttonTxtShadow.text = @"Loading...";
    loadMoreCell.userInteractionEnabled = NO;
    loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
    
    [self downloadTimeline:@"gettipsbytopicid" batch:++batchNo];
}

#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource
{
	NSIndexPath *indexPath_lastTappedRow = [NSIndexPath indexPathForRow:lastTappedRow inSection:0];
    
    TipCell *cell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath_lastTappedRow];
    
    if (cell.tipCardView.isSelected) {
        tapCount = 1;
        
        tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                  selector:@selector(tapTimerFired:)
                                                  userInfo:nil repeats:NO];
    }
    
    [loadMoreCell hideEndMarker];
    [loadMoreCell.button setTitle:@"Loading..." forState:UIControlStateDisabled];
    loadMoreCell.buttonTxtShadow.text = @"Loading...";
    loadMoreCell.userInteractionEnabled = NO;
    loadMoreCell.button.enabled = NO; // Don't forget to disable the button!
    
    batchNo = 0;
    [self getTopicInfo];
	reloading = YES;	
}

- (void)doneLoadingTableViewData
{
	//  Model should call this when its done loading
	reloading = NO;
	[refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:timelineFeed];
}

#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	[refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];	
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
	return reloading; // should return if data source model is reloading	
}

/*
 - (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
 {
 return [NSDate date]; // should return date data source was last changed	
 }
*/

- (void)markUseful:(id)sender
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    ToggleButton *markUsefulButton = (ToggleButton *)sender;
    TipCell *targetCell = (TipCell *)[[[[markUsefulButton superview] superview] superview] superview];
    NSIndexPath *indexPath = [timelineFeed indexPathForCell:targetCell];
    
    if (targetCell.tipCardView.marked == YES) {
        [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button.png"] forState:UIControlStateNormal];
        markUsefulButton.activated = NO;
        targetCell.tipCardView.marked = NO;
        [[self.feedEntries objectAtIndex:indexPath.row] setObject:@"NO" forKey:@"marked"]; // Modify our copy of the data.
        
        targetCell.tipCardView.usefulCount--;
    } else if (targetCell.tipCardView.marked == NO) {
        [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button_activated.png"] forState:UIControlStateNormal];
        markUsefulButton.activated = YES;
        targetCell.tipCardView.marked = YES;
        [targetCell.tipCardView playMarkingAnimation];
        [[self.feedEntries objectAtIndex:indexPath.row] setObject:@"YES" forKey:@"marked"]; // Modify our copy of the data.
        
        targetCell.tipCardView.usefulCount++;
    }
    
    [targetCell.tipCardView redisplayUsefulnessData];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/liketip", SH_DOMAIN]];
    
    dataRequest_child = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest_child setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest_child setPostValue:[NSNumber numberWithInt:targetCell.tipCardView.tipid] forKey:@"tipid"];
    [dataRequest_child setCompletionBlock:^{
        NSError *jsonError;
        responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData_child objectForKey:@"error"] intValue] == 0) {
            
        } else {
            // Revert the button's state.
            if (targetCell.tipCardView.marked == YES) {
                [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button.png"] forState:UIControlStateNormal];
                markUsefulButton.activated = NO;
                targetCell.tipCardView.marked = NO;
                [[self.feedEntries objectAtIndex:indexPath.row] setObject:@"NO" forKey:@"marked"]; // Modify our copy of the data.
                
                targetCell.tipCardView.usefulCount--;
            } else if (targetCell.tipCardView.marked == NO) {
                [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button_activated.png"] forState:UIControlStateNormal];
                markUsefulButton.activated = YES;
                targetCell.tipCardView.marked = YES;
                [[self.feedEntries objectAtIndex:indexPath.row] setObject:@"YES" forKey:@"marked"]; // Modify our copy of the data.
                
                targetCell.tipCardView.usefulCount++;
            }
            
            [targetCell.tipCardView redisplayUsefulnessData];
            
            NSLog(@"Could not mark/unmark tip!\nError:\n%@", dataRequest_child.responseString);
            [appDelegate.strobeLight negativeStrobeLight];
            
            if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
    }];
    [dataRequest_child setFailedBlock:^{
        [appDelegate.strobeLight negativeStrobeLight];
        
        // Revert the button's state.
        if (targetCell.tipCardView.marked == YES) {
            [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button.png"] forState:UIControlStateNormal];
            markUsefulButton.activated = NO;
            targetCell.tipCardView.marked = NO;
            [[self.feedEntries objectAtIndex:indexPath.row] setObject:@"NO" forKey:@"marked"]; // Modify our copy of the data.
            
            targetCell.tipCardView.usefulCount--;
        } else if (targetCell.tipCardView.marked == NO) {
            [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button_activated.png"] forState:UIControlStateNormal];
            markUsefulButton.activated = YES;
            targetCell.tipCardView.marked = YES;
            [[self.feedEntries objectAtIndex:indexPath.row] setObject:@"YES" forKey:@"marked"]; // Modify our copy of the data.
            
            targetCell.tipCardView.usefulCount++;
        }
        
        [targetCell.tipCardView redisplayUsefulnessData];
        
        NSError *error = [dataRequest_child error];
        NSLog(@"%@", error);
    }];
    [dataRequest_child startAsynchronous];
}

- (void)gotoTip:(id)sender
{
    UIButton *gotoTipButton = (UIButton *)sender;
    TipCell *targetCell = (TipCell *)[[[[[[gotoTipButton superview] superview] superview] superview] superview] superview];
    NSIndexPath *indexPath = [timelineFeed indexPathForCell:targetCell];
    int tipid = targetCell.tipCardView.tipid;
    NSString *content = targetCell.tipCardView.content;
    NSString *name = targetCell.tipCardView.fullname;
    NSString *username = targetCell.tipCardView.username;
    int userid = targetCell.tipCardView.tipUserid;
    NSString *userPicHash = targetCell.tipCardView.userPicHash;
    NSString *timestamp = targetCell.tipCardView.timestamp;
    NSString *timestamp_short = targetCell.tipCardView.timestamp_short;
    NSString *actualTime = targetCell.tipCardView.actualTime;
    int usefulCount = targetCell.tipCardView.usefulCount;
    NSMutableArray *participantData = targetCell.tipCardView.participantData;
    int catid = targetCell.tipCardView.catid;
    NSString *subcat = targetCell.tipCardView.subcat;
    NSString *parentCat = targetCell.tipCardView.parentCat;
    int topicid = targetCell.tipCardView.topicid;
    NSString *topicContent = targetCell.tipCardView.topicContent;
    BOOL followsTopic = targetCell.tipCardView.followsTopic;
    int genius = targetCell.tipCardView.genius;
    
    // Initialize the detail view controller and display it.
    TipViewController *tipView = [[TipViewController alloc] 
                                  initWithNibName:@"TipView" 
                                  bundle:[NSBundle mainBundle]];
    
    tipView.motherCellIndexPath = indexPath;
    tipView.tipid = tipid;
    tipView.tipUserid = userid;
    tipView.subcat = subcat;
    tipView.parentCat = parentCat;
    tipView.catid = catid;
    tipView.topicid = topicid;
    tipView.topicContent = topicContent;
    tipView.userFollowsTopic = followsTopic;
    tipView.tipFullName = name;
    tipView.tipUsername = username;
    tipView.tipUserPicHash = userPicHash;
    tipView.content = content;
    tipView.tipTimestamp = timestamp;
    tipView.tipTimestamp_short = timestamp_short;
    tipView.tipActualTime = actualTime;
    tipView.usefulCount = usefulCount;
    tipView.participantData = participantData;
    tipView.marked = targetCell.tipCardView.marked;
    tipView.genius = genius;
	
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:topicName style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:tipView animated:YES];
	[tipView release];
	tipView = nil;
}

#pragma mark Follow/Unfollow the topic of the tip
- (void)followTopicAtIndexPath:(NSIndexPath *)indexPath
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    TipCell *targetCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath];
    BOOL userFollowsTipTopic = targetCell.tipCardView.followsTopic;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/followtopic", SH_DOMAIN]];
    
    [appDelegate.strobeLight activateStrobeLight];
    dataRequest_child = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest_child setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest_child setPostValue:[NSNumber numberWithInt:targetCell.tipCardView.topicid] forKey:@"topicid"];
    [dataRequest_child setCompletionBlock:^{
        NSError *jsonError;
        responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData_child objectForKey:@"error"] intValue] == 0) {
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            NSString *HUDImageName;
            
            if (userFollowsTipTopic) {
                targetCell.tipCardView.followsTopic = 0;
                
                HUDImageName = @"cross_white.png";
                HUD.labelText = @"Unfollowed";
            } else {
                targetCell.tipCardView.followsTopic = 1;
                
                HUDImageName = @"check_white.png";
                HUD.labelText = @"Following";
            }
            
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:HUDImageName]] autorelease];
            HUD.mode = MBProgressHUDModeCustomView; // Set custom view mode.
            HUD.dimBackground = YES;
            HUD.delegate = self;
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:2];
            [appDelegate.strobeLight deactivateStrobeLight];
        } else {
            NSLog(@"Could not follow/unfollow topic!\nError:\n%@", dataRequest_child.responseString);
            [appDelegate.strobeLight negativeStrobeLight];
            
            if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
    }];
    [dataRequest_child setFailedBlock:^{
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
        
        NSError *error = [dataRequest_child error];
        NSLog(@"%@", error);
    }];
    [dataRequest_child startAsynchronous];
}

#pragma mark Handle the tip sharing options
- (void)handleTipSharingAtIndexPath:(NSIndexPath *)indexPath forButtonAtIndex:(NSInteger)buttonIndex
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    TipCell *targetCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *content = targetCell.tipCardView.content;
    
    if (buttonIndex == 0) {         // Copy Tip
        pasteboard.string = content;
    } else if (buttonIndex == 1) {  // Copy Link to Tip
        pasteboard.string = [NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, targetCell.tipCardView.tipid];
    } else if (buttonIndex == 2) {  // Mail Tip
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        NSString *emailBody = [NSString stringWithFormat:
                               @"<strong>%@</strong> <span style='color:#777;'>(@%@)</span> shared this tip on <em>%@</em> with you!<br /><br />“%@”<br /><br /><em style='color:#777;'>(Source on Tipbox: <a href=\"http://%@/tipbox/tip/%d\" style='color:#0073b9;text-decoration:none;'>http://%@/tipbox/tip/%d</a>)</em>", 
                               targetCell.tipCardView.fullname,
                               targetCell.tipCardView.username,
                               targetCell.tipCardView.topicContent,
                               content, 
                               SH_DOMAIN, 
                               targetCell.tipCardView.tipid, 
                               SH_DOMAIN, 
                               targetCell.tipCardView.tipid]; // Fill out the email body text.
        [picker setSubject:[NSString stringWithFormat:@"A tip on %@ • Tipbox", targetCell.tipCardView.topicContent]];
        [picker setMessageBody:emailBody isHTML:YES]; // Depends. Mostly YES, unless you want to send it as plain text (boring).
        
        picker.navigationBar.tintColor = [UIColor colorWithRed:162/255.0 green:165/255.0 blue:152/255.0 alpha:1.0];
        
        [appDelegate navbarShadowMode_navbar];
        [appDelegate tabbarShadowMode_nobar];
        [self presentModalViewController:picker animated:YES];
        [picker release];
    } else if (buttonIndex == 3) {  // Facebook
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *fbController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            NSString *previewTxt = targetCell.tipCardView.content;
            
            SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result) {
                [fbController dismissViewControllerAnimated:YES completion:nil];
                
                switch(result) {
                    case SLComposeViewControllerResultCancelled:
                    default:
                    {
                        NSLog(@"Cancelled!");
                        
                    }
                        break;
                    case SLComposeViewControllerResultDone:
                    {
                        NSLog(@"Posted!");
                    }
                        break;
                }};
            
            [fbController setInitialText:[NSString stringWithFormat:@"%@ (via Tipbox)", previewTxt]];
            [fbController addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, targetCell.tipCardView.tipid]]];
            [fbController setCompletionHandler:completionHandler];
            [self presentViewController:fbController animated:YES completion:nil];
        } else {
            FBSBJSON *jsonWriter = [[FBSBJSON new] autorelease];
            
            NSMutableDictionary *params;
            
            // Dialog parameters
            if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
                params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          @"A tip on Tipbox", @"name",
                          @"Tipbox is tip sharing, reinvented for your iPhone.", @"caption",
                          targetCell.tipCardView.content, @"description",
                          [NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, targetCell.tipCardView.tipid], @"link",
                          @"http://scapehouse.com/graphics/en/icons/tipbox_icon_medium.png", @"picture",
                          nil];
            } else {
                NSArray* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [NSString stringWithFormat:@"@%@ on Tipbox", [global readProperty:@"username"]], @"name", @"http://scapehouse.com/", @"link", nil], nil];
                NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
                
                params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%@ shared a tip on Tipbox",  [global readProperty:@"name"]], @"name",
                          @"Tipbox is tip sharing, reinvented for your iPhone.", @"caption",
                          targetCell.tipCardView.content, @"description",
                          [NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, targetCell.tipCardView.tipid], @"link",
                          @"http://scapehouse.com/graphics/en/icons/tipbox_icon_medium.png", @"picture",
                          actionLinksStr, @"actions",
                          nil];
            }
            
            [appDelegate.facebook dialog:@"feed"
                               andParams:params
                             andDelegate:self];
        }
    } else if (buttonIndex == 4) {  // Tweet
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init]; // Create the tweet sheet.
        NSString *previewTxt = targetCell.tipCardView.content;
        
        if (previewTxt.length > 69) {
            previewTxt = [NSString stringWithFormat:@"%@… #Tipbox (by @Scapehouse)", [previewTxt substringToIndex:68]];
        } else {
            previewTxt = [NSString stringWithFormat:@"%@ #Tipbox (by @Scapehouse)", previewTxt];
        }
        
        [tweetSheet setInitialText:previewTxt];
        [tweetSheet addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, targetCell.tipCardView.tipid]]];
        
        tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result) { // Set a blocking handler for the tweet sheet.
            dispatch_async(dispatch_get_main_queue(), ^{            
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            });
        };
        
        // Show the tweet sheet!
        [self presentModalViewController:tweetSheet animated:YES];
        [tweetSheet release];
    } else if (buttonIndex == 5) { // Message
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate = self;
            
            NSString *messageBody = [NSString stringWithFormat:@"%@ (Source on Tipbox: http://%@/tipbox/tip/%d)", content, SH_DOMAIN, targetCell.tipCardView.tipid]; // Fill out the body text.
            [picker setBody:messageBody];
            
            picker.navigationBar.tintColor = [UIColor colorWithRed:162/255.0 green:165/255.0 blue:152/255.0 alpha:1.0];
            
            [appDelegate navbarShadowMode_navbar];
            [appDelegate tabbarShadowMode_nobar];
            [self presentModalViewController:picker animated:YES];
            [picker release];
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

#pragma mark Handle tip deletion
- (void)handleTipDeletionAtIndexPath:(NSIndexPath *)indexPath
{
    // We have to deselct the cell before deleting it, otherwise the next cell opens up when this one's gone.
    // The code here's basically the same as the one handling a single tap on it to collapse it.
    TipCell *targetCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath];
    
    tapCount = 1;
    tappedRow = indexPath.row;
    tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self 
                                              selector:@selector(tapTimerFired:) 
                                              userInfo:nil repeats:NO];
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/deletetip", SH_DOMAIN]];
    
    dataRequest_child = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest_child setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest_child setPostValue:[NSNumber numberWithInt:targetCell.tipCardView.tipid] forKey:@"tipid"];
    [dataRequest_child setCompletionBlock:^{
        NSError *jsonError;
        responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData_child objectForKey:@"error"] intValue] == 0) {
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [targetCell.tipCardView.card setFrame:CGRectMake(targetCell.tipCardView.card.frame.origin.x - targetCell.tipCardView.card.frame.size.width, targetCell.tipCardView.card.frame.origin.y, targetCell.tipCardView.card.frame.size.width, targetCell.tipCardView.card.frame.size.height)];
                targetCell.tipCardView.card.alpha = 0;
            } completion:^(BOOL finished){
                [feedEntries removeObjectAtIndex:indexPath.row];
                [timelineFeed deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [timelineFeed reloadData];
                
                // Reset other cards on this index path.
                [UIView animateWithDuration:0.5 delay:0.4 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [targetCell.tipCardView.card setFrame:CGRectMake(targetCell.tipCardView.card.frame.origin.x + targetCell.tipCardView.card.frame.size.width, targetCell.tipCardView.card.frame.origin.y, targetCell.tipCardView.card.frame.size.width, targetCell.tipCardView.card.frame.size.height)];
                    targetCell.tipCardView.card.alpha = 1;
                } completion:^(BOOL finished){
                    
                }];
            }];
            
            [appDelegate.strobeLight deactivateStrobeLight];
        } else {
            NSLog(@"Could not delete tip!\nError:\n%@", dataRequest_child.responseString);
            [appDelegate.strobeLight negativeStrobeLight];
            
            if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
    }];
    [dataRequest_child setFailedBlock:^{
        NSError *error = [dataRequest_child error];
        NSLog(@"%@", error);
    }];
    [dataRequest_child startAsynchronous];
}

#pragma mark Handle creating a tip on the topic of the cell
- (void)handleTipCreationAtIndexPath:(NSIndexPath *)indexPath
{
    // Collapse the cell first.
    // The code here's basically the same as the one handling a single tap on it to collapse it.
    TipCell *targetCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath];
    
    tapCount = 1;
    tappedRow = indexPath.row;
    tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self 
                                              selector:@selector(tapTimerFired:) 
                                              userInfo:nil repeats:NO];
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    int topicid = targetCell.tipCardView.topicid;
    NSString *topicContent = targetCell.tipCardView.topicContent;
    NSString *subcat = targetCell.tipCardView.subcat;
    int catid = targetCell.tipCardView.catid;
    int category;
    
    if ([targetCell.tipCardView.parentCat isEqualToString:@"thing"]) {
        category = 0;
    } else if ([targetCell.tipCardView.parentCat isEqualToString:@"place"]) {
        category = 1;
    } else {
        category = 2;
    }
    
    if ([subcat isEqualToString:@"none"]) {
        subcat = @"This category doesn't need a subcategory.";
    }
    
    appDelegate.mainTabBarController.tabBar.hidden = YES;
    [appDelegate navbarShadowMode_navbar];
    [appDelegate tabbarShadowMode_nobar];
    [appDelegate showNavbarShadowAnimated:YES];
    [appDelegate showTabbarShadowAnimated:YES];
    
    Publisher *pub = [[Publisher alloc] init];
    UINavigationController *publisherNavigationController = [[UINavigationController alloc] initWithRootViewController:pub];
    pub.category = category;
    pub.topicid = topicid;
    pub.topic = topicContent;
    [appDelegate.mainTabBarController presentModalViewController:publisherNavigationController animated:true];
    pub.subcategory = catid;
    pub.selectedCategoryButtonSubtitle.text = subcat;
	[pub release];
    [publisherNavigationController release];
}

#pragma mark Handle tip reporting
- (void)handleTipReportingAtIndexPath:(NSIndexPath *)indexPath
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    TipCell *targetCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:indexPath];
    int tipid = targetCell.tipCardView.tipid;
    
    ReportViewController *reportView = [[ReportViewController alloc] initWithNibName:@"ReportView" bundle:nil];
    reportView.reportType = @"tip";
    reportView.objectid = tipid;
    [self presentModalViewController:reportView animated:true];
    [reportView release];
}

/* * * * * * * * * * * * * * * * * * *
 * TAG REFERENCE
 * =============
 * 10: Tip details Pane: Facemash 1.
 * 20: Tip details Pane: Facemash 2.
 * 30: Tip details Pane: Facemash 3.
 * 40: Tip details Pane: Facemash 4.
 * 50: Tip details Pane: Facemash 5.
 * 60: Tip details Pane: Facemash 6.
 * 70: Tip details Pane: Facemash 7.
 * * * * * * * * * * * * * * * * * * */
- (void)gotoUser:(id)sender
{
    UIButton *gotoUserButton = (UIButton *)sender;
    FacemashPhoto *facemash = (FacemashPhoto *)sender;
    TipCell *targetCell = (TipCell *)[[[[[[gotoUserButton superview] superview] superview] superview] superview] superview];
    NSMutableArray *participantData = targetCell.tipCardView.participantData;
	NSString *username;
    
    // Facemash handlers.
    switch (gotoUserButton.tag) {
        case 10:
        {
            NSDictionary *data_facemash_1 = [participantData objectAtIndex:0];
            username = [data_facemash_1 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
            
        case 20:
        {
            NSDictionary *data_facemash_2 = [participantData objectAtIndex:1];
            username = [data_facemash_2 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
        case 30:
        {
            NSDictionary *data_facemash_3 = [participantData objectAtIndex:2];
            username = [data_facemash_3 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
        case 40:
        {
            NSDictionary *data_facemash_4 = [participantData objectAtIndex:3];
            username = [data_facemash_4 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
        case 50:
        {
            NSDictionary *data_facemash_5 = [participantData objectAtIndex:4];
            username = [data_facemash_5 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
        case 60:
        {
            NSDictionary *data_facemash_6 = [participantData objectAtIndex:5];
            username = [data_facemash_6 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
        case 70:
        {
            NSDictionary *data_facemash_7 = [participantData objectAtIndex:6];
            username = [data_facemash_7 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
        default: // Non-facemash handler.
            username = targetCell.tipCardView.username;
            break;
    }
    
	// Initialize the detail view controller and display it.
	MeViewController *profileView = [[MeViewController alloc] 
                                     initWithNibName:@"MeView" 
                                     bundle:[NSBundle mainBundle]];		// Creating new detail view controller instance.
	
    profileView.isCurrentUser = NO;
    profileView.profileOwnerUsername = username;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:topicName style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:profileView animated:YES];	// "Pushing the controller on the screen".
	[profileView release];                                                      // Releasing controller from the memory.
    profileView = nil;
    
}

- (void)showMoreTipOptions:(id)sender
{
    UIButton *button = (UIButton *)sender;
    TipCell *targetCell = (TipCell *)[[[[[[button superview] superview] superview] superview] superview] superview];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:targetCell.tipCardView.rowNumber inSection:0];
    BOOL userFollowsTipTopic = targetCell.tipCardView.followsTopic;
    
    if (userFollowsTipTopic) {
        if ([[global readProperty:@"userid"] intValue] == targetCell.tipCardView.tipUserid) {
            genericOptions = [[UITableViewActionSheet alloc] 
                              initWithTitle:@"More Options" 
                              delegate:self
                              cancelButtonTitle:@"Cancel" 
                              destructiveButtonTitle:@"Unfollow Topic" 
                              otherButtonTitles:@"New Tip On Topic", nil];
        } else {
            genericOptions = [[UITableViewActionSheet alloc] 
                              initWithTitle:@"More Options" 
                              delegate:self
                              cancelButtonTitle:@"Cancel" 
                              destructiveButtonTitle:@"Unfollow Topic" 
                              otherButtonTitles:@"New Tip On Topic", @"Report Tip", nil];
        }
    } else {
        if ([[global readProperty:@"userid"] intValue] == targetCell.tipCardView.tipUserid) {
            genericOptions = [[UITableViewActionSheet alloc] 
                              initWithTitle:@"More Options" 
                              delegate:self
                              cancelButtonTitle:@"Cancel" 
                              destructiveButtonTitle:nil 
                              otherButtonTitles:@"Follow Topic", @"New Tip On Topic", nil];
        } else {
            genericOptions = [[UITableViewActionSheet alloc] 
                              initWithTitle:@"More Options" 
                              delegate:self
                              cancelButtonTitle:@"Cancel" 
                              destructiveButtonTitle:nil 
                              otherButtonTitles:@"Follow Topic", @"New Tip On Topic", @"Report Tip", nil];
        }
        
    }
    
	genericOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    genericOptions.tag = 102;
    genericOptions.indexPath = indexPath;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
	[genericOptions showFromTabBar:appDelegate.mainTabBarController.tabBar];
}

- (void)showTipSharingOptions:(id)sender
{
    UIButton *button = (UIButton *)sender;
    TipCell *targetCell = (TipCell *)[[[[[[button superview] superview] superview] superview] superview] superview];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:targetCell.tipCardView.rowNumber inSection:0];
    
    sharingOptions = [[UITableViewActionSheet alloc] 
                      initWithTitle:@"Share this tip" 
                      delegate:self
                      cancelButtonTitle:@"Cancel" 
                      destructiveButtonTitle:nil 
                      otherButtonTitles:@"Copy Tip", @"Copy Link to Tip", @"Mail Tip", @"Facebook", @"Tweet", @"Message", nil];
	
	sharingOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    sharingOptions.tag = 100;
    sharingOptions.indexPath = indexPath;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
	[sharingOptions showFromTabBar:appDelegate.mainTabBarController.tabBar];
}

- (void)showTipDeletionOptions:(id)sender
{
    UIButton *button = (UIButton *)sender;
    TipCell *targetCell = (TipCell *)[[[[[[button superview] superview] superview] superview] superview] superview];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:targetCell.tipCardView.rowNumber inSection:0];
    
	deletionOptions = [[UITableViewActionSheet alloc] 
                       initWithTitle:@"Delete this tip?" 
                       delegate:self
                       cancelButtonTitle:@"Cancel" 
                       destructiveButtonTitle:@"Delete" 
                       otherButtonTitles:nil];
	deletionOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    deletionOptions.tag = 101;
    deletionOptions.indexPath = indexPath;
    
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
	[deletionOptions showFromTabBar:appDelegate.mainTabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITableViewActionSheet *targetActionSheet = (UITableViewActionSheet *)actionSheet;
    
    if (targetActionSheet.tag == 100) {        // Sharing options
        
        [self handleTipSharingAtIndexPath:targetActionSheet.indexPath forButtonAtIndex:buttonIndex];
        
    } else if (targetActionSheet.tag == 101) { // Deletion options
        
        if (buttonIndex == 0) {                                                 // Delete
            [self handleTipDeletionAtIndexPath:targetActionSheet.indexPath];
        }
        
    } else if (targetActionSheet.tag == 102) {  // Generic options
        
        if (buttonIndex == 0) {                                                 // Follow topic
            [self followTopicAtIndexPath:targetActionSheet.indexPath];
        } else if (buttonIndex == 1) {                                          // New Tip on Topic
            [self handleTipCreationAtIndexPath:targetActionSheet.indexPath];
        } else if (buttonIndex == 2 && actionSheet.numberOfButtons == 4) {      // Report Tip
            [self handleTipReportingAtIndexPath:targetActionSheet.indexPath];
        }
        
    }
}

#pragma UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        if (buttonIndex == 0) { // GTFO of this view 'cuz this topic don't exist!
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)setUpFacemash
{
    // Facemash setup.
    switch ([followers count]) {
        case 0:
        {
            facemash_1.imageURL = nil;
            facemash_1.placeholderImage = nil;
            facemash_2.imageURL = nil;
            facemash_2.placeholderImage = nil;
            facemash_3.imageURL = nil;
            facemash_3.placeholderImage = nil;
            facemash_4.imageURL = nil;
            facemash_4.placeholderImage = nil;
            facemash_5.imageURL = nil;
            facemash_5.placeholderImage = nil;
            facemash_6.imageURL = nil;
            facemash_6.placeholderImage = nil;
            facemash_7.imageURL = nil;
            facemash_7.placeholderImage = nil;
            facemash_8.imageURL = nil;
            facemash_8.placeholderImage = nil;
            facemash_9.imageURL = nil;
            facemash_9.placeholderImage = nil;
            break;
        }
            
        case 1:
        {
            NSDictionary *data_facemash_1 = [followers objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            facemash_2.imageURL = nil;
            facemash_2.placeholderImage = nil;
            facemash_3.imageURL = nil;
            facemash_3.placeholderImage = nil;
            facemash_4.imageURL = nil;
            facemash_4.placeholderImage = nil;
            facemash_5.imageURL = nil;
            facemash_5.placeholderImage = nil;
            facemash_6.imageURL = nil;
            facemash_6.placeholderImage = nil;
            facemash_7.imageURL = nil;
            facemash_7.placeholderImage = nil;
            facemash_8.imageURL = nil;
            facemash_8.placeholderImage = nil;
            facemash_9.imageURL = nil;
            facemash_9.placeholderImage = nil;
            break;
        }
            
        case 2:
        {
            NSDictionary *data_facemash_1 = [followers objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [followers objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            facemash_3.imageURL = nil;
            facemash_3.placeholderImage = nil;
            facemash_4.imageURL = nil;
            facemash_4.placeholderImage = nil;
            facemash_5.imageURL = nil;
            facemash_5.placeholderImage = nil;
            facemash_6.imageURL = nil;
            facemash_6.placeholderImage = nil;
            facemash_7.imageURL = nil;
            facemash_7.placeholderImage = nil;
            facemash_8.imageURL = nil;
            facemash_8.placeholderImage = nil;
            facemash_9.imageURL = nil;
            facemash_9.placeholderImage = nil;
            break;
        }
            
        case 3:
        {
            NSDictionary *data_facemash_1 = [followers objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [followers objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            
            NSDictionary *data_facemash_3 = [followers objectAtIndex:2];
            NSString *profilePicPath_facemash_3 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_3 objectForKey:@"userid"], [data_facemash_3 objectForKey:@"pichash"]];
            facemash_3.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_3.imageURL = [NSURL URLWithString:profilePicPath_facemash_3];
            facemash_4.imageURL = nil;
            facemash_4.placeholderImage = nil;
            facemash_5.imageURL = nil;
            facemash_5.placeholderImage = nil;
            facemash_6.imageURL = nil;
            facemash_6.placeholderImage = nil;
            facemash_7.imageURL = nil;
            facemash_7.placeholderImage = nil;
            facemash_8.imageURL = nil;
            facemash_8.placeholderImage = nil;
            facemash_9.imageURL = nil;
            facemash_9.placeholderImage = nil;
            break;
        }
            
        case 4:
        {
            NSDictionary *data_facemash_1 = [followers objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [followers objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            
            NSDictionary *data_facemash_3 = [followers objectAtIndex:2];
            NSString *profilePicPath_facemash_3 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_3 objectForKey:@"userid"], [data_facemash_3 objectForKey:@"pichash"]];
            facemash_3.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_3.imageURL = [NSURL URLWithString:profilePicPath_facemash_3];
            
            NSDictionary *data_facemash_4 = [followers objectAtIndex:3];
            NSString *profilePicPath_facemash_4 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_4 objectForKey:@"userid"], [data_facemash_4 objectForKey:@"pichash"]];
            facemash_4.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_4.imageURL = [NSURL URLWithString:profilePicPath_facemash_4];
            facemash_5.imageURL = nil;
            facemash_5.placeholderImage = nil;
            facemash_6.imageURL = nil;
            facemash_6.placeholderImage = nil;
            facemash_7.imageURL = nil;
            facemash_7.placeholderImage = nil;
            facemash_8.imageURL = nil;
            facemash_8.placeholderImage = nil;
            facemash_9.imageURL = nil;
            facemash_9.placeholderImage = nil;
            break;
        }
            
        case 5:
        {
            NSDictionary *data_facemash_1 = [followers objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [followers objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            
            NSDictionary *data_facemash_3 = [followers objectAtIndex:2];
            NSString *profilePicPath_facemash_3 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_3 objectForKey:@"userid"], [data_facemash_3 objectForKey:@"pichash"]];
            facemash_3.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_3.imageURL = [NSURL URLWithString:profilePicPath_facemash_3];
            
            NSDictionary *data_facemash_4 = [followers objectAtIndex:3];
            NSString *profilePicPath_facemash_4 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_4 objectForKey:@"userid"], [data_facemash_4 objectForKey:@"pichash"]];
            facemash_4.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_4.imageURL = [NSURL URLWithString:profilePicPath_facemash_4];
            
            NSDictionary *data_facemash_5 = [followers objectAtIndex:4];
            NSString *profilePicPath_facemash_5 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_5 objectForKey:@"userid"], [data_facemash_5 objectForKey:@"pichash"]];
            facemash_5.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_5.imageURL = [NSURL URLWithString:profilePicPath_facemash_5];
            facemash_6.imageURL = nil;
            facemash_6.placeholderImage = nil;
            facemash_7.imageURL = nil;
            facemash_7.placeholderImage = nil;
            facemash_8.imageURL = nil;
            facemash_8.placeholderImage = nil;
            facemash_9.imageURL = nil;
            facemash_9.placeholderImage = nil;
            break;
        }
            
        case 6:
        {
            NSDictionary *data_facemash_1 = [followers objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [followers objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            
            NSDictionary *data_facemash_3 = [followers objectAtIndex:2];
            NSString *profilePicPath_facemash_3 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_3 objectForKey:@"userid"], [data_facemash_3 objectForKey:@"pichash"]];
            facemash_3.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_3.imageURL = [NSURL URLWithString:profilePicPath_facemash_3];
            
            NSDictionary *data_facemash_4 = [followers objectAtIndex:3];
            NSString *profilePicPath_facemash_4 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_4 objectForKey:@"userid"], [data_facemash_4 objectForKey:@"pichash"]];
            facemash_4.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_4.imageURL = [NSURL URLWithString:profilePicPath_facemash_4];
            
            NSDictionary *data_facemash_5 = [followers objectAtIndex:4];
            NSString *profilePicPath_facemash_5 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_5 objectForKey:@"userid"], [data_facemash_5 objectForKey:@"pichash"]];
            facemash_5.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_5.imageURL = [NSURL URLWithString:profilePicPath_facemash_5];
            
            NSDictionary *data_facemash_6 = [followers objectAtIndex:5];
            NSString *profilePicPath_facemash_6 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_6 objectForKey:@"userid"], [data_facemash_6 objectForKey:@"pichash"]];
            facemash_6.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_6.imageURL = [NSURL URLWithString:profilePicPath_facemash_6];
            facemash_7.imageURL = nil;
            facemash_7.placeholderImage = nil;
            facemash_8.imageURL = nil;
            facemash_8.placeholderImage = nil;
            facemash_9.imageURL = nil;
            facemash_9.placeholderImage = nil;
            break;
        }
            
        case 7:
        {
            NSDictionary *data_facemash_1 = [followers objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [followers objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            
            NSDictionary *data_facemash_3 = [followers objectAtIndex:2];
            NSString *profilePicPath_facemash_3 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_3 objectForKey:@"userid"], [data_facemash_3 objectForKey:@"pichash"]];
            facemash_3.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_3.imageURL = [NSURL URLWithString:profilePicPath_facemash_3];
            
            NSDictionary *data_facemash_4 = [followers objectAtIndex:3];
            NSString *profilePicPath_facemash_4 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_4 objectForKey:@"userid"], [data_facemash_4 objectForKey:@"pichash"]];
            facemash_4.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_4.imageURL = [NSURL URLWithString:profilePicPath_facemash_4];
            
            NSDictionary *data_facemash_5 = [followers objectAtIndex:4];
            NSString *profilePicPath_facemash_5 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_5 objectForKey:@"userid"], [data_facemash_5 objectForKey:@"pichash"]];
            facemash_5.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_5.imageURL = [NSURL URLWithString:profilePicPath_facemash_5];
            
            NSDictionary *data_facemash_6 = [followers objectAtIndex:5];
            NSString *profilePicPath_facemash_6 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_6 objectForKey:@"userid"], [data_facemash_6 objectForKey:@"pichash"]];
            facemash_6.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_6.imageURL = [NSURL URLWithString:profilePicPath_facemash_6];
            
            NSDictionary *data_facemash_7 = [followers objectAtIndex:6];
            NSString *profilePicPath_facemash_7 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_7 objectForKey:@"userid"], [data_facemash_7 objectForKey:@"pichash"]];
            facemash_7.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_7.imageURL = [NSURL URLWithString:profilePicPath_facemash_7];
            facemash_8.imageURL = nil;
            facemash_8.placeholderImage = nil;
            facemash_9.imageURL = nil;
            facemash_9.placeholderImage = nil;
            break;
        }
            
        case 8:
        {
            NSDictionary *data_facemash_1 = [followers objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [followers objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            
            NSDictionary *data_facemash_3 = [followers objectAtIndex:2];
            NSString *profilePicPath_facemash_3 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_3 objectForKey:@"userid"], [data_facemash_3 objectForKey:@"pichash"]];
            facemash_3.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_3.imageURL = [NSURL URLWithString:profilePicPath_facemash_3];
            
            NSDictionary *data_facemash_4 = [followers objectAtIndex:3];
            NSString *profilePicPath_facemash_4 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_4 objectForKey:@"userid"], [data_facemash_4 objectForKey:@"pichash"]];
            facemash_4.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_4.imageURL = [NSURL URLWithString:profilePicPath_facemash_4];
            
            NSDictionary *data_facemash_5 = [followers objectAtIndex:4];
            NSString *profilePicPath_facemash_5 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_5 objectForKey:@"userid"], [data_facemash_5 objectForKey:@"pichash"]];
            facemash_5.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_5.imageURL = [NSURL URLWithString:profilePicPath_facemash_5];
            
            NSDictionary *data_facemash_6 = [followers objectAtIndex:5];
            NSString *profilePicPath_facemash_6 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_6 objectForKey:@"userid"], [data_facemash_6 objectForKey:@"pichash"]];
            facemash_6.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_6.imageURL = [NSURL URLWithString:profilePicPath_facemash_6];
            
            NSDictionary *data_facemash_7 = [followers objectAtIndex:6];
            NSString *profilePicPath_facemash_7 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_7 objectForKey:@"userid"], [data_facemash_7 objectForKey:@"pichash"]];
            facemash_7.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_7.imageURL = [NSURL URLWithString:profilePicPath_facemash_7];
            
            NSDictionary *data_facemash_8 = [followers objectAtIndex:7];
            NSString *profilePicPath_facemash_8 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_8 objectForKey:@"userid"], [data_facemash_8 objectForKey:@"pichash"]];
            facemash_8.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_8.imageURL = [NSURL URLWithString:profilePicPath_facemash_8];
            facemash_9.imageURL = nil;
            facemash_9.placeholderImage = nil;
            break;
        }
            
        case 9:
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 15:
        {
            NSDictionary *data_facemash_1 = [followers objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [followers objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            
            NSDictionary *data_facemash_3 = [followers objectAtIndex:2];
            NSString *profilePicPath_facemash_3 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_3 objectForKey:@"userid"], [data_facemash_3 objectForKey:@"pichash"]];
            facemash_3.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_3.imageURL = [NSURL URLWithString:profilePicPath_facemash_3];
            
            NSDictionary *data_facemash_4 = [followers objectAtIndex:3];
            NSString *profilePicPath_facemash_4 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_4 objectForKey:@"userid"], [data_facemash_4 objectForKey:@"pichash"]];
            facemash_4.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_4.imageURL = [NSURL URLWithString:profilePicPath_facemash_4];
            
            NSDictionary *data_facemash_5 = [followers objectAtIndex:4];
            NSString *profilePicPath_facemash_5 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_5 objectForKey:@"userid"], [data_facemash_5 objectForKey:@"pichash"]];
            facemash_5.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_5.imageURL = [NSURL URLWithString:profilePicPath_facemash_5];
            
            NSDictionary *data_facemash_6 = [followers objectAtIndex:5];
            NSString *profilePicPath_facemash_6 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_6 objectForKey:@"userid"], [data_facemash_6 objectForKey:@"pichash"]];
            facemash_6.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_6.imageURL = [NSURL URLWithString:profilePicPath_facemash_6];
            
            NSDictionary *data_facemash_7 = [followers objectAtIndex:6];
            NSString *profilePicPath_facemash_7 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_7 objectForKey:@"userid"], [data_facemash_7 objectForKey:@"pichash"]];
            facemash_7.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_7.imageURL = [NSURL URLWithString:profilePicPath_facemash_7];
            
            NSDictionary *data_facemash_8 = [followers objectAtIndex:7];
            NSString *profilePicPath_facemash_8 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_8 objectForKey:@"userid"], [data_facemash_8 objectForKey:@"pichash"]];
            facemash_8.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_8.imageURL = [NSURL URLWithString:profilePicPath_facemash_8];
            
            NSDictionary *data_facemash_9 = [followers objectAtIndex:8];
            NSString *profilePicPath_facemash_9 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_9 objectForKey:@"userid"], [data_facemash_9 objectForKey:@"pichash"]];
            facemash_9.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_9.imageURL = [NSURL URLWithString:profilePicPath_facemash_9];
            break;
        }
            
        default:
        {
            break;
        }
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super.view willMoveToSuperview:newSuperview];
	
	if (!newSuperview) {
		[userThmbnl cancelImageLoad];
        [facemash_1 cancelImageLoad];
        [facemash_2 cancelImageLoad];
        [facemash_3 cancelImageLoad];
        [facemash_4 cancelImageLoad];
        [facemash_5 cancelImageLoad];
        [facemash_6 cancelImageLoad];
        [facemash_7 cancelImageLoad];
        [facemash_8 cancelImageLoad];
        [facemash_9 cancelImageLoad];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [selectedIndexes release];
    [feedEntries release];
    [refreshHeaderView release];
    [genericOptions release];
    [sharingOptions release];
    [deletionOptions release];
    [dottedDivider release];
    [super dealloc];
}

@end
