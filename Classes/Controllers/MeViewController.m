#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import "MeViewController.h"
#import "TipboxAppDelegate.h"
#import "TipViewController.h"
#import "WebViewController.h"
#import "TopicsListViewController.h"
#import "UsefulTipsViewController.h"
#import "Publisher.h"
#import "ReportViewController.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation MeViewController

@synthesize dataRequest_child, isCurrentUser, profileOwnerName, profileOwnerUsername;
@synthesize profileOwnerEmail, profileOwnerHash, profileOwnerLocation, profileOwnerBio;
@synthesize profileOwnerURL, freshTip;

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

- (void)getUserInfoForUsername:(NSString *)username
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    global = appDelegate.global;
    [appDelegate.strobeLight activateStrobeLight];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/getprofile", SH_DOMAIN]];
    
    dataRequest_child = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest_child setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest_child setPostValue:username forKey:@"username"];
    [dataRequest_child setCompletionBlock:^{
        NSError *jsonError;
        responseData_child = [NSJSONSerialization JSONObjectWithData:[dataRequest_child.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[NSNull null] isEqual:responseData_child] || [responseData_child count] == 0) {
            [self userNotFound];
        } else if ([[responseData_child objectForKey:@"error"] intValue] == 0) {
            NSDictionary *responce = [responseData_child objectForKey:@"responce"];
            
            profileOwnerUserid = [[[responce objectForKey:@"id"] retain] intValue];
            profileOwnerName = [[responce objectForKey:@"fullname"] retain];
            profileOwnerUsername = [[responce objectForKey:@"username"] retain];
            profileOwnerEmail = [[responce objectForKey:@"email"] retain];
            profileOwnerHash = [[responce objectForKey:@"pichash"] retain];
            profileOwnerLocation = [[responce objectForKey:@"location"] retain];
            profileOwnerURL = [[responce objectForKey:@"website"] retain];
            profileOwnerBio = [[responce objectForKey:@"bio"] retain];
            tipCount = [[[responce objectForKey:@"tipCount"] retain] intValue];
            geniusCount = [[[responce objectForKey:@"geniusCount"] retain] intValue];
            topicCount = [[[responce objectForKey:@"followCount"] retain] intValue];
            peopleHelped = [[[responce objectForKey:@"helpCount"] retain] intValue];
            foundUsefulCount = [[[responce objectForKey:@"likeCount"] retain] intValue];
            fbID = [[responce objectForKey:@"fbProfile"] retain];
            twitterID = [[responce objectForKey:@"twtProfile"] retain];
            fbConnected = [[[responce objectForKey:@"fbConnected"] retain] boolValue];
            twitterConnected = [[[responce objectForKey:@"twtConnected"] retain] boolValue];
            
            if (![[NSNull null] isEqual:profileOwnerBio]) {
                if (profileOwnerBio.length > 160) {
                    profileOwnerBio = [profileOwnerBio stringByAppendingString:@"..."];
                }
            }
            
            if ([[global readProperty:@"userid"] intValue] == -1 || profileOwnerUserid == [[global readProperty:@"userid"] intValue]) {
                isCurrentUser = YES;
            } else {
                isCurrentUser = NO;
            }
            
            if (isCurrentUser) {
                [appDelegate.global writeValue:[NSString stringWithFormat:@"%d", profileOwnerUserid] forProperty:@"userid"];
                [appDelegate.global writeValue:profileOwnerName forProperty:@"name"];
                [appDelegate.global writeValue:profileOwnerUsername forProperty:@"username"];
                [appDelegate.global writeValue:profileOwnerEmail forProperty:@"email"];
                [appDelegate.global writeValue:profileOwnerHash forProperty:@"userPicHash"];
                [appDelegate.global writeValue:profileOwnerLocation forProperty:@"location"];
                [appDelegate.global writeValue:profileOwnerBio forProperty:@"bio"];
                [appDelegate.global writeValue:profileOwnerURL forProperty:@"url"];
                [appDelegate.global writeValue:[NSString stringWithFormat:@"%@", fbConnected ? @"YES":@"NO"] forProperty:@"fbConnected"];
                [appDelegate.global writeValue:[NSString stringWithFormat:@"%@", twitterConnected ? @"YES":@"NO"] forProperty:@"twitterConnected"];
            }
            
            [self setTitle:[NSString stringWithFormat:@"@%@", [responce objectForKey:@"username"]]];
            [self redrawContents];
            feed_targetid = profileOwnerUserid;
            batchNo = 0;
            [self downloadTimeline:@"gettipsbyuser" batch:batchNo];
        } else {
            if ([[responseData_child objectForKey:@"errormsg"] isEqualToString:@"authFail"] && ![appDelegate.SHToken isEqualToString:@""]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
        
        if (!freshTip) {
            [appDelegate.strobeLight deactivateStrobeLight]; // We don't want it turning off the green strobe light!
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

- (void)userNotFound
{
    profileOwnerCard.hidden = YES;
    profileOwnerCardBg.hidden = YES;
    profileOwnerBioLabel.hidden = YES;
    profileOwnerBioLabelShadow.hidden = YES;
    profileOwnerURLButton.hidden = YES;
    tipCountButton.hidden = YES;
    topicCountButton.hidden = YES;
    geniusCountButton.hidden = YES;
    foundUsefulButtonIconView.hidden = YES;
    foundUsefulButtonTitle.hidden = YES;
    foundUsefulButtonBg.hidden = YES;
    externIdentityButton_fb.hidden = YES;
    externIdentityButton_twitter.hidden = YES;
    feedTitle.hidden = YES;
    loadMoreCell.userInteractionEnabled = NO;
    loadMoreCell.button.enabled = NO;
    [loadMoreCell.button setTitle:@"User not found!" forState:UIControlStateDisabled];
    loadMoreCell.buttonTxtShadow.text = @"User not found!";
    
    if (self != [self.navigationController.viewControllers objectAtIndex:0]) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    timelineFeed.scrollEnabled = NO;
    CGRect tableHeaderFrame = timelineFeed.tableHeaderView.frame;
	tableHeaderFrame.size.height = 150;
	timelineFeed.tableHeaderView.frame = tableHeaderFrame;
	timelineFeed.tableHeaderView = tableHeader;
}

- (void)redrawContents
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Customizations depending on whether the viewed profile is that of the current user.
    if (isCurrentUser) {
        currentUserIndicator.hidden = NO;
        
        profileOwnerHash = [global readProperty:@"userPicHash"];
        profileOwnerUserid = [[global readProperty:@"userid"] intValue];
        profileOwnerName = [global readProperty:@"name"];
        profileOwnerUsername = [global readProperty:@"username"];
        profileOwnerLocation = [global readProperty:@"location"];
        profileOwnerURL = [global readProperty:@"url"];
        profileOwnerBio = [global readProperty:@"bio"];
        fbConnected = [[global readProperty:@"fbConnected"] boolValue];
        twitterConnected = [[global readProperty:@"twitterConnected"] boolValue];
    } else {
        currentUserIndicator.hidden = YES;
    }
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        // Don't do anything.
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = settingsButtonItem;
    }
    
    if (fbID.length > 0) {
        externIdentityButton_fb.hidden = NO;
    } else {
        externIdentityButton_fb.hidden = YES;
    }
    
    if (twitterID.length > 0) {
        externIdentityButton_twitter.hidden = NO;
    } else {
        externIdentityButton_twitter.hidden = YES;
    }
    
    tipCountLabel.text = [NSString stringWithFormat:@"%d", tipCount];
    topicCountLabel.text = [NSString stringWithFormat:@"%d", topicCount];
    geniusCountLabel.text = [NSString stringWithFormat:@"%d", geniusCount];
    peopleHelpedLabel.text = [NSString stringWithFormat:@"%d", peopleHelped];
    
    NSString *profilePicPath = [NSString stringWithFormat:@"http://%@/userphotos/%d/profile/m_%@.jpg", SH_DOMAIN, profileOwnerUserid, profileOwnerHash];
    userThmbnl.imageURL = [NSURL URLWithString:profilePicPath];
    
    // Unfortunately, yes. We have to redraw everything, every single time. :/
    if ([[NSNull null] isEqual:profileOwnerLocation] || profileOwnerLocation.length == 0) {
        profileOwnerLocationLabel.hidden = YES;
        locationMarkerIconView.hidden = YES;
        locationSeparator.hidden = YES;
    } else {
        profileOwnerLocationLabel.hidden = NO;
        locationMarkerIconView.hidden = NO;
        locationSeparator.hidden = NO;
        profileOwnerLocationLabel.text = profileOwnerLocation;
    }
    
    if ([[NSNull null] isEqual:profileOwnerURL] || profileOwnerURL.length == 0) {
        profileOwnerURLButton.hidden = YES;
    } else {
        profileOwnerURLButton.hidden = NO;
        profileOwnerURLLabel.text = profileOwnerURL;
    }
    
    if ([[NSNull null] isEqual:profileOwnerBio] || profileOwnerBio.length == 0) {
        if (isCurrentUser == YES) {
            profileOwnerBioLabel.font = [UIFont fontWithName:@"Georgia-Italic" size:MIN_MAIN_FONT_SIZE];
            profileOwnerBioLabelShadow.font = [UIFont fontWithName:@"Georgia-Italic" size:MIN_MAIN_FONT_SIZE];
            profileOwnerBioLabel.text = @"Write something about yourself here. Just tap the \"Gears\" button in the upper right corner of the toolbar up there!";
            profileOwnerBioLabelShadow.text = profileOwnerBioLabel.text;
            profileOwnerBioLabel.hidden = NO;
            profileOwnerBioLabelShadow.hidden = NO;
        } else {
            profileOwnerBioLabel.hidden = YES;
            profileOwnerBioLabelShadow.hidden = YES;
        }
        
    } else {
        profileOwnerBioLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
        profileOwnerBioLabelShadow.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
        profileOwnerBioLabel.text = profileOwnerBio;
        profileOwnerBioLabelShadow.dataDetectorTypes = UIDataDetectorTypeAll;
        profileOwnerBioLabelShadow.text = profileOwnerBioLabel.text;
        
        profileOwnerBioLabel.hidden = NO;
        profileOwnerBioLabelShadow.hidden = NO;
        
        NSRegularExpression *mentionRegex = [NSRegularExpression regularExpressionWithPattern:@"(@[a-zA-Z0-9_]+)" options:0 error:NULL];
        NSArray *allMentions = [mentionRegex matchesInString:profileOwnerBio options:0 range:NSMakeRange(0, profileOwnerBio.length)];
        
        for (NSTextCheckingResult *mentionMatch in allMentions) {
            int captureIndex;
            for (captureIndex = 1; captureIndex < mentionMatch.numberOfRanges; captureIndex++) {
                [profileOwnerBioLabelShadow addLinkToURL:[NSURL URLWithString:[profileOwnerBio substringWithRange:[mentionMatch rangeAtIndex:captureIndex]]] withRange:[mentionMatch rangeAtIndex:1]]; // Embedding a custom link in a substring
            }
        }
    }
    
    if (([[NSNull null] isEqual:profileOwnerLocation] || profileOwnerLocation.length == 0) && ([[NSNull null] isEqual:profileOwnerURL] || profileOwnerURL.length == 0) && ([[NSNull null] isEqual:profileOwnerBio] || profileOwnerBio.length == 0) && isCurrentUser == NO) {
        detailsSeparator.hidden = YES;
    } else {
        detailsSeparator.hidden = NO;
    }
    
    profileOwnerNameLabel.text = profileOwnerName;
    profileOwnerUsernameLabel.text = [NSString stringWithFormat:@"@%@", profileOwnerUsername];
    tipCountTextLabel.text = [NSString stringWithFormat:@"TIP%@", tipCount == 1 ? @"" : @"S"];
    topicCountTextLabel.text = [NSString stringWithFormat:@"TOPIC%@", topicCount == 1 ? @"" : @"S"];
    peopleHelpedTextLabel.text = [NSString stringWithFormat:@"%@ helped", peopleHelped == 1 ? @"person" : @"people"];
    foundUsefulButtonTitle.text = [[NSString stringWithFormat:@"TIPS %@ FOUND USEFUL", profileOwnerName] uppercaseString];
    foundUsefulLabel.text = [NSString stringWithFormat:@"%d tip%@ found useful", foundUsefulCount, foundUsefulCount == 1 ? @"" : @"s"];
    
    // Disable the count buttons if they're 0. Pointless to show a new empty view.
    if (geniusCount == 0) {
        geniusCountButton.enabled = NO;
    } else {
        geniusCountButton.enabled = YES;
    }
    
    if (topicCount == 0) {
        topicCountButton.enabled = NO;
    } else {
        topicCountButton.enabled = YES;
    }
    
    if (foundUsefulCount == 0) {
        foundUsefulButton.enabled = NO;
        foundUsefulStripChevron.hidden = YES;
    } else {
        foundUsefulButton.enabled = YES;
        foundUsefulStripChevron.hidden = NO;
    }
    
    [self layoutProfileCard];
}

- (void)layoutProfileCard
{
    if ([[NSNull null] isEqual:profileOwnerLocation]) {
        profileOwnerLocation = @"";
    }
    
    if ([[NSNull null] isEqual:profileOwnerBio]) {
        profileOwnerBio = @"";
    }
    
    if ([[NSNull null] isEqual:profileOwnerURL]) {
        profileOwnerURL = @"";
    }
    
    CGSize nameSize = [profileOwnerName sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(230, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    // NOTE: we use the LABEL text, not the string text, for the username size. The string doesn't take into account the "@" preceding the username.
    CGSize usernameSize = [profileOwnerUsernameLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(230, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    CGSize locationSize = [profileOwnerLocation sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE] constrainedToSize:CGSizeMake(250, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    CGSize bioSize = [profileOwnerBioLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(280, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    CGSize urlSize = [profileOwnerURL sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(289, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    CGSize peopleHelpedSize = [peopleHelpedLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(248, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    if ([[NSNull null] isEqual:profileOwnerBio] || profileOwnerBio.length == 0) {
        if (isCurrentUser == YES) {
            bioSize = [profileOwnerBioLabel.text sizeWithFont:[UIFont fontWithName:@"Georgia-Italic" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(280, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        }
    }
    
    profileOwnerNameLabel.frame = CGRectMake(47, 6, nameSize.width, 18);
    profileOwnerUsernameLabel.frame = CGRectMake(47, 26, usernameSize.width, 17);
    profileOwnerLocationLabel.frame = CGRectMake(21, 55, 250, 16);
    locationSeparator.frame = CGRectMake(6, locationSize.height + 57, 288, 2);
    profileOwnerBioLabel.frame = CGRectMake(15, locationSize.height + 79, 280, bioSize.height);
    profileOwnerBioLabelShadow.frame = CGRectMake(15, locationSize.height + 79, 280, bioSize.height);
    profileOwnerURLButton.frame = CGRectMake(13,  locationSize.height + bioSize.height + 77, urlSize.width + 4, 20);
    profileOwnerURLLabel.frame = CGRectMake(2, 0, urlSize.width, 20);
    statsTopSeparator.frame = CGRectMake(0,  locationSize.height + bioSize.height + urlSize.height + 69, 301, 1);
    statsSideSeparator_1.frame = CGRectMake(100, locationSize.height + bioSize.height + urlSize.height + 70, 1, 50);
    statsSideSeparator_2.frame = CGRectMake(200, locationSize.height + bioSize.height + urlSize.height + 70, 1, 50);
    tipCountButton.frame = CGRectMake(9, locationSize.height + bioSize.height + urlSize.height + 84, 100, 50);
    topicCountButton.frame = CGRectMake(111, locationSize.height + bioSize.height + urlSize.height + 84, 99, 50);
    geniusCountButton.frame = CGRectMake(211, locationSize.height + bioSize.height + urlSize.height + 84, 99, 50);
    peopleHelpedStrip.frame = CGRectMake(0, locationSize.height + bioSize.height + urlSize.height + 120, 300, 36);
    peopleHelpedTextLabel.frame = CGRectMake(peopleHelpedSize.width + 11, 9, 280, 20);
    externIdentityButton_fb.frame = CGRectMake(238, 3, 34, 34);
    externIdentityButton_twitter.frame = CGRectMake(266, 3, 34, 34);
    profileOwnerCard.frame = CGRectMake(6, 10, 308, locationSize.height + bioSize.height + urlSize.height + 164);
    profileOwnerCardBg.frame = CGRectMake(4, 4, 300, locationSize.height + bioSize.height + urlSize.height + 155);
    foundUsefulButtonIconView.frame = CGRectMake(9, locationSize.height + bioSize.height + urlSize.height + 184, 14, 14);
    foundUsefulButtonTitle.frame = CGRectMake(28, locationSize.height + bioSize.height + urlSize.height + 180, 287, 20);
    foundUsefulButtonBg.frame = CGRectMake(6, locationSize.height + bioSize.height + urlSize.height + 204, 308, 42);
    feedTitle.frame = CGRectMake(28, locationSize.height + bioSize.height + urlSize.height + 249, 287, 20);
    
    if ([[NSNull null] isEqual:profileOwnerLocation] || profileOwnerLocation.length == 0) { // Slightly adjust the bio's position.
        profileOwnerBioLabel.frame = CGRectMake(15, locationSize.height + 74, 280, bioSize.height);
        profileOwnerBioLabelShadow.frame = CGRectMake(15, locationSize.height + 74, 280, bioSize.height);
    }
    
    if ([[NSNull null] isEqual:profileOwnerBio] || profileOwnerBio.length == 0) {
        if (isCurrentUser == YES) {
            profileOwnerURLButton.frame = CGRectMake(13,  locationSize.height + bioSize.height + 79, urlSize.width + 4, urlSize.height);
        }
    }
    
    if (fbID.length > 0 && twitterID.length == 0) {
        externIdentityButton_fb.frame = CGRectMake(266, 3, 34, 34);
    }
    
    CGRect tableHeaderFrame = timelineFeed.tableHeaderView.frame;
	tableHeaderFrame.size.height = locationSize.height + bioSize.height + urlSize.height + 260;
	timelineFeed.tableHeaderView.frame = tableHeaderFrame;
	timelineFeed.tableHeaderView = tableHeader;
}

- (void)showSettingsPanel
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Customizations depending on whether the viewed profile is that of the current user.
    if (isCurrentUser == NO) {
        UIActionSheet *userOptions = [[UIActionSheet alloc] 
                                      initWithTitle:@"Options" 
                                      delegate:self
                                      cancelButtonTitle:@"Cancel" 
                                      destructiveButtonTitle:@"Report User" 
                                      otherButtonTitles:nil];
        
        userOptions.tag = 99;
        userOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [userOptions showFromTabBar:appDelegate.mainTabBarController.tabBar];
        [userOptions release];
    } else {
        settings = [[SettingsPanelViewController alloc] initWithNibName:@"SettingsPanel" bundle:nil];
        settings.delegate = self;
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:settings] autorelease];
        [self presentModalViewController:navigationController animated:true];
        
        appDelegate.mainTabBarController.tabBar.hidden = YES;
    }
}

- (void)panelDidGetDismissed
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mainTabBarController.tabBar.hidden = NO;
    [self redrawContents];
}

- (void)showTopicsFollowed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    TopicsListViewController *followedTopicsList = [[TopicsListViewController alloc] 
                                                    initWithNibName:@"TopicsListView" 
                                                    bundle:[NSBundle mainBundle]];
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"@%@", profileOwnerUsername] style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    
    if (button.tag == 1) {
        [followedTopicsList setTitle:@"Topics"];
        followedTopicsList.topicCount = topicCount;
        followedTopicsList.listType = @"topics";
    } else {
        [followedTopicsList setTitle:@"Genius"];
        followedTopicsList.topicCount = geniusCount;
        followedTopicsList.listType = @"genius";
    }
    
    followedTopicsList.listOwner = profileOwnerName;
    followedTopicsList.listOwnerUserid = [NSString stringWithFormat:@"%d", profileOwnerUserid];
	[self.navigationController pushViewController:followedTopicsList animated:YES];
	[followedTopicsList release];
	followedTopicsList = nil;
}

- (void)gotoProfilePicOptions:(id)sender
{
    [self showSettingsPanel];
    [settings showUserPicOptions];
}

- (void)reportUser
{
    ReportViewController *reportView = [[ReportViewController alloc] initWithNibName:@"ReportView" bundle:nil];
    reportView.reportType = @"user";
    reportView.objectid = profileOwnerUserid;
    [self presentModalViewController:reportView animated:true];
    [reportView release];
}

- (void)viewDidLoad
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showNavbarShadowAnimated:YES];
    
    selectedIndexes = [[NSMutableDictionary alloc] init];
    feedEntries = [[NSMutableArray alloc] init];
    global = appDelegate.global;
    fbID = @"";
    twitterID = @"";
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if (viewControllers.count == 1) { // If this is a root MeView, then it's the current user's profile.
        isCurrentUser = YES;
        profileOwnerUsername = [global readProperty:@"username"];
    }
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:192.0/255.0 green:133.0/255.0 blue:87.0/255.0 alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    
    // Add the Settings button to the navbar.
    UIImage *settingsButtonImage = [UIImage imageNamed:@"settings.png"];
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setImage:settingsButtonImage forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(showSettingsPanel) forControlEvents:UIControlEventTouchUpInside];
    settingsButton.showsTouchWhenHighlighted = YES;
    settingsButton.frame = CGRectMake(0, 0, 44, 44);
    
    settingsButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        // Don't do anything.
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = settingsButtonItem;
    }
    
    if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] 
                                           initWithFrame:CGRectMake(0, 0 - timelineFeed.bounds.size.height, self.view.frame.size.width, timelineFeed.bounds.size.height)];
		refreshHeaderView.delegate = self;
		[timelineFeed addSubview:refreshHeaderView];
	}
    
    if (!freshTip) {
        // Wrap this call in a safety net! Tip creation calls it again. If both get
        // called simultaneously, it locks the profile!
        [refreshHeaderView egoRefreshScrollViewDataSourceStartManualLoading:timelineFeed];
    }
    
    [self setTitle:[NSString stringWithFormat:@"@%@", profileOwnerUsername]];
    
    UIImage *userThmbnlOverlay = [[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:3.0];
    UIImageView *userThmbnlOverlayView = [[UIImageView alloc] initWithImage:userThmbnlOverlay];
    userThmbnlOverlayView.frame = CGRectMake(0, 0, 36, 36);
    
	userThmbnl = [[EGOImageView alloc] initWithFrame:CGRectMake(3, 2, 30, 30)];
    userThmbnl.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
    userThmbnl.opaque = YES;
    
    UIButton *userThmbnlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [userThmbnlButton addTarget:self action:@selector(gotoProfilePicOptions:) forControlEvents:UIControlEventTouchUpInside];
    userThmbnlButton.frame = CGRectMake(5, 6, 36, 36);
    
    profileOwnerNameLabel = [[UILabel alloc] init];
    profileOwnerNameLabel.backgroundColor = [UIColor clearColor];
    profileOwnerNameLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    profileOwnerNameLabel.numberOfLines = 1;
    profileOwnerNameLabel.minimumFontSize = 8.;
    profileOwnerNameLabel.adjustsFontSizeToFitWidth = YES;
    profileOwnerNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
    profileOwnerNameLabel.opaque = YES;
    
    profileOwnerUsernameLabel = [[LPLabel alloc] init];
    profileOwnerUsernameLabel.backgroundColor = [UIColor clearColor];
    profileOwnerUsernameLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    profileOwnerUsernameLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    profileOwnerUsernameLabel.numberOfLines = 1;
    profileOwnerUsernameLabel.minimumFontSize = 8.;
    profileOwnerUsernameLabel.adjustsFontSizeToFitWidth = YES;
    profileOwnerUsernameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    profileOwnerUsernameLabel.opaque = YES;
    
    currentUserIndicator = [[LPLabel alloc] initWithFrame:CGRectMake(195, 19, 100, 20)];
    currentUserIndicator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    currentUserIndicator.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    currentUserIndicator.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    currentUserIndicator.numberOfLines = 1;
    currentUserIndicator.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_SECONDARY_FONT_SIZE];
    currentUserIndicator.textAlignment = UITextAlignmentRight;
    currentUserIndicator.text = @"← That's you!";
    currentUserIndicator.opaque = YES;
    currentUserIndicator.hidden = YES;
    
    detailsSeparator = [CALayer layer];
    detailsSeparator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"solid_line_red.png"]].CGColor;
    detailsSeparator.frame = CGRectMake(6, 49, 288, 2);
    detailsSeparator.opaque = YES;
    [detailsSeparator setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
    
    locationMarkerIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small_grey_location_marker.png"]];
    locationMarkerIconView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    locationMarkerIconView.frame = CGRectMake(5, 55, 14, 14);
    locationMarkerIconView.opaque = YES;
    
    locationSeparator = [CALayer layer];
    locationSeparator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_red.png"]].CGColor;
    locationSeparator.opaque = YES;
    [locationSeparator setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
    
    profileOwnerLocationLabel = [[LPLabel alloc] init];
    profileOwnerLocationLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    profileOwnerLocationLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    profileOwnerLocationLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    profileOwnerLocationLabel.numberOfLines = 1;
    profileOwnerLocationLabel.minimumFontSize = 8.;
    profileOwnerLocationLabel.adjustsFontSizeToFitWidth = YES;
    profileOwnerLocationLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    profileOwnerLocationLabel.opaque = YES;
    
    profileOwnerBioLabel = [[TTTAttributedLabel alloc] init];
    profileOwnerBioLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    profileOwnerBioLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    profileOwnerBioLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    profileOwnerBioLabel.shadowOffset = CGSizeMake(0, 1);
    profileOwnerBioLabel.numberOfLines = 0;
    profileOwnerBioLabel.lineBreakMode = UILineBreakModeWordWrap;
    profileOwnerBioLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    profileOwnerBioLabel.opaque = YES;
    
    profileOwnerBioLabelShadow = [[TTTAttributedLabel alloc] init];
    profileOwnerBioLabelShadow.backgroundColor = [UIColor clearColor];
    profileOwnerBioLabelShadow.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    profileOwnerBioLabelShadow.shadowColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:0.8];
    profileOwnerBioLabelShadow.shadowOffset = CGSizeMake(0, -1);
    profileOwnerBioLabelShadow.numberOfLines = 0;
    profileOwnerBioLabelShadow.lineBreakMode = UILineBreakModeWordWrap;
    profileOwnerBioLabelShadow.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    profileOwnerBioLabelShadow.userInteractionEnabled = YES;
    profileOwnerBioLabelShadow.delegate = self;
    
    profileOwnerURLLabel = [[LPLabel alloc] init];
    profileOwnerURLLabel.backgroundColor = [UIColor clearColor];
    profileOwnerURLLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:115.0/255.0 blue:185.0/255.0 alpha:1.0];
    profileOwnerURLLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    profileOwnerURLLabel.numberOfLines = 1;
    profileOwnerURLLabel.minimumFontSize = 8.;
    profileOwnerURLLabel.adjustsFontSizeToFitWidth = YES;
    profileOwnerURLLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    
    profileOwnerURLButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    profileOwnerURLButton.layer.masksToBounds = YES;
    profileOwnerURLButton.layer.cornerRadius = 4;
    profileOwnerURLButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    [profileOwnerURLButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [profileOwnerURLButton addTarget:self action:@selector(gotoUserURL:) forControlEvents:UIControlEventTouchUpInside];
    
    statsTopSeparator = [CALayer layer];
    statsTopSeparator.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0].CGColor;
    statsTopSeparator.opaque = YES;
    
    statsSideSeparator_1 = [CALayer layer];
    statsSideSeparator_1.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0].CGColor;
    statsSideSeparator_1.opaque = YES;
    
    statsSideSeparator_2 = [CALayer layer];
    statsSideSeparator_2.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0].CGColor;
    statsSideSeparator_2.opaque = YES;
    
    tipCountLabel = [[LPLabel alloc] init];
    tipCountLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    tipCountLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    tipCountLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    tipCountLabel.shadowOffset = CGSizeMake(0, 1);
    tipCountLabel.numberOfLines = 1;
    tipCountLabel.minimumFontSize = 8.;
    tipCountLabel.adjustsFontSizeToFitWidth = YES;
    tipCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
    tipCountLabel.opaque = YES;
    
    tipCountTextLabel = [[UILabel alloc] init];
    tipCountTextLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    tipCountTextLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    tipCountTextLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    tipCountTextLabel.shadowOffset = CGSizeMake(0, 1);
    tipCountTextLabel.numberOfLines = 1;
    tipCountTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    tipCountTextLabel.opaque = YES;
    
    tipCountButton = [[UIView alloc] init];
    tipCountButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    tipCountButton.opaque = YES;
    
    topicCountLabel = [[LPLabel alloc] init];
    topicCountLabel.backgroundColor = [UIColor clearColor];
    topicCountLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    topicCountLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    topicCountLabel.shadowOffset = CGSizeMake(0, 1);
    topicCountLabel.numberOfLines = 1;
    topicCountLabel.minimumFontSize = 8.;
    topicCountLabel.adjustsFontSizeToFitWidth = YES;
    topicCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
    
    topicCountTextLabel = [[UILabel alloc] init];
    topicCountTextLabel.backgroundColor = [UIColor clearColor];
    topicCountTextLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    topicCountTextLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    topicCountTextLabel.shadowOffset = CGSizeMake(0, 1);
    topicCountTextLabel.numberOfLines = 1;
    topicCountTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    
    topicCountButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    topicCountButton.tag = 1;
    topicCountButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    [topicCountButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [topicCountButton addTarget:self action:@selector(showTopicsFollowed:) forControlEvents:UIControlEventTouchUpInside];
    
    geniusCountLabel = [[LPLabel alloc] init];
    geniusCountLabel.backgroundColor = [UIColor clearColor];
    geniusCountLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    geniusCountLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    geniusCountLabel.shadowOffset = CGSizeMake(0, 1);
    geniusCountLabel.numberOfLines = 1;
    geniusCountLabel.minimumFontSize = 8.;
    geniusCountLabel.adjustsFontSizeToFitWidth = YES;
    geniusCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
    
    geniusCountTextLabel = [[UILabel alloc] init];
    geniusCountTextLabel.backgroundColor = [UIColor clearColor];
    geniusCountTextLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    geniusCountTextLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    geniusCountTextLabel.shadowOffset = CGSizeMake(0, 1);
    geniusCountTextLabel.numberOfLines = 1;
    geniusCountTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    
    geniusCountButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    geniusCountButton.tag = 2;
    geniusCountButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    [geniusCountButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [geniusCountButton addTarget:self action:@selector(showTopicsFollowed:) forControlEvents:UIControlEventTouchUpInside];
    
    peopleHelpedLabel = [[UILabel alloc] init];
    peopleHelpedLabel.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0];
    peopleHelpedLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    peopleHelpedLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    peopleHelpedLabel.shadowOffset = CGSizeMake(0, 1);
    peopleHelpedLabel.numberOfLines = 1;
    peopleHelpedLabel.lineBreakMode = UILineBreakModeWordWrap;
    peopleHelpedLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
    peopleHelpedLabel.opaque = YES;
    
    peopleHelpedTextLabel = [[UILabel alloc] init];
    peopleHelpedTextLabel.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0];
    peopleHelpedTextLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    peopleHelpedTextLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    peopleHelpedTextLabel.shadowOffset = CGSizeMake(0, 1);
    peopleHelpedTextLabel.numberOfLines = 1;
    peopleHelpedTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    peopleHelpedTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    peopleHelpedTextLabel.opaque = YES;
    
    peopleHelpedStrip = [[UIView alloc] init];
    peopleHelpedStrip.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0];
    peopleHelpedStrip.layer.masksToBounds = YES;
    peopleHelpedStrip.layer.borderWidth = 0.7;
    peopleHelpedStrip.layer.borderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
    peopleHelpedStrip.opaque = YES;
    
    externIdentityButton_fb = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [externIdentityButton_fb setBackgroundImage:[UIImage imageNamed:@"share_facebook_off.png"] forState:UIControlStateNormal];
    [externIdentityButton_fb setBackgroundImage:[UIImage imageNamed:@"share_facebook_on.png"] forState:UIControlStateHighlighted];
    [externIdentityButton_fb addTarget:self action:@selector(gotoUserIdentity:) forControlEvents:UIControlEventTouchUpInside];
    externIdentityButton_fb.showsTouchWhenHighlighted = YES;
    externIdentityButton_fb.tag = 911;
    
    externIdentityButton_twitter = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [externIdentityButton_twitter setBackgroundImage:[UIImage imageNamed:@"share_twitter_off.png"] forState:UIControlStateNormal];
    [externIdentityButton_twitter setBackgroundImage:[UIImage imageNamed:@"share_twitter_on.png"] forState:UIControlStateHighlighted];
    [externIdentityButton_twitter addTarget:self action:@selector(gotoUserIdentity:) forControlEvents:UIControlEventTouchUpInside];
    externIdentityButton_twitter.showsTouchWhenHighlighted = YES;
    externIdentityButton_twitter.tag = 912;
    
    profileOwnerCard = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
    profileOwnerCard.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    profileOwnerCard.opaque = YES;
    profileOwnerCard.userInteractionEnabled = YES;
    
    profileOwnerCardBg = [[UIView alloc] init];
    profileOwnerCardBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    profileOwnerCardBg.opaque = YES;
    
    foundUsefulButtonIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small_grey_bulb.png"]];
    foundUsefulButtonIconView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    foundUsefulButtonIconView.opaque = YES;
    
    foundUsefulButtonTitle = [[UILabel alloc] init];
    foundUsefulButtonTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
	foundUsefulButtonTitle.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
    foundUsefulButtonTitle.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    foundUsefulButtonTitle.shadowOffset = CGSizeMake(0, 1);
	foundUsefulButtonTitle.numberOfLines = 1;
	foundUsefulButtonTitle.font = [UIFont boldSystemFontOfSize:MIN_SECONDARY_FONT_SIZE];
    foundUsefulButtonTitle.opaque = YES;
    
    foundUsefulButtonBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
    foundUsefulButtonBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    foundUsefulButtonBg.opaque = YES;
    foundUsefulButtonBg.userInteractionEnabled = YES;
    
    foundUsefulButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    foundUsefulButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    [foundUsefulButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [foundUsefulButton addTarget:self action:@selector(gotoUsefulList) forControlEvents:UIControlEventTouchUpInside];
    
    foundUsefulStripChevron = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feed_chevron_grey.png"]];
    
    foundUsefulLabel = [[UILabel alloc] init];
    foundUsefulLabel.backgroundColor = [UIColor clearColor];
    foundUsefulLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    foundUsefulLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    foundUsefulLabel.shadowOffset = CGSizeMake(0, 1);
    foundUsefulLabel.numberOfLines = 1;
    foundUsefulLabel.minimumFontSize = 8.;
    foundUsefulLabel.adjustsFontSizeToFitWidth = YES;
    foundUsefulLabel.font = [UIFont fontWithName:@"Georgia" size:MIN_MAIN_FONT_SIZE];
    
    feedTitle = [[UILabel alloc] init];
    feedTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
	feedTitle.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
    feedTitle.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    feedTitle.shadowOffset = CGSizeMake(0, 1);
	feedTitle.numberOfLines = 1;
	feedTitle.font = [UIFont boldSystemFontOfSize:MIN_SECONDARY_FONT_SIZE];
    feedTitle.text = @"TIPS";
    feedTitle.opaque = YES;
    
    tableHeader = [[UIView alloc] init];
    
    phantomCard = [[TipCard alloc] init];
    phantomCard.hidden = YES;
    
    [self redrawContents];
    tipCountLabel.text = @"0";
    topicCountLabel.text = @"0";
    geniusCountLabel.text = @"0";
    peopleHelpedLabel.text = @"0";
    
    tipCountTextLabel.text = @"TIPS";
    topicCountTextLabel.text = @"TOPICS";
    geniusCountTextLabel.text = @"GENIUS";
    peopleHelpedTextLabel.text = @"people helped";
    foundUsefulButtonTitle.text = [[NSString stringWithFormat:@"TIPS @%@ FOUND USEFUL", profileOwnerUsername] uppercaseString];
    foundUsefulLabel.text = @"0 tips found useful";
    
    [profileOwnerCardBg addSubview:currentUserIndicator];
    [profileOwnerCard addSubview:profileOwnerCardBg];
    [profileOwnerCardBg addSubview:userThmbnlButton];
    [profileOwnerCardBg addSubview:profileOwnerNameLabel];
    [profileOwnerCardBg addSubview:profileOwnerUsernameLabel];
    [profileOwnerCardBg.layer addSublayer:detailsSeparator];
    [profileOwnerCardBg addSubview:locationMarkerIconView];
    [profileOwnerCardBg addSubview:profileOwnerLocationLabel];
    [profileOwnerCardBg.layer addSublayer:locationSeparator];
    [profileOwnerCardBg.layer addSublayer:statsTopSeparator];
    [profileOwnerCardBg.layer addSublayer:statsSideSeparator_1];
    [profileOwnerCardBg.layer addSublayer:statsSideSeparator_2];
    [profileOwnerCardBg addSubview:peopleHelpedStrip];
    [userThmbnlButton addSubview:userThmbnlOverlayView];
    [userThmbnlButton addSubview:userThmbnl];
    [profileOwnerURLButton addSubview:profileOwnerURLLabel];
    [tipCountButton addSubview:tipCountLabel];
    [tipCountButton addSubview:tipCountTextLabel];
    [topicCountButton addSubview:topicCountLabel];
    [topicCountButton addSubview:topicCountTextLabel];
    [geniusCountButton addSubview:geniusCountLabel];
    [geniusCountButton addSubview:geniusCountTextLabel];
    [peopleHelpedStrip addSubview:peopleHelpedLabel];
    [peopleHelpedStrip addSubview:peopleHelpedTextLabel];
    [peopleHelpedStrip addSubview:externIdentityButton_fb];
    [peopleHelpedStrip addSubview:externIdentityButton_twitter];
    [profileOwnerCard addSubview:profileOwnerCardBg];
    [foundUsefulButtonBg addSubview:foundUsefulButton];
    [foundUsefulButton addSubview:foundUsefulStripChevron];
    [foundUsefulButton addSubview:foundUsefulLabel];
    [tableHeader addSubview:profileOwnerCard];
    [tableHeader addSubview:profileOwnerBioLabel];
    [tableHeader addSubview:profileOwnerBioLabelShadow];
    [tableHeader addSubview:profileOwnerURLButton];
    [tableHeader addSubview:tipCountButton];
    [tableHeader addSubview:topicCountButton];
    [tableHeader addSubview:geniusCountButton];
    [tableHeader addSubview:foundUsefulButtonIconView];
    [tableHeader addSubview:foundUsefulButtonTitle];
    [tableHeader addSubview:foundUsefulButtonBg];
    [tableHeader addSubview:feedTitle];
    timelineFeed.tableHeaderView = tableHeader;
    
    [tableHeader addSubview:phantomCard];
    [self layoutProfileCard];
    
    tipCountLabel.frame = CGRectMake(15, 10, 70, 20);
    tipCountTextLabel.frame = CGRectMake(15, 25, 70, 20);
    topicCountLabel.frame = CGRectMake(15, 10, 70, 20);
    topicCountTextLabel.frame = CGRectMake(15, 25, 70, 20);
    geniusCountLabel.frame = CGRectMake(15, 10, 70, 20);
    geniusCountTextLabel.frame = CGRectMake(15, 25, 70, 20);
    peopleHelpedLabel.frame = CGRectMake(7, 9, 280, 20);
    foundUsefulButton.frame = CGRectMake(4, 4, 300, 34);
    foundUsefulStripChevron.frame = CGRectMake(282, 9, 10, 17);
    foundUsefulLabel.frame = CGRectMake(7, 2, 234, 28);
    
    [userThmbnlOverlayView release];
    [super viewDidLoad];
    /************************************************************************************************************************************************
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];         // Code archived for future purposes.
    [self.navigationController.navigationBar.topItem setTitleView:[appDelegate.tabBarController setupNavBar]];  // Possibly for notifications badge.
    *************************************************************************************************************************************************/
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
    }
}

#pragma mark Timeline delegate methods
- (void)timelineDidFinishDownloading
{
    timelineDidDownload = YES;
	
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self performSelector:@selector(doneLoadingTableViewData)];
    [timelineFeed reloadData];
    
    if (freshTip) {
        TipCell *targetCell = (TipCell *)[timelineFeed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        targetCell.tipCardView.card.hidden = YES;
        
        [appDelegate.strobeLight affirmativeStrobeLight];
        [timelineFeed scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        tipCountLabel.text = [NSString stringWithFormat:@"%d", tipCount];
        tipCountTextLabel.text = [NSString stringWithFormat:@"TIP%@", tipCount == 1 ? @"" : @"S"];
        
        [phantomCard populateCellWithContent:[self.feedEntries objectAtIndex:0]];
        phantomCard.frame = CGRectMake(-340, tableHeader.frame.size.height, phantomCard.frame.size.width, phantomCard.frame.size.height);
        phantomCard.hidden = NO;
        
        // Momentum bump effect.
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            phantomCard.frame = CGRectMake(15, tableHeader.frame.size.height, phantomCard.frame.size.width, phantomCard.frame.size.height);
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                phantomCard.frame = CGRectMake(-12, tableHeader.frame.size.height, phantomCard.frame.size.width, phantomCard.frame.size.height);
            } completion:^(BOOL finished){
                [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    phantomCard.frame = CGRectMake(7, tableHeader.frame.size.height, phantomCard.frame.size.width, phantomCard.frame.size.height);
                } completion:^(BOOL finished){
                    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                        phantomCard.frame = CGRectMake(2, tableHeader.frame.size.height, phantomCard.frame.size.width, phantomCard.frame.size.height);
                    } completion:^(BOOL finished){
                        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                            phantomCard.frame = CGRectMake(0, tableHeader.frame.size.height, phantomCard.frame.size.width, phantomCard.frame.size.height);
                        } completion:^(BOOL finished){
                            phantomCard.hidden = YES;
                            targetCell.tipCardView.card.hidden = NO;
                            freshTip = NO;
                        }];
                    }];
                }];
            }];
        }];
    } else {
        [appDelegate.strobeLight deactivateStrobeLight]; // We don't want it turning off the green strobe light!
    }
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
    
    if (indexPath.row == [feedEntries count]) {
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
    
    [self downloadTimeline:@"gettipsbyuser" batch:++batchNo];
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
    [self getUserInfoForUsername:profileOwnerUsername];
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

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    // If the URL is an @mention, we push a profile view controller, otherwise we push a normal WebView controller.
    NSRegularExpression *mentionRegex = [NSRegularExpression regularExpressionWithPattern:@"(@[a-zA-Z0-9_]+)" options:0 error:NULL];
    NSArray *mentionCheckingResults = [mentionRegex matchesInString:[url absoluteString] options:0 range:NSMakeRange(0, [[url absoluteString] length])];
    
    for (NSTextCheckingResult *ntcr in mentionCheckingResults) {
        NSString *match = [[url absoluteString] substringWithRange:[ntcr rangeAtIndex:1]];
        NSString *processedUsername = [match substringWithRange:NSMakeRange(1, [match length] - 1)];
        
        MeViewController *profileView = [[MeViewController alloc] 
                                         initWithNibName:@"MeView" 
                                         bundle:[NSBundle mainBundle]];
        
        profileView.isCurrentUser = NO;
        profileView.profileOwnerUsername = processedUsername;
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"@%@", profileOwnerUsername] style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:profileView animated:YES];
        [profileView release];
        profileView = nil;
        
        return;
    }
    
    NSString *urlStr = url.absoluteString;
    
    NSRange rangeOfSubstring = [urlStr rangeOfString:@"/Tipbox.app/www"];
    
    if (rangeOfSubstring.location != NSNotFound) {
        urlStr = [urlStr substringFromIndex:rangeOfSubstring.location + 12];
    }
    
    if (![urlStr hasPrefix:@"http://"] && ![urlStr hasPrefix:@"https://"] && ![urlStr hasPrefix:@"ftp://"] && ![urlStr hasPrefix:@"ftps://"]) {
        urlStr = [NSString stringWithFormat:@"http://%@", urlStr];
    }
    
    WebViewController *webView = [[WebViewController alloc] 
                                  initWithNibName:@"WebView" 
                                  bundle:[NSBundle mainBundle]];
    webView.url = urlStr;
    [webView setTitle:urlStr];
    webView.hidesBottomBarWhenPushed = YES;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"@%@", profileOwnerUsername] style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:webView animated:YES];
	[webView release];
	webView = nil;
}

- (void)gotoUserURL:(id)sender
{
    NSString *urlStr = profileOwnerURL;
    
    if (![urlStr hasPrefix:@"http://"] && ![urlStr hasPrefix:@"https://"] && ![urlStr hasPrefix:@"ftp://"] && ![urlStr hasPrefix:@"ftps://"]) {
        urlStr = [NSString stringWithFormat:@"http://%@", urlStr];
    }
    
    WebViewController *webView = [[WebViewController alloc] 
                                  initWithNibName:@"WebView" 
                                  bundle:[NSBundle mainBundle]];
    webView.url = urlStr;
    [webView setTitle:urlStr];
    webView.hidesBottomBarWhenPushed = YES;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"@%@", profileOwnerUsername] style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:webView animated:YES];
	[webView release];
	webView = nil;
}

- (void)gotoUserIdentity:(id)sender
{
    UIButton *identityButton = (UIButton *)sender;
    NSURL *url, *appURL = [NSURL URLWithString:@""];
    WebViewController *webView = [[WebViewController alloc] 
                                  initWithNibName:@"WebView" 
                                  bundle:[NSBundle mainBundle]];
    
    // Launch the profile in its native app if possible.
    if (identityButton.tag == 911) {        // Facebook
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/%@", fbID]];
        [webView setTitle:@"Facebook"];
        
        appURL = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", fbID]];
    } else if (identityButton.tag == 912) { //Twitter
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", twitterID]];
        [webView setTitle:@"Twitter"];
        
        appURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", twitterID]];
    }
    
    if (![[UIApplication sharedApplication] openURL:appURL]) {
        // Native app failed to open. Use the website instead.
        webView.url = [url absoluteString];
        webView.hidesBottomBarWhenPushed = YES;
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"@%@", profileOwnerUsername] style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:webView animated:YES];
        [webView release];
        webView = nil;
        return;
    }
    
    [webView release];
    webView = nil;
}

- (void)gotoUsefulList
{
	UsefulTipsViewController *usefulList = [[UsefulTipsViewController alloc] 
                                  initWithNibName:@"UsefulTipsView" 
                                  bundle:[NSBundle mainBundle]];
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"@%@", profileOwnerUsername] style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    usefulList.feed_targetid = profileOwnerUserid;
    
	[self.navigationController pushViewController:usefulList animated:YES];
	[usefulList release];
	usefulList = nil;
}

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
	
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"@%@", profileOwnerUsername] style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
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
                topicCount--;
                
                HUDImageName = @"cross_white.png";
                HUD.labelText = @"Unfollowed";
            } else {
                targetCell.tipCardView.followsTopic = 1;
                topicCount++;
                
                HUDImageName = @"check_white.png";
                HUD.labelText = @"Following";
            }
            
            topicCountLabel.text = [NSString stringWithFormat:@"%d", topicCount];
            topicCountTextLabel.text = [NSString stringWithFormat:@"TOPIC%@", topicCount == 1 ? @"" : @"S"];
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
            tipCountLabel.text = [NSString stringWithFormat:@"%d", --tipCount];
            tipCountTextLabel.text = [NSString stringWithFormat:@"TIP%@", tipCount == 1 ? @"" : @"S"];
            
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
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"@%@", profileOwnerUsername] style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:profileView animated:YES];
    [profileView release];
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
    
    if (targetActionSheet.tag == 99) {          // User options
        
        if (buttonIndex == 0) {                                                 // Report User
            [self reportUser];
        }
        
    } else if (targetActionSheet.tag == 100) {  // Sharing options
        
        [self handleTipSharingAtIndexPath:targetActionSheet.indexPath forButtonAtIndex:buttonIndex];
        
    } else if (targetActionSheet.tag == 101) {  // Deletion options
        
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [selectedIndexes release];
    [feedEntries release];
    [settingsButtonItem release];
    [refreshHeaderView release];
    [settings release];
    [genericOptions release];
    [sharingOptions release];
    [deletionOptions release];
    [profileOwnerNameLabel release];
    [profileOwnerUsernameLabel release];
    [currentUserIndicator release];
    [locationMarkerIconView release];
    [profileOwnerURLButton release];
    [tipCountButton release];
    [topicCountButton release];
    [tipCountLabel release];
    [tipCountTextLabel release];
    [topicCountLabel release];
    [topicCountTextLabel release];
    [geniusCountButton release];
    [geniusCountLabel release];
    [geniusCountTextLabel release];
    [peopleHelpedLabel release];
    [peopleHelpedTextLabel release];
    [externIdentityButton_fb release];
    [externIdentityButton_twitter release];
    [profileOwnerCard release];
    [profileOwnerCardBg release];
    [foundUsefulButtonIconView release];
    [foundUsefulButtonTitle release];
    [foundUsefulButtonBg release];
    [foundUsefulLabel release];
    [foundUsefulStripChevron release];
    [feedTitle release];
    [tableHeader release];
    [phantomCard release];
    [super dealloc];
}


@end
