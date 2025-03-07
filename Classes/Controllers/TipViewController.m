#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import "TipViewController.h"
#import "TipboxAppDelegate.h"
#import "WebViewController.h"
#import "TopicViewController.h"
#import "MeViewController.h"
#import "ReportViewController.h"
#import "SearchViewController.h"
#import "Publisher.h"
#import "Timeline.h"
#import "TipCell.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation TipViewController

@synthesize scrollView, participantData;
@synthesize genius, marked, userFollowsTopic, fetchesOwnData;
@synthesize motherCellIndexPath, tipid, tipUserid, tipFullName, tipUsername;
@synthesize tipUserPicHash, subcat, parentCat, topicid, topicContent, catid;
@synthesize content, tipTimestamp, tipTimestamp_short, tipActualTime, usefulCount;

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

- (void)fetchTipData
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.strobeLight activateStrobeLight];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/gettipbyid", SH_DOMAIN]];
    
    dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest setPostValue:[NSNumber numberWithInt:tipid] forKey:@"tipid"];
    [dataRequest setCompletionBlock:^{
        NSError *jsonError;
        responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData objectForKey:@"error"] intValue] == 0) {
            NSMutableDictionary *tip = [[responseData objectForKey:@"responce"] mutableCopy];
            
            tipid = [[tip objectForKey:@"id"] intValue];
            tipUserid = [[tip objectForKey:@"userid"] intValue];
            tipFullName = [tip objectForKey:@"fullname"];
            tipUsername = [tip objectForKey:@"username"];
            tipUserPicHash = [tip objectForKey:@"pichash"];
            catid = [[tip objectForKey:@"catid"] intValue];
            subcat = [tip objectForKey:@"subcat"];
            parentCat = [tip objectForKey:@"parentcat"];
            content = [tip objectForKey:@"content"];
            topicid = [[tip objectForKey:@"topicid"] intValue];
            topicContent = [tip objectForKey:@"topicContent"];
            userFollowsTopic = [[tip objectForKey:@"followsTopic"] boolValue];
            tipTimestamp = [tip objectForKey:@"relativeTime"];
            tipTimestamp_short = [tip objectForKey:@"relativeTimeShort"];
            tipActualTime = [tip objectForKey:@"time"];
            //location_lat = [[tip objectForKey:@"location_lat"] floatValue];
            //location_long = [[tip objectForKey:@"location_long"] floatValue];
            usefulCount = [[tip objectForKey:@"likerCount"] intValue];
            participantData = [[tip objectForKey:@"likers"] mutableCopy];
            marked = [[tip objectForKey:@"marked"] boolValue];
            
            if (![[NSNull null] isEqual:[tip objectForKey:@"genius"]]) {
                genius = [[tip objectForKey:@"genius"] intValue];
            } else {
                genius = -1;
            }
            
            [self redrawView];
            [appDelegate.strobeLight deactivateStrobeLight];
        } else {
            NSLog(@"Could not fetch tip data!\nError:\n%@", dataRequest.responseString);
            [appDelegate.strobeLight negativeStrobeLight];
            
            if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
    }];
    [dataRequest setFailedBlock:^{
        TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.strobeLight negativeStrobeLight];
        
        NSError *error = [dataRequest error];
        NSLog(@"%@", error);
    }];
    [dataRequest startAsynchronous];
}

- (void)redrawView
{
    NSString *profilePicPath = [NSString stringWithFormat:@"http://%@/userphotos/%d/profile/m_%@.jpg", SH_DOMAIN, tipUserid, tipUserPicHash];
	userThmbnl.imageURL = [NSURL URLWithString:profilePicPath];
    
    tipTxtLabelShadowCopy.text = content;
    
    NSString* htmlContentString = [NSString stringWithFormat:
                                   @"<html>"
                                   "<head>"
                                   "<style type=\"text/css\">"
                                   "* { -webkit-touch-callout: none; -webkit-transform: translate3d(0,0,0); -webkit-user-select: none;}" // Disable selection.
                                   "body {background-color:transparent; color:#363636; font:normal 15px 'Helvetica Neue'; line-height:20px; margin:0; padding:0; text-shadow: 0 -2px 2px #d5d5d5; word-wrap:break-word; width:286px;}"
                                   "p {margin:0;}"
                                   "a:link, a:visited {color:#0073b9; text-decoration:none;}"
                                   "a:hover, a:active {color:#38b3ff;}"
                                   ".SHMention s {color:#38b3ff; text-decoration:none;}"
                                   "</style>"
                                   "<script type=\"text/javascript\">"
                                   "function escapeHtml(unsafe) {"
                                   "return unsafe"
                                   ".replace(/&/g, \"&amp;\")"
                                   ".replace(/</g, \"&lt;\")"
                                   ".replace(/>/g, \"&gt;\")"
                                   "}"
                                   "function replaceURLWithHTMLLinks(text) {"
                                   "if (!text) {return;}"
                                   "var replacedText, replacePattern1;"
                                   "replacePattern1 = /\\b((?:[a-z][\\w-]+:(?:\\/{1,3}|[a-z0-9%%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}\\/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))/gim;"
                                   "replacedText = text.replace(replacePattern1, '<a href=\"$1\" class=\"externLink\" ontouchstart=\"\">$1</a>');"
                                   "return replacedText;"
                                   "}"
                                   "function mentions(text) {"
                                   "if (!text) {"
                                   "return;"
                                   "} else {"
                                   "var replacedText, mention;"
                                   "mention = /(^|\\s|[^\\w\\d])@([\\w\\-_]+)/gi;"
                                   "replacedText = text.replace(mention, '$1<a href=\"@$2\" class=\"SHMention\" ontouchstart=\"\"><s>@</s><span>$2</span></a>');"
                                   "return replacedText;"
                                   "}"
                                   "}"
                                   "</script>"
                                   "</head>"
                                   "<body>"
                                   "<p id='tip'>%@</p>"
                                   "</body></html>", [content stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"]];
    
    [tipTxtLabel loadHTMLString:htmlContentString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
    
    nameLabel.text = tipFullName;
	usernameLabel.text = [NSString stringWithFormat:@"@%@", tipUsername];
	timestampLabel.text = tipTimestamp;
    topicLabel.text = topicContent;
    
    if ([[global readProperty:@"userid"] intValue] == tipUserid) {
        pane_markUsefulButton.enabled = NO;
        pane_deleteButton.enabled = YES;
    } else {
        pane_markUsefulButton.enabled = YES;
        pane_deleteButton.enabled = NO;
    }
    
    // Genius.
    if (genius == tipUserid) {
        geniusIcon.hidden = NO;
    } else {
        geniusIcon.hidden = YES;
    }
    
    // Marked useful.
    if (marked) {
        [pane_markUsefulButton setImage:[UIImage imageNamed:@"tip_view_bulb.png"] forState:UIControlStateNormal];
    } else {
        [pane_markUsefulButton setImage:[UIImage imageNamed:@"tip_view_bulb_off.png"] forState:UIControlStateNormal];
    }
    
    [self setUpFacemash];
    [self redisplayUsefulnessData];
    
    // Categories, subcategories.
    if ([parentCat isEqualToString:@"thing"]) {
        catIcon.image = [UIImage imageNamed:@"feed_category_thing.png"];
        categoryLabel.text = [NSString stringWithFormat:@"This tip is related to a thing (%@).", subcat];
    } else if ([parentCat isEqualToString:@"place"]) {
        catIcon.image = [UIImage imageNamed:@"feed_category_place.png"];
        categoryLabel.text = [NSString stringWithFormat:@"This tip is related to a place (%@).", subcat];
    } else {
        catIcon.image = [UIImage imageNamed:@"feed_category_idea.png"];
        categoryLabel.text = @"This tip is related to an idea.";
    }
	
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
	CGSize tipTxtSize = [content sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(286, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    CGSize nameSize = [tipFullName sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(200, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    CGSize usernameSize = [usernameLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(200, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
	nameLabel.frame = CGRectMake(47, 6, nameSize.width, 18);
    usernameLabel.frame = CGRectMake(47, 26, usernameSize.width, 17);
    geniusIcon.frame = CGRectMake(nameSize.width + 50, 7, 16, 16);
    tipTxtLabelShadowCopy.frame = CGRectMake(10, 85.5, 286, tipTxtSize.height);
    tipTxtLabel.frame = CGRectMake(10, 85, 286, tipTxtSize.height);
    tipOptionsLinen.frame = CGRectMake(4, tipTxtSize.height + 96, 300, 50);
    pane_markUsefulButton.frame = CGRectMake(4, tipTxtSize.height + 96, 76, 50);
    pane_tipOptionsButton.frame = CGRectMake(pane_markUsefulButton.frame.size.width, tipTxtSize.height + 96, 76, 50);
    pane_shareButton.frame = CGRectMake(pane_markUsefulButton.frame.size.width * 2, tipTxtSize.height + 96, 76, 50);
    pane_deleteButton.frame = CGRectMake(pane_markUsefulButton.frame.size.width * 3, tipTxtSize.height + 96, 76, 50);
    cardBgTexture.frame = CGRectMake(4, 4, 300, tipTxtSize.height + 175);
    topicButton.frame = CGRectMake(4, tipTxtSize.height + 146, 300, 33);
    card.frame = CGRectMake(6, 10, 308, tipTxtSize.height + 183);
    usefulnessMeterIconView.frame = CGRectMake(17, card.frame.size.height + 27, 14, 14);
    usefulnessMeter.frame = CGRectMake(38, card.frame.size.height + 23, 287, 20);
    facemashStripBg.frame = CGRectMake(14, card.frame.size.height + 43, 292, 42);
    dottedDivider.frame = CGRectMake(0, card.frame.size.height + 103, 320, 2);
    catIcon.frame = CGRectMake(147, card.frame.size.height + 118, 20, 20);
    categoryLabel.frame = CGRectMake(14, card.frame.size.height + 143, 292, 11);
	
	scrollView.contentSize = CGSizeMake(320, MAX(card.frame.size.height + screenHeight - 310, screenHeight - 40));
}

- (void)showTipSharingOptions:(id)sender
{
    sharingOptions = [[UITableViewActionSheet alloc] 
                      initWithTitle:@"Share this tip" 
                      delegate:self
                      cancelButtonTitle:@"Cancel" 
                      destructiveButtonTitle:nil 
                      otherButtonTitles:@"Copy Tip", @"Copy Link to Tip", @"Mail Tip", @"Facebook", @"Tweet", @"Message", nil];
    
	sharingOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    sharingOptions.tag = 100;
	TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [sharingOptions showFromTabBar:appDelegate.mainTabBarController.tabBar];
}

- (void)showTipDeletionOptions:(id)sender
{
	deletionOptions = [[UIActionSheet alloc] 
									 initWithTitle:@"Delete this tip?" 
									 delegate:self
									 cancelButtonTitle:@"Cancel" 
									 destructiveButtonTitle:@"Delete" 
									 otherButtonTitles:nil];
	deletionOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    deletionOptions.tag = 101;
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [deletionOptions showFromTabBar:appDelegate.mainTabBarController.tabBar];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (actionSheet.tag == 100) {       // Sharing options
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        
        if (buttonIndex == 0) {         // Copy Tip
            pasteboard.string = content;
        } else if (buttonIndex == 1) {  // Copy Link to Tip
            pasteboard.string = [NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, tipid];
        } else if (buttonIndex == 2) {  // Mail Tip
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            
            NSString *emailBody = [NSString stringWithFormat:
                                   @"<strong>%@</strong> <span style='color:#777;'>(@%@)</span> shared this tip on <em>%@</em> with you!<br /><br />“%@”<br /><br /><em style='color:#777;'>(Source on Tipbox: <a href=\"http://%@/tipbox/tip/%d\" style='color:#0073b9;text-decoration:none;'>http://%@/tipbox/tip/%d</a>)</em>", 
                                   tipFullName,
                                   tipUsername,
                                   topicContent,
                                   content, 
                                   SH_DOMAIN, 
                                   tipid, 
                                   SH_DOMAIN, 
                                   tipid]; // Fill out the email body text.
            [picker setSubject:[NSString stringWithFormat:@"A tip on %@ • Tipbox", topicContent]];
            [picker setMessageBody:emailBody isHTML:YES]; // Depends. Mostly YES, unless you want to send it as plain text (boring).
            
            picker.navigationBar.tintColor = [UIColor colorWithRed:162/255.0 green:165/255.0 blue:152/255.0 alpha:1.0];
            
            [appDelegate navbarShadowMode_navbar];
            [appDelegate tabbarShadowMode_nobar];
            [self presentModalViewController:picker animated:YES];
            [picker release];
        } else if (buttonIndex == 3) {  // Facebook
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                SLComposeViewController *fbController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                NSString *previewTxt = content;
                
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
                [fbController addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, tipid]]];
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
                              content, @"description",
                              [NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, tipid], @"link",
                              @"http://scapehouse.com/graphics/en/icons/tipbox_icon_medium.png", @"picture",
                              nil];
                } else {
                    NSArray* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [NSString stringWithFormat:@"@%@ on Tipbox", [global readProperty:@"username"]], @"name", @"http://scapehouse.com/", @"link", nil], nil];
                    NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
                    
                    params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:@"%@ shared a tip on Tipbox",  [global readProperty:@"name"]], @"name",
                              @"Tipbox is tip sharing, reinvented for your iPhone.", @"caption",
                              content, @"description",
                              [NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, tipid], @"link",
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
            NSString *previewTxt = content;
            
            if (previewTxt.length > 69) {
                previewTxt = [NSString stringWithFormat:@"%@… #Tipbox (by @Scapehouse)", [previewTxt substringToIndex:68]];
            } else {
                previewTxt = [NSString stringWithFormat:@"%@ #Tipbox (by @Scapehouse)", previewTxt];
            }
            
            [tweetSheet setInitialText:previewTxt];
            [tweetSheet addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/tip/%d", SH_DOMAIN, tipid]]];
            
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
                
                NSString *messageBody = [NSString stringWithFormat:@"%@ (Source on Tipbox: http://%@/tipbox/tip/%d)", content, SH_DOMAIN, tipid]; // Fill out the body text.
                [picker setBody:messageBody];
                
                picker.navigationBar.tintColor = [UIColor colorWithRed:162/255.0 green:165/255.0 blue:152/255.0 alpha:1.0];
                
                [appDelegate navbarShadowMode_navbar];
                [appDelegate tabbarShadowMode_nobar];
                [self presentModalViewController:picker animated:YES];
                [picker release];
            }
        }
        
    } else if (actionSheet.tag == 101) {// Deletion options
        
        if (buttonIndex == 0) {                                                 // Delete
            [self deleteTip];
        }
        
    } else if (actionSheet.tag == 102) {// Generic options
        
        if (buttonIndex == 0) {                                                 // Follow topic
            [self followTopic];
        } else if (buttonIndex == 1) {                                          // New Tip on Topic
            [self createTipOnTopic];
        } else if (buttonIndex == 2 && actionSheet.numberOfButtons == 4) {      // Report Tip
            [self reportTip];
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

#pragma mark Mark tip as useful
- (void)markUseful:(id)sender
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    if (marked == YES) {
        [pane_markUsefulButton setImage:[UIImage imageNamed:@"tip_view_bulb_off.png"] forState:UIControlStateNormal];
        pane_markUsefulButton.activated = NO;
        marked = NO;
        
        usefulCount--;
    } else if (marked == NO) {
        [pane_markUsefulButton setImage:[UIImage imageNamed:@"tip_view_bulb.png"] forState:UIControlStateNormal];
        pane_markUsefulButton.activated = YES;
        marked = YES;
        
        usefulCount++;
    }
    
    [self redisplayUsefulnessData];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/liketip", SH_DOMAIN]];
    
    dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest setPostValue:[NSNumber numberWithInt:tipid] forKey:@"tipid"];
    [dataRequest setCompletionBlock:^{
        NSError *jsonError;
        responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        if ([[responseData objectForKey:@"error"] intValue] == 0) {
            
        } else {
            // Revert the button's state.
            if (marked == YES) {
                [pane_markUsefulButton setImage:[UIImage imageNamed:@"tip_view_bulb_off.png"] forState:UIControlStateNormal];
                pane_markUsefulButton.activated = NO;
                marked = NO;
                
                usefulCount--;
            } else if (marked == NO) {
                [pane_markUsefulButton setImage:[UIImage imageNamed:@"tip_view_bulb.png"] forState:UIControlStateNormal];
                pane_markUsefulButton.activated = YES;
                marked = YES;
                
                usefulCount++;
            }
            
            [self redisplayUsefulnessData];
            
            NSLog(@"Could not mark/unmark tip!\nError:\n%@", dataRequest.responseString);
            [appDelegate.strobeLight negativeStrobeLight];
            
            if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
    }];
    [dataRequest setFailedBlock:^{
        [appDelegate.strobeLight negativeStrobeLight];
        
        // Revert the button's state.
        if (marked == YES) {
            [pane_markUsefulButton setImage:[UIImage imageNamed:@"tip_view_bulb_off.png"] forState:UIControlStateNormal];
            pane_markUsefulButton.activated = NO;
            marked = NO;
            
            usefulCount--;
        } else if (marked == NO) {
            [pane_markUsefulButton setImage:[UIImage imageNamed:@"tip_view_bulb.png"] forState:UIControlStateNormal];
            pane_markUsefulButton.activated = YES;
            marked = YES;
            
            usefulCount++;
        }
        
        [self redisplayUsefulnessData];
        
        NSError *error = [dataRequest error];
        NSLog(@"%@", error);
    }];
    [dataRequest startAsynchronous];
}

#pragma mark More tip options
- (void)showMoreTipOptions:(id)sender
{
    if (userFollowsTopic) {
        if ([[global readProperty:@"userid"] intValue] == tipUserid) {
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
        if ([[global readProperty:@"userid"] intValue] == tipUserid) {
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
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [genericOptions showFromTabBar:appDelegate.mainTabBarController.tabBar];
}

#pragma mark Delete tip
- (void)deleteTip
{
    deleted = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Create tip on topic
- (void)createTipOnTopic
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    int category;
    
    if ([parentCat isEqualToString:@"thing"]) {
        category = 0;
    } else if ([parentCat isEqualToString:@"place"]) {
        category = 1;
    } else {
        category = 2;
    }
    
    if ([subcat isEqualToString:@"none"]) {
        subcat = @"This category doesn't need a subcategory.";
    }
    
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

#pragma mark Follow tip topic
- (void)followTopic
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    [appDelegate.strobeLight activateStrobeLight];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/followtopic", SH_DOMAIN]];
    
    dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest setPostValue:[NSNumber numberWithInt:topicid] forKey:@"topicid"];
    [dataRequest setCompletionBlock:^{
        NSError *jsonError;
        responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        
        
        if ([[responseData objectForKey:@"error"] intValue] == 0) {
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            NSString *HUDImageName;
            
            if (userFollowsTopic) {
                userFollowsTopic = 0;
                
                HUDImageName = @"cross_white.png";
                HUD.labelText = @"Unfollowed";
            } else {
                userFollowsTopic = 1;
                
                HUDImageName = @"check_white.png";
                HUD.labelText = @"Following";
            }
            
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:HUDImageName]] autorelease];
            HUD.mode = MBProgressHUDModeCustomView; // Set custom view mode.
            HUD.dimBackground = YES;
            HUD.delegate = self;
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:2];
        } else {
            if ([[responseData objectForKey:@"errormsg"] isEqualToString:@"authFail"]) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                [appDelegate logoutWithMessage:@"Sorry, but you need to log in again!"];
            }
        }
        
        [appDelegate.strobeLight deactivateStrobeLight];
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
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:3];
        
        NSError *error = [dataRequest error];
        NSLog(@"%@", error);
    }];
    [dataRequest startAsynchronous];
}

#pragma mark Report tip
- (void)reportTip
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.SHToken || [appDelegate.SHToken isEqualToString:@""]) {
        [appDelegate logoutWithMessage:@"You need to log in before you can do that!"];
        
        return;
    }
    
    ReportViewController *reportView = [[ReportViewController alloc] initWithNibName:@"ReportView" bundle:nil];
    reportView.reportType = @"tip";
    reportView.objectid = tipid;
    [self presentModalViewController:reportView animated:true];
    [reportView release];
}

- (void)viewDidLoad
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    global = appDelegate.global;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenBound.size.height;
    
    [appDelegate showNavbarShadowAnimated:YES];
    [self setTitle:@"Tip"]; // This is for setting a custom title color.
    
    // If the user swipes to the right, it pops the view controller.
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeView)];
    gesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:gesture];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:192.0/255.0 green:133.0/255.0 blue:87.0/255.0 alpha:1.0];
    
    scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    scrollView.showsVerticalScrollIndicator = NO; // Personally, I think it's just useless clutter.
    scrollView.contentSize = CGSizeMake(320, screenHeight - 40);
    
    card = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
    card.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    card.opaque = YES;
    card.frame = CGRectMake(6, 10, 308, 183);
    card.userInteractionEnabled = YES;
    
    cardBgTexture = [CALayer layer];
    cardBgTexture.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]].CGColor;
    cardBgTexture.opaque = YES;
    [cardBgTexture setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)]; // Sets the co-ordinates right.
    cardBgTexture.frame = CGRectMake(4, 4, 300, 175);
    
    tipAuthorButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    tipAuthorButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    [tipAuthorButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [tipAuthorButton addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
    tipAuthorButton.frame = CGRectMake(4, 4, 300, 49);
    tipAuthorButton.tag = 1;
    
    userThmbnlOverlay = [[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:3.0];
    userThmbnlOverlayView = [[UIImageView alloc] initWithImage:userThmbnlOverlay];
    userThmbnlOverlayView.frame = CGRectMake(5, 6, 36, 36);
    
    userThmbnl = [[EGOImageView alloc] initWithFrame:CGRectMake(8, 8, 30, 30)];
    userThmbnl.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
    userThmbnl.opaque = YES;
    userThmbnl.layer.shouldRasterize = YES;
    userThmbnl.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    nameLabel = [[LPLabel alloc] initWithFrame:CGRectMake(47, 6, 100, 15)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    nameLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    nameLabel.numberOfLines = 1;
    nameLabel.minimumFontSize = 8.;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
    nameLabel.text = @"";
    
    usernameLabel = [[LPLabel alloc] initWithFrame:CGRectMake(47, 24, 100, 15)];
    usernameLabel.backgroundColor = [UIColor clearColor];
    usernameLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    usernameLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    usernameLabel.numberOfLines = 1;
    usernameLabel.minimumFontSize = 8.;
    usernameLabel.adjustsFontSizeToFitWidth = YES;
    usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    usernameLabel.text = @"";
    
    geniusIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genius_star.png"]];
    geniusIcon.hidden = YES;
    
    UIImageView *tipAuthorButtonChevron = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feed_chevron_grey.png"]];
    tipAuthorButtonChevron.frame = CGRectMake(282, 16, 10, 17);
	
    detailsSeparator = [CALayer layer];
    detailsSeparator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"solid_line_red.png"]].CGColor;
    detailsSeparator.frame = CGRectMake(10, 53, 288, 2);
    detailsSeparator.opaque = YES;
    [detailsSeparator setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
    
    clockIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small_grey_clock.png"]];
    clockIcon.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    clockIcon.frame = CGRectMake(10, 58, 14, 14);
    
    timestampLabel = [[LPLabel alloc] initWithFrame:CGRectMake(26, 59, 250, 14)];
    timestampLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    timestampLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
    timestampLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    timestampLabel.numberOfLines = 1;
    timestampLabel.minimumFontSize = 8.;
    timestampLabel.adjustsFontSizeToFitWidth = YES;
    timestampLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
    timestampLabel.opaque = YES;
    timestampLabel.text = @"...";
    
    timestampSeparator = [CALayer layer];
    timestampSeparator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_red.png"]].CGColor;
    timestampSeparator.opaque = YES;
    [timestampSeparator setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
    timestampSeparator.frame = CGRectMake(10, 76, 288, 2);
    
    /*tipTxtLabel = [[TTTAttributedLabel alloc] init];
	tipTxtLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    tipTxtLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    tipTxtLabel.numberOfLines = 0;
    tipTxtLabel.lineBreakMode = UILineBreakModeWordWrap;
    tipTxtLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    tipTxtLabel.dataDetectorTypes = UIDataDetectorTypeAll; // Automatically detect links when the label text is subsequently changed.
    tipTxtLabel.text = content;
    tipTxtLabel.delegate = self;
    tipTxtLabel.userInteractionEnabled = YES;
    
    NSRegularExpression *mentionRegex = [NSRegularExpression regularExpressionWithPattern:@"(@[a-zA-Z0-9_]+)" options:0 error:NULL];
    NSArray *allMentions = [mentionRegex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    
    for (NSTextCheckingResult *mentionMatch in allMentions) {
        int captureIndex;
        for (captureIndex = 1; captureIndex < mentionMatch.numberOfRanges; captureIndex++) {
            [tipTxtLabel addLinkToURL:[NSURL URLWithString:[content substringWithRange:[mentionMatch rangeAtIndex:captureIndex]]] withRange:[mentionMatch rangeAtIndex:1]]; // Embedding a custom link in a substring
        }
    }*/
    
    // UIWebView lags for a few seconds sometimes before showing its contents. This shadow label sorta remedies that issue.
    tipTxtLabelShadowCopy = [[UILabel alloc] initWithFrame:CGRectMake(10, 85.5, 286, 20)];
    tipTxtLabelShadowCopy.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    tipTxtLabelShadowCopy.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    tipTxtLabelShadowCopy.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    tipTxtLabelShadowCopy.shadowOffset = CGSizeMake(0, 1);
    tipTxtLabelShadowCopy.numberOfLines = 0;
    tipTxtLabelShadowCopy.lineBreakMode = UILineBreakModeWordWrap;
    tipTxtLabelShadowCopy.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    tipTxtLabelShadowCopy.opaque = YES;
    tipTxtLabelShadowCopy.text = @"Loading tip...";
    
    tipTxtLabel = [[UIWebView alloc] initWithFrame:CGRectMake(10, 85, 286, 20)];
    tipTxtLabel.backgroundColor = [UIColor clearColor];
    tipTxtLabel.opaque = NO;
    tipTxtLabel.scalesPageToFit = NO;
    tipTxtLabel.delegate = self;
    
    NSString* htmlContentString = [NSString stringWithFormat:
                                   @"<html>"
                                   "<head>"
                                   "<style type=\"text/css\">"
                                   "* { -webkit-touch-callout: none; -webkit-transform: translate3d(0,0,0); -webkit-user-select: none;}" // Disable selection.
                                   "body {background-color:transparent; color:#363636; font:normal 15px 'Helvetica Neue'; margin:0; padding:0; text-shadow: 0 -2px 2px #d5d5d5; word-wrap:break-word; width:286px;}"
                                   "p {margin:0;}"
                                   "</style>"
                                   "</head>"
                                   "<body>"
                                   "<p id='tip'>Loading tip...</p>"
                                   "</body></html>"];
    
    [tipTxtLabel loadHTMLString:htmlContentString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
    
    tipOptionsLinen = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tip_view_tip_options.png"]];
    tipOptionsLinen.opaque = YES;
    tipOptionsLinen.userInteractionEnabled = YES;
    tipOptionsLinen.frame = CGRectMake(0, 0, 0, 0);
    
    pane_markUsefulButton = [[ToggleButton alloc] init];
    [pane_markUsefulButton setImage:[UIImage imageNamed:@"tip_view_bulb_off.png"] forState:UIControlStateNormal];
    [pane_markUsefulButton addTarget:self action:@selector(markUseful:) forControlEvents:UIControlEventTouchUpInside];
    pane_markUsefulButton.showsTouchWhenHighlighted = YES;
    
    pane_tipOptionsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [pane_tipOptionsButton setImage:[UIImage imageNamed:@"tip_view_gear.png"] forState:UIControlStateNormal];
    [pane_tipOptionsButton addTarget:self action:@selector(showMoreTipOptions:) forControlEvents:UIControlEventTouchUpInside];
    pane_tipOptionsButton.showsTouchWhenHighlighted = YES;
    
    pane_shareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [pane_shareButton setImage:[UIImage imageNamed:@"tip_view_action.png"] forState:UIControlStateNormal];
    [pane_shareButton addTarget:self action:@selector(showTipSharingOptions:) forControlEvents:UIControlEventTouchUpInside];
    pane_shareButton.showsTouchWhenHighlighted = YES;
    
    pane_deleteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [pane_deleteButton setImage:[UIImage imageNamed:@"tip_view_delete.png"] forState:UIControlStateNormal];
    [pane_deleteButton addTarget:self action:@selector(showTipDeletionOptions:) forControlEvents:UIControlEventTouchUpInside];
    pane_deleteButton.showsTouchWhenHighlighted = YES;
    
    UIImageView *topicStripIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_bar_topics.png"]];
    topicStripIcon.frame = CGRectMake(7, 1, 30, 30);
    
    UIImageView *topicStripChevron = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feed_chevron_black.png"]];
    topicStripChevron.frame = CGRectMake(283, 9, 10, 17);
    
    topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 7, 230, 19)];
    topicLabel.backgroundColor = [UIColor clearColor];
    topicLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
    topicLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    topicLabel.shadowOffset = CGSizeMake(0, 1);
    topicLabel.numberOfLines = 1;
    topicLabel.minimumFontSize = 8.;
    topicLabel.adjustsFontSizeToFitWidth = YES;
    topicLabel.font = [UIFont fontWithName:@"Georgia" size:MIN_MAIN_FONT_SIZE];
    topicLabel.opaque = YES;
    
    topicButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    topicButton.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0];
    [topicButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [topicButton addTarget:self action:@selector(gotoTopic:) forControlEvents:UIControlEventTouchUpInside];
    topicButton.frame = CGRectMake(4, 146, 300, 33);
    
    usefulnessMeter = [[UILabel alloc] initWithFrame:CGRectMake(38, card.frame.size.height + 23, 287, 20)];
    usefulnessMeter.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
	usefulnessMeter.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
    usefulnessMeter.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    usefulnessMeter.shadowOffset = CGSizeMake(0, 1);
	usefulnessMeter.numberOfLines = 1;
    usefulnessMeter.minimumFontSize = 8.;
    usefulnessMeter.adjustsFontSizeToFitWidth = YES;
	usefulnessMeter.font = [UIFont boldSystemFontOfSize:MIN_SECONDARY_FONT_SIZE];
    usefulnessMeter.opaque = YES;
    usefulnessMeter.text = [NSString stringWithFormat:@"HOLD ON..."];
    
    usefulnessMeterIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small_grey_bulb.png"]];
    usefulnessMeterIconView.frame = CGRectMake(17, card.frame.size.height + 27, 14, 14);
    
    facemashStripBg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
    facemashStripBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    facemashStripBg.opaque = YES;
    facemashStripBg.frame = CGRectMake(14, card.frame.size.height + 43, 292, 42);
    facemashStripBg.userInteractionEnabled = YES;
    
    UIView *facemashStrip = [[UIView alloc] initWithFrame:CGRectMake(4, 4, 284, 34)];
    facemashStrip.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
    facemashStrip.opaque = YES;
    
    // Initialize the facemash photos.
    facemash_1 = [[FacemashPhoto alloc] init];
    facemash_1.tag = 10;
    facemash_1.photo.imageURL = nil;
    facemash_1.enabled = NO;
    facemash_1.layer.shouldRasterize = YES;
    facemash_1.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    facemash_2 = [[FacemashPhoto alloc] init];
    facemash_2.tag = 20;
    facemash_2.photo.imageURL = nil;
    facemash_2.enabled = NO;
    facemash_2.layer.shouldRasterize = YES;
    facemash_2.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    facemash_3 = [[FacemashPhoto alloc] init];
    facemash_3.tag = 30;
    facemash_3.photo.imageURL = nil;
    facemash_3.enabled = NO;
    facemash_3.layer.shouldRasterize = YES;
    facemash_3.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    facemash_4 = [[FacemashPhoto alloc] init];
    facemash_4.tag = 40;
    facemash_4.photo.imageURL = nil;
    facemash_4.enabled = NO;
    facemash_4.layer.shouldRasterize = YES;
    facemash_4.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    facemash_5 = [[FacemashPhoto alloc] init];
    facemash_5.tag = 50;
    facemash_5.photo.imageURL = nil;
    facemash_5.enabled = NO;
    facemash_5.layer.shouldRasterize = YES;
    facemash_5.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    facemash_6 = [[FacemashPhoto alloc] init];
    facemash_6.tag = 60;
    facemash_6.photo.imageURL = nil;
    facemash_6.enabled = NO;
    facemash_6.layer.shouldRasterize = YES;
    facemash_6.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    facemash_7 = [[FacemashPhoto alloc] init];
    facemash_7.tag = 70;
    facemash_7.photo.imageURL = nil;
    facemash_7.enabled = NO;
    facemash_7.layer.shouldRasterize = YES;
    facemash_7.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    facemash_8 = [[FacemashPhoto alloc] init];
    facemash_8.tag = 80;
    facemash_8.photo.imageURL = nil;
    facemash_8.enabled = NO;
    facemash_8.layer.shouldRasterize = YES;
    facemash_8.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    facemash_9 = [[FacemashPhoto alloc] init];
    facemash_9.tag = 90;
    facemash_9.photo.imageURL = nil;
    facemash_9.enabled = NO;
    facemash_9.layer.shouldRasterize = YES;
    facemash_9.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    facemash_1.frame = CGRectMake(5, 5, 25, 26);
    facemash_2.frame = CGRectMake(facemash_1.frame.size.width + 11, 5, 25, 26);
    facemash_3.frame = CGRectMake(facemash_2.frame.size.width * 2 + 18, 5, 25, 26);
    facemash_4.frame = CGRectMake(facemash_3.frame.size.width * 3 + 24, 5, 25, 26);
    facemash_5.frame = CGRectMake(facemash_4.frame.size.width * 4 + 30, 5, 25, 26);
    facemash_6.frame = CGRectMake(facemash_5.frame.size.width * 5 + 36, 5, 25, 26);
    facemash_7.frame = CGRectMake(facemash_6.frame.size.width * 6 + 42, 5, 25, 26);
    facemash_8.frame = CGRectMake(facemash_7.frame.size.width * 7 + 48, 5, 25, 26);
    facemash_9.frame = CGRectMake(facemash_8.frame.size.width * 8 + 54, 5, 25, 26);
    
    [facemash_1 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
    [facemash_2 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
    [facemash_3 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
    [facemash_4 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
    [facemash_5 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
    [facemash_6 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
    [facemash_7 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
    [facemash_8 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
    [facemash_9 addTarget:self action:@selector(gotoUser:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setUpFacemash];
    
    dottedDivider = [CALayer layer];
    dottedDivider.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_grey.png"]].CGColor;
    dottedDivider.opaque = YES;
    [dottedDivider setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
    
    catIcon = [[UIImageView alloc] init];
    catIcon.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    catIcon.opaque = YES;
    
    categoryLabel = [[UILabel alloc] init];
    categoryLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
	categoryLabel.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
    categoryLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    categoryLabel.shadowOffset = CGSizeMake(0, 1);
	categoryLabel.numberOfLines = 1;
    categoryLabel.textAlignment = UITextAlignmentCenter;
	categoryLabel.font = [UIFont italicSystemFontOfSize:MIN_SECONDARY_FONT_SIZE];
    categoryLabel.opaque = YES;
    
    // Check if this view needs to fetch its own data from the server.
    if (fetchesOwnData) {
        [self fetchTipData];
    } else {
        [self redrawView];
    }
    
    [card.layer addSublayer:cardBgTexture];
    [card addSubview:tipAuthorButton];
    [card.layer addSublayer:detailsSeparator];
    [card addSubview:tipTxtLabelShadowCopy];
    [card addSubview:tipTxtLabel];
    [card addSubview:clockIcon];
    [card addSubview:timestampLabel];
    [card.layer addSublayer:timestampSeparator];
    [card addSubview:tipOptionsLinen];
    [card addSubview:pane_markUsefulButton];
    [card addSubview:pane_shareButton];
    [card addSubview:pane_tipOptionsButton];
    [card addSubview:pane_deleteButton];
    [card addSubview:topicButton];
    [tipAuthorButton addSubview:userThmbnlOverlayView];
    [tipAuthorButton addSubview:userThmbnl];
    [tipAuthorButton addSubview:nameLabel];
    [tipAuthorButton addSubview:usernameLabel];
    [tipAuthorButton addSubview:geniusIcon];
    [tipAuthorButton addSubview:tipAuthorButtonChevron];
    [topicButton addSubview:topicStripIcon];
    [topicButton addSubview:topicLabel];
    [topicButton addSubview:topicStripChevron];
    [facemashStripBg addSubview:facemashStrip];
    [facemashStrip addSubview:facemash_1];
    [facemashStrip addSubview:facemash_2];
    [facemashStrip addSubview:facemash_3];
    [facemashStrip addSubview:facemash_4];
    [facemashStrip addSubview:facemash_5];
    [facemashStrip addSubview:facemash_6];
    [facemashStrip addSubview:facemash_7];
    [facemashStrip addSubview:facemash_8];
    [facemashStrip addSubview:facemash_9];
    [scrollView addSubview:card];
    [scrollView addSubview:usefulnessMeterIconView];
    [scrollView addSubview:usefulnessMeter];
    [scrollView addSubview:facemashStripBg];
    [scrollView.layer addSublayer:dottedDivider];
    [scrollView addSubview:catIcon];
    [scrollView addSubview:categoryLabel];
    
	[gesture release];
    [tipAuthorButtonChevron release];
    [tipOptionsLinen release];
    [topicStripIcon release];
    [topicStripChevron release];
    [facemashStrip release];
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
        [appDelegate tabbarShadowMode_tabbar];
        
        HUD.delegate = nil;
        
        // Make sure we're not in a notification sheet!
        if (!fetchesOwnData) {
            // We need to modify the original cell that popped this view.
            Timeline *feed = (Timeline *)[viewControllers objectAtIndex:viewControllers.count - 1];
            TipCell *targetCell;
            
            if ([feed isKindOfClass:[SearchViewController class]]) { // The search view uses a different table to show the tips!
                SearchViewController *searchView = (SearchViewController *)[viewControllers objectAtIndex:viewControllers.count - 1];
                feed = searchView;
                targetCell = (TipCell *)[searchView.searchResultsTableView cellForRowAtIndexPath:motherCellIndexPath];
            } else {
                targetCell = (TipCell *)[feed.timelineFeed cellForRowAtIndexPath:motherCellIndexPath];
            }
            
            if (marked) { // Marked useful.
                [targetCell.tipCardView.markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button_activated.png"] forState:UIControlStateNormal];
                targetCell.tipCardView.markUsefulButton.activated = YES;
                targetCell.tipCardView.marked = YES;
                [[feed.feedEntries objectAtIndex:motherCellIndexPath.row] setObject:@"YES" forKey:@"marked"];
            } else {
                [targetCell.tipCardView.markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button.png"] forState:UIControlStateNormal];
                targetCell.tipCardView.markUsefulButton.activated = NO;
                targetCell.tipCardView.marked = NO;
                [[feed.feedEntries objectAtIndex:motherCellIndexPath.row] setObject:@"NO" forKey:@"marked"];
            }
            
            targetCell.tipCardView.participantData = participantData;
            targetCell.tipCardView.usefulCount = usefulCount;
            [targetCell.tipCardView redisplayUsefulnessData];
            [targetCell.tipCardView setUpFacemash];
            
            if (deleted) { // Cell has been marked for deletion. Finish it! :P
                           // Since we don't know for sure whether the cell is collapsed or not, we collapse it anyways.
                BOOL isSelected = NO;
                
                // Store cell 'selected' state keyed on indexPath
                NSNumber *selectedIndex = [NSNumber numberWithBool:isSelected];
                [feed.selectedIndexes setObject:selectedIndex forKey:motherCellIndexPath];
                targetCell.tipCardView.isSelected = isSelected;
                
                [targetCell collapseCell];
                
                feed.tapCount = 0;
                feed.tappedRow = -1;
                
                [appDelegate.strobeLight activateStrobeLight];
                
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/deletetip", SH_DOMAIN]];
                
                dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
                [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
                [dataRequest setPostValue:[NSNumber numberWithInt:targetCell.tipCardView.tipid] forKey:@"tipid"];
                [dataRequest setCompletionBlock:^{
                    NSError *jsonError;
                    responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
                    
                    if ([[responseData objectForKey:@"error"] intValue] == 0) {
                        [feed.feedEntries removeObjectAtIndex:targetCell.tipCardView.rowNumber];
                        
                        if ([feed isKindOfClass:[SearchViewController class]]) { // The search view uses a different table to show the tips!
                            SearchViewController *searchView = (SearchViewController *)[viewControllers objectAtIndex:viewControllers.count - 1];
                            [searchView.searchResultsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:motherCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                        } else {
                            [feed.timelineFeed deleteRowsAtIndexPaths:[NSArray arrayWithObject:motherCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                        }
                        
                        [appDelegate.strobeLight deactivateStrobeLight];
                    } else {
                        NSLog(@"Could not delete tip!\nError:\n%@", dataRequest.responseString);
                        [appDelegate.strobeLight negativeStrobeLight];
                        
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
                    
                    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate.strobeLight negativeStrobeLight];
                    
                    [HUD show:YES];
                    [HUD hide:YES afterDelay:3];
                    
                    NSError *error = [dataRequest error];
                    NSLog(@"%@", error);
                }];
                [dataRequest startAsynchronous];
            }
        }
    }
    
    [super viewWillDisappear:animated];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *cleanedString;
    
    cleanedString = [content stringByReplacingOccurrencesOfString:@"\n" withString:@"\t"];
    cleanedString = [cleanedString stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\\\\\"]; // Escape the backslashes! Note that we add 2 escape layers, not 1!
    cleanedString = [cleanedString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"]; // Escape the single quotes!
    cleanedString = [cleanedString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]; // Escape the double quotes!
    
    cleanedString = [tipTxtLabel stringByEvaluatingJavaScriptFromString:
                     [NSString stringWithFormat:@"escapeHtml('%@');", cleanedString]]; // Temporarily change \n to \t to prevent choking, then clean HTML.
    
    // Escape everything again because the previous JS evaluation resets all the text.
    cleanedString = [cleanedString stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\\\\\"];
    cleanedString = [cleanedString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    cleanedString = [cleanedString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    // Change \n to <br />, linkify links, stick in @mentions.
    [tipTxtLabel stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"document.getElementById('tip').innerHTML = mentions(replaceURLWithHTMLLinks('%@'));", [cleanedString stringByReplacingOccurrencesOfString:@"\t" withString:@"<br />"]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        // If the URL is an @mention, we push a profile view controller, otherwise we push a normal WebView controller.
        NSRegularExpression *mentionRegex = [NSRegularExpression regularExpressionWithPattern:@"(@[a-zA-Z0-9_]+)" options:0 error:NULL];
        NSArray *mentionCheckingResults = [mentionRegex matchesInString:request.URL.absoluteString options:0 range:NSMakeRange(0, request.URL.absoluteString.length)];
        
        for (NSTextCheckingResult *ntcr in mentionCheckingResults) {
            NSString *match = [request.URL.absoluteString substringWithRange:[ntcr rangeAtIndex:1]];
            NSString *processedUsername = [match substringWithRange:NSMakeRange(1, [match length] - 1)];
            
            MeViewController *profileView = [[MeViewController alloc] 
                                             initWithNibName:@"MeView" 
                                             bundle:[NSBundle mainBundle]];
            
            profileView.isCurrentUser = NO;
            profileView.profileOwnerUsername = processedUsername;
            self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Tip" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
            [self.navigationController pushViewController:profileView animated:YES];
            [profileView release];
            profileView = nil;
            
            return NO;
        }
        
        NSString *url = request.URL.absoluteString;
        
        NSRange rangeOfSubstring = [url rangeOfString:@"/Tipbox.app/"];
        
        if (rangeOfSubstring.location != NSNotFound) {
            url = [url substringFromIndex:rangeOfSubstring.location + 12];
        }
        
        if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"] && ![url hasPrefix:@"ftp://"] && ![url hasPrefix:@"ftps://"]) {
            url = [NSString stringWithFormat:@"http://%@", url];
        }
        
        WebViewController *SHBrowser = [[WebViewController alloc] 
                                        initWithNibName:@"WebView" 
                                        bundle:[NSBundle mainBundle]];
        SHBrowser.url = url;
        [SHBrowser setTitle:url];
        SHBrowser.hidesBottomBarWhenPushed = YES;
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Tip" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:SHBrowser animated:YES];
        [SHBrowser release];
        SHBrowser = nil;
        
        return NO;
    }
    
    return YES;
}

- (void)redisplayUsefulnessData
{
    if (usefulCount > 1) {
        usefulnessMeter.text = [NSString stringWithFormat:@"%d PEOPLE FOUND THIS USEFUL", usefulCount];
        
        if (marked) {
            if (usefulCount == 2) {
                usefulnessMeter.text = [NSString stringWithFormat:@"YOU & 1 OTHER PERSON FOUND THIS USEFUL"];
            } else if (usefulCount > 2) {
                usefulnessMeter.text = [NSString stringWithFormat:@"YOU & %d PEOPLE FOUND THIS USEFUL", usefulCount - 1];
            }
            
            if ([participantData count] < 10) {
                
                // If the user's already in the facemash, stop.
                for (NSDictionary *data_facemash in participantData) {
                    int userid = [[data_facemash objectForKey:@"userid"] intValue];
                    
                    if ([[global readProperty:@"userid"] intValue] == userid) {
                        return;
                    }
                }
                
                NSDictionary *me = [[NSDictionary alloc] initWithObjectsAndKeys:[global readProperty:@"name"], @"fullname",
                                    [global readProperty:@"username"], @"username", 
                                    [global readProperty:@"userid"], @"userid",
                                    [global readProperty:@"userPicHash"], @"pichash", nil];
                
                [participantData addObject:me];
                [me release];
                [self setUpFacemash];
            }
        } else {
            int deletionIndex = -1;
            
            // Find the user in the facemash, and remove them if they exist.
            for (NSDictionary *data_facemash in participantData) {
                int userid = [[data_facemash objectForKey:@"userid"] intValue];
                
                if ([[global readProperty:@"userid"] intValue] == userid) {
                    deletionIndex = [participantData indexOfObject:data_facemash];
                }
            }
            
            if (deletionIndex != -1) {
                [participantData removeObjectAtIndex:deletionIndex];
                [self setUpFacemash];
            }
        }
    } else if (usefulCount == 1) {
        usefulnessMeter.text = [NSString stringWithFormat:@"1 PERSON FOUND THIS USEFUL"];
        
        if (marked) {
            usefulnessMeter.text = [NSString stringWithFormat:@"YOU FOUND THIS USEFUL"];
            
            if ([participantData count] < 10) {
                
                // If the user's already in the facemash, stop.
                for (NSDictionary *data_facemash in participantData) {
                    int userid = [[data_facemash objectForKey:@"userid"] intValue];
                    
                    if ([[global readProperty:@"userid"] intValue] == userid) {
                        return;
                    }
                }
                
                NSDictionary *me = [[NSDictionary alloc] initWithObjectsAndKeys:[global readProperty:@"name"], @"fullname",
                                    [global readProperty:@"username"], @"username", 
                                    [global readProperty:@"userid"], @"userid",
                                    [global readProperty:@"userPicHash"], @"pichash", nil];
                
                [participantData addObject:me];
                [me release];
                [self setUpFacemash];
            }
        } else {
            int deletionIndex = -1;
            
            // Find the user in the facemash, and remove them if they exist.
            for (NSDictionary *data_facemash in participantData) {
                int userid = [[data_facemash objectForKey:@"userid"] intValue];
                
                if ([[global readProperty:@"userid"] intValue] == userid) {
                    deletionIndex = [participantData indexOfObject:data_facemash];
                }
            }
            
            if (deletionIndex != -1) {
                [participantData removeObjectAtIndex:deletionIndex];
                [self setUpFacemash];
            }
        }
    } else if (usefulCount == 0) {
        usefulnessMeter.text = [NSString stringWithFormat:@"NOBODY FOUND THIS USEFUL YET"];
        
        [participantData removeAllObjects];
        [self setUpFacemash];
    }
}

- (void)setUpFacemash
{
    // Facemash setup.
    switch ([participantData count]) {
        case 0:
        {
            facemash_1.photo.placeholderImage = nil;
            facemash_1.photo.imageURL = nil;
            facemash_1.enabled = NO;
            facemash_2.photo.placeholderImage = nil;
            facemash_2.photo.imageURL = nil;
            facemash_2.enabled = NO;
            facemash_3.photo.placeholderImage = nil;
            facemash_3.photo.imageURL = nil;
            facemash_3.enabled = NO;
            facemash_4.photo.placeholderImage = nil;
            facemash_4.photo.imageURL = nil;
            facemash_4.enabled = NO;
            facemash_5.photo.placeholderImage = nil;
            facemash_5.photo.imageURL = nil;
            facemash_5.enabled = NO;
            facemash_6.photo.placeholderImage = nil;
            facemash_6.photo.imageURL = nil;
            facemash_6.enabled = NO;
            facemash_7.photo.placeholderImage = nil;
            facemash_7.photo.imageURL = nil;
            facemash_7.enabled = NO;
            facemash_8.photo.placeholderImage = nil;
            facemash_8.photo.imageURL = nil;
            facemash_8.enabled = NO;
            facemash_9.photo.placeholderImage = nil;
            facemash_9.photo.imageURL = nil;
            facemash_9.enabled = NO;
            break;
        }
            
        case 1:
        {
            NSDictionary *data_facemash_1 = [participantData objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.enabled = YES;
            facemash_1.name = [NSString stringWithFormat:@"%@", [data_facemash_1 objectForKey:@"fullname"]];
            facemash_1.username = [data_facemash_1 objectForKey:@"username"];
            facemash_1.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            facemash_2.photo.placeholderImage = nil;
            facemash_2.photo.imageURL = nil;
            facemash_2.enabled = NO;
            facemash_3.photo.placeholderImage = nil;
            facemash_3.photo.imageURL = nil;
            facemash_3.enabled = NO;
            facemash_4.photo.placeholderImage = nil;
            facemash_4.photo.imageURL = nil;
            facemash_4.enabled = NO;
            facemash_5.photo.placeholderImage = nil;
            facemash_5.photo.imageURL = nil;
            facemash_5.enabled = NO;
            facemash_6.photo.placeholderImage = nil;
            facemash_6.photo.imageURL = nil;
            facemash_6.enabled = NO;
            facemash_7.photo.placeholderImage = nil;
            facemash_7.photo.imageURL = nil;
            facemash_7.enabled = NO;
            facemash_8.photo.placeholderImage = nil;
            facemash_8.photo.imageURL = nil;
            facemash_8.enabled = NO;
            facemash_9.photo.placeholderImage = nil;
            facemash_9.photo.imageURL = nil;
            facemash_9.enabled = NO;
            break;
        }
            
        case 2:
        {
            NSDictionary *data_facemash_1 = [participantData objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.enabled = YES;
            facemash_1.name = [NSString stringWithFormat:@"%@", [data_facemash_1 objectForKey:@"fullname"]];
            facemash_1.username = [data_facemash_1 objectForKey:@"username"];
            facemash_1.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [participantData objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.enabled = YES;
            facemash_2.name = [NSString stringWithFormat:@"%@", [data_facemash_2 objectForKey:@"fullname"]];
            facemash_2.username = [data_facemash_2 objectForKey:@"username"];
            facemash_2.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            facemash_3.photo.placeholderImage = nil;
            facemash_3.photo.imageURL = nil;
            facemash_3.enabled = NO;
            facemash_4.photo.placeholderImage = nil;
            facemash_4.photo.imageURL = nil;
            facemash_4.enabled = NO;
            facemash_5.photo.placeholderImage = nil;
            facemash_5.photo.imageURL = nil;
            facemash_5.enabled = NO;
            facemash_6.photo.placeholderImage = nil;
            facemash_6.photo.imageURL = nil;
            facemash_6.enabled = NO;
            facemash_7.photo.placeholderImage = nil;
            facemash_7.photo.imageURL = nil;
            facemash_7.enabled = NO;
            facemash_8.photo.placeholderImage = nil;
            facemash_8.photo.imageURL = nil;
            facemash_8.enabled = NO;
            facemash_9.photo.placeholderImage = nil;
            facemash_9.photo.imageURL = nil;
            facemash_9.enabled = NO;
            break;
        }
            
        case 3:
        {
            NSDictionary *data_facemash_1 = [participantData objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.enabled = YES;
            facemash_1.name = [NSString stringWithFormat:@"%@", [data_facemash_1 objectForKey:@"fullname"]];
            facemash_1.username = [data_facemash_1 objectForKey:@"username"];
            facemash_1.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [participantData objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.enabled = YES;
            facemash_2.name = [NSString stringWithFormat:@"%@", [data_facemash_2 objectForKey:@"fullname"]];
            facemash_2.username = [data_facemash_2 objectForKey:@"username"];
            facemash_2.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            
            NSDictionary *data_facemash_3 = [participantData objectAtIndex:2];
            NSString *profilePicPath_facemash_3 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_3 objectForKey:@"userid"], [data_facemash_3 objectForKey:@"pichash"]];
            facemash_3.enabled = YES;
            facemash_3.name = [NSString stringWithFormat:@"%@", [data_facemash_3 objectForKey:@"fullname"]];
            facemash_3.username = [data_facemash_3 objectForKey:@"username"];
            facemash_3.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_3.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_3];
            facemash_4.photo.placeholderImage = nil;
            facemash_4.photo.imageURL = nil;
            facemash_4.enabled = NO;
            facemash_5.photo.placeholderImage = nil;
            facemash_5.photo.imageURL = nil;
            facemash_5.enabled = NO;
            facemash_6.photo.placeholderImage = nil;
            facemash_6.photo.imageURL = nil;
            facemash_6.enabled = NO;
            facemash_7.photo.placeholderImage = nil;
            facemash_7.photo.imageURL = nil;
            facemash_7.enabled = NO;
            facemash_8.photo.placeholderImage = nil;
            facemash_8.photo.imageURL = nil;
            facemash_8.enabled = NO;
            facemash_9.photo.placeholderImage = nil;
            facemash_9.photo.imageURL = nil;
            facemash_9.enabled = NO;
            break;
        }
            
        case 4:
        {
            NSDictionary *data_facemash_1 = [participantData objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.enabled = YES;
            facemash_1.name = [NSString stringWithFormat:@"%@", [data_facemash_1 objectForKey:@"fullname"]];
            facemash_1.username = [data_facemash_1 objectForKey:@"username"];
            facemash_1.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [participantData objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.enabled = YES;
            facemash_2.name = [NSString stringWithFormat:@"%@", [data_facemash_2 objectForKey:@"fullname"]];
            facemash_2.username = [data_facemash_2 objectForKey:@"username"];
            facemash_2.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            
            NSDictionary *data_facemash_3 = [participantData objectAtIndex:2];
            NSString *profilePicPath_facemash_3 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_3 objectForKey:@"userid"], [data_facemash_3 objectForKey:@"pichash"]];
            facemash_3.enabled = YES;
            facemash_3.name = [NSString stringWithFormat:@"%@", [data_facemash_3 objectForKey:@"fullname"]];
            facemash_3.username = [data_facemash_3 objectForKey:@"username"];
            facemash_3.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_3.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_3];
            
            NSDictionary *data_facemash_4 = [participantData objectAtIndex:3];
            NSString *profilePicPath_facemash_4 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_4 objectForKey:@"userid"], [data_facemash_4 objectForKey:@"pichash"]];
            facemash_4.enabled = YES;
            facemash_4.name = [NSString stringWithFormat:@"%@", [data_facemash_4 objectForKey:@"fullname"]];
            facemash_4.username = [data_facemash_4 objectForKey:@"username"];
            facemash_4.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_4.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_4];
            facemash_5.photo.placeholderImage = nil;
            facemash_5.photo.imageURL = nil;
            facemash_5.enabled = NO;
            facemash_6.photo.placeholderImage = nil;
            facemash_6.photo.imageURL = nil;
            facemash_6.enabled = NO;
            facemash_7.photo.placeholderImage = nil;
            facemash_7.photo.imageURL = nil;
            facemash_7.enabled = NO;
            facemash_8.photo.placeholderImage = nil;
            facemash_8.photo.imageURL = nil;
            facemash_8.enabled = NO;
            facemash_9.photo.placeholderImage = nil;
            facemash_9.photo.imageURL = nil;
            facemash_9.enabled = NO;
            break;
        }
            
        case 5:
        {
            NSDictionary *data_facemash_1 = [participantData objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.enabled = YES;
            facemash_1.name = [NSString stringWithFormat:@"%@", [data_facemash_1 objectForKey:@"fullname"]];
            facemash_1.username = [data_facemash_1 objectForKey:@"username"];
            facemash_1.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [participantData objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.enabled = YES;
            facemash_2.name = [NSString stringWithFormat:@"%@", [data_facemash_2 objectForKey:@"fullname"]];
            facemash_2.username = [data_facemash_2 objectForKey:@"username"];
            facemash_2.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            
            NSDictionary *data_facemash_3 = [participantData objectAtIndex:2];
            NSString *profilePicPath_facemash_3 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_3 objectForKey:@"userid"], [data_facemash_3 objectForKey:@"pichash"]];
            facemash_3.enabled = YES;
            facemash_3.name = [NSString stringWithFormat:@"%@", [data_facemash_3 objectForKey:@"fullname"]];
            facemash_3.username = [data_facemash_3 objectForKey:@"username"];
            facemash_3.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_3.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_3];
            
            NSDictionary *data_facemash_4 = [participantData objectAtIndex:3];
            NSString *profilePicPath_facemash_4 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_4 objectForKey:@"userid"], [data_facemash_4 objectForKey:@"pichash"]];
            facemash_4.enabled = YES;
            facemash_4.name = [NSString stringWithFormat:@"%@", [data_facemash_4 objectForKey:@"fullname"]];
            facemash_4.username = [data_facemash_4 objectForKey:@"username"];
            facemash_4.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_4.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_4];
            
            NSDictionary *data_facemash_5 = [participantData objectAtIndex:4];
            NSString *profilePicPath_facemash_5 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_5 objectForKey:@"userid"], [data_facemash_5 objectForKey:@"pichash"]];
            facemash_5.enabled = YES;
            facemash_5.name = [NSString stringWithFormat:@"%@", [data_facemash_5 objectForKey:@"fullname"]];
            facemash_5.username = [data_facemash_5 objectForKey:@"username"];
            facemash_5.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_5.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_5];
            facemash_6.photo.placeholderImage = nil;
            facemash_6.photo.imageURL = nil;
            facemash_6.enabled = NO;
            facemash_7.photo.placeholderImage = nil;
            facemash_7.photo.imageURL = nil;
            facemash_7.enabled = NO;
            facemash_8.photo.placeholderImage = nil;
            facemash_8.photo.imageURL = nil;
            facemash_8.enabled = NO;
            facemash_9.photo.placeholderImage = nil;
            facemash_9.photo.imageURL = nil;
            facemash_9.enabled = NO;
            break;
        }
            
        case 6:
        {
            NSDictionary *data_facemash_1 = [participantData objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.enabled = YES;
            facemash_1.name = [NSString stringWithFormat:@"%@", [data_facemash_1 objectForKey:@"fullname"]];
            facemash_1.username = [data_facemash_1 objectForKey:@"username"];
            facemash_1.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [participantData objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.enabled = YES;
            facemash_2.name = [NSString stringWithFormat:@"%@", [data_facemash_2 objectForKey:@"fullname"]];
            facemash_2.username = [data_facemash_2 objectForKey:@"username"];
            facemash_2.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            
            NSDictionary *data_facemash_3 = [participantData objectAtIndex:2];
            NSString *profilePicPath_facemash_3 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_3 objectForKey:@"userid"], [data_facemash_3 objectForKey:@"pichash"]];
            facemash_3.enabled = YES;
            facemash_3.name = [NSString stringWithFormat:@"%@", [data_facemash_3 objectForKey:@"fullname"]];
            facemash_3.username = [data_facemash_3 objectForKey:@"username"];
            facemash_3.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_3.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_3];
            
            NSDictionary *data_facemash_4 = [participantData objectAtIndex:3];
            NSString *profilePicPath_facemash_4 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_4 objectForKey:@"userid"], [data_facemash_4 objectForKey:@"pichash"]];
            facemash_4.enabled = YES;
            facemash_4.name = [NSString stringWithFormat:@"%@", [data_facemash_4 objectForKey:@"fullname"]];
            facemash_4.username = [data_facemash_4 objectForKey:@"username"];
            facemash_4.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_4.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_4];
            
            NSDictionary *data_facemash_5 = [participantData objectAtIndex:4];
            NSString *profilePicPath_facemash_5 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_5 objectForKey:@"userid"], [data_facemash_5 objectForKey:@"pichash"]];
            facemash_5.enabled = YES;
            facemash_5.name = [NSString stringWithFormat:@"%@", [data_facemash_5 objectForKey:@"fullname"]];
            facemash_5.username = [data_facemash_5 objectForKey:@"username"];
            facemash_5.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_5.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_5];
            
            NSDictionary *data_facemash_6 = [participantData objectAtIndex:5];
            NSString *profilePicPath_facemash_6 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_6 objectForKey:@"userid"], [data_facemash_6 objectForKey:@"pichash"]];
            facemash_6.enabled = YES;
            facemash_6.name = [NSString stringWithFormat:@"%@", [data_facemash_6 objectForKey:@"fullname"]];
            facemash_6.username = [data_facemash_6 objectForKey:@"username"];
            facemash_6.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_6.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_6];
            facemash_7.photo.placeholderImage = nil;
            facemash_7.photo.imageURL = nil;
            facemash_7.enabled = NO;
            facemash_8.photo.placeholderImage = nil;
            facemash_8.photo.imageURL = nil;
            facemash_8.enabled = NO;
            facemash_9.photo.placeholderImage = nil;
            facemash_9.photo.imageURL = nil;
            facemash_9.enabled = NO;
            break;
        }
            
        case 7:
        {
            NSDictionary *data_facemash_1 = [participantData objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.enabled = YES;
            facemash_1.name = [NSString stringWithFormat:@"%@", [data_facemash_1 objectForKey:@"fullname"]];
            facemash_1.username = [data_facemash_1 objectForKey:@"username"];
            facemash_1.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [participantData objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.enabled = YES;
            facemash_2.name = [NSString stringWithFormat:@"%@", [data_facemash_2 objectForKey:@"fullname"]];
            facemash_2.username = [data_facemash_2 objectForKey:@"username"];
            facemash_2.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            
            NSDictionary *data_facemash_3 = [participantData objectAtIndex:2];
            NSString *profilePicPath_facemash_3 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_3 objectForKey:@"userid"], [data_facemash_3 objectForKey:@"pichash"]];
            facemash_3.enabled = YES;
            facemash_3.name = [NSString stringWithFormat:@"%@", [data_facemash_3 objectForKey:@"fullname"]];
            facemash_3.username = [data_facemash_3 objectForKey:@"username"];
            facemash_3.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_3.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_3];
            
            NSDictionary *data_facemash_4 = [participantData objectAtIndex:3];
            NSString *profilePicPath_facemash_4 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_4 objectForKey:@"userid"], [data_facemash_4 objectForKey:@"pichash"]];
            facemash_4.enabled = YES;
            facemash_4.name = [NSString stringWithFormat:@"%@", [data_facemash_4 objectForKey:@"fullname"]];
            facemash_4.username = [data_facemash_4 objectForKey:@"username"];
            facemash_4.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_4.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_4];
            
            NSDictionary *data_facemash_5 = [participantData objectAtIndex:4];
            NSString *profilePicPath_facemash_5 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_5 objectForKey:@"userid"], [data_facemash_5 objectForKey:@"pichash"]];
            facemash_5.enabled = YES;
            facemash_5.name = [NSString stringWithFormat:@"%@", [data_facemash_5 objectForKey:@"fullname"]];
            facemash_5.username = [data_facemash_5 objectForKey:@"username"];
            facemash_5.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_5.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_5];
            
            NSDictionary *data_facemash_6 = [participantData objectAtIndex:5];
            NSString *profilePicPath_facemash_6 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_6 objectForKey:@"userid"], [data_facemash_6 objectForKey:@"pichash"]];
            facemash_6.enabled = YES;
            facemash_6.name = [NSString stringWithFormat:@"%@", [data_facemash_6 objectForKey:@"fullname"]];
            facemash_6.username = [data_facemash_6 objectForKey:@"username"];
            facemash_6.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_6.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_6];
            
            NSDictionary *data_facemash_7 = [participantData objectAtIndex:6];
            NSString *profilePicPath_facemash_7 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_7 objectForKey:@"userid"], [data_facemash_7 objectForKey:@"pichash"]];
            facemash_7.enabled = YES;
            facemash_7.name = [NSString stringWithFormat:@"%@", [data_facemash_7 objectForKey:@"fullname"]];
            facemash_7.username = [data_facemash_7 objectForKey:@"username"];
            facemash_7.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_7.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_7];
            facemash_8.photo.placeholderImage = nil;
            facemash_8.photo.imageURL = nil;
            facemash_8.enabled = NO;
            facemash_9.photo.placeholderImage = nil;
            facemash_9.photo.imageURL = nil;
            facemash_9.enabled = NO;
            break;
        }
            
        case 8:
        {
            NSDictionary *data_facemash_1 = [participantData objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.enabled = YES;
            facemash_1.name = [NSString stringWithFormat:@"%@", [data_facemash_1 objectForKey:@"fullname"]];
            facemash_1.username = [data_facemash_1 objectForKey:@"username"];
            facemash_1.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [participantData objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.enabled = YES;
            facemash_2.name = [NSString stringWithFormat:@"%@", [data_facemash_2 objectForKey:@"fullname"]];
            facemash_2.username = [data_facemash_2 objectForKey:@"username"];
            facemash_2.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            
            NSDictionary *data_facemash_3 = [participantData objectAtIndex:2];
            NSString *profilePicPath_facemash_3 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_3 objectForKey:@"userid"], [data_facemash_3 objectForKey:@"pichash"]];
            facemash_3.enabled = YES;
            facemash_3.name = [NSString stringWithFormat:@"%@", [data_facemash_3 objectForKey:@"fullname"]];
            facemash_3.username = [data_facemash_3 objectForKey:@"username"];
            facemash_3.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_3.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_3];
            
            NSDictionary *data_facemash_4 = [participantData objectAtIndex:3];
            NSString *profilePicPath_facemash_4 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_4 objectForKey:@"userid"], [data_facemash_4 objectForKey:@"pichash"]];
            facemash_4.enabled = YES;
            facemash_4.name = [NSString stringWithFormat:@"%@", [data_facemash_4 objectForKey:@"fullname"]];
            facemash_4.username = [data_facemash_4 objectForKey:@"username"];
            facemash_4.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_4.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_4];
            
            NSDictionary *data_facemash_5 = [participantData objectAtIndex:4];
            NSString *profilePicPath_facemash_5 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_5 objectForKey:@"userid"], [data_facemash_5 objectForKey:@"pichash"]];
            facemash_5.enabled = YES;
            facemash_5.name = [NSString stringWithFormat:@"%@", [data_facemash_5 objectForKey:@"fullname"]];
            facemash_5.username = [data_facemash_5 objectForKey:@"username"];
            facemash_5.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_5.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_5];
            
            NSDictionary *data_facemash_6 = [participantData objectAtIndex:5];
            NSString *profilePicPath_facemash_6 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_6 objectForKey:@"userid"], [data_facemash_6 objectForKey:@"pichash"]];
            facemash_6.enabled = YES;
            facemash_6.name = [NSString stringWithFormat:@"%@", [data_facemash_6 objectForKey:@"fullname"]];
            facemash_6.username = [data_facemash_6 objectForKey:@"username"];
            facemash_6.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_6.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_6];
            
            NSDictionary *data_facemash_7 = [participantData objectAtIndex:6];
            NSString *profilePicPath_facemash_7 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_7 objectForKey:@"userid"], [data_facemash_7 objectForKey:@"pichash"]];
            facemash_7.enabled = YES;
            facemash_7.name = [NSString stringWithFormat:@"%@", [data_facemash_7 objectForKey:@"fullname"]];
            facemash_7.username = [data_facemash_7 objectForKey:@"username"];
            facemash_7.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_7.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_7];
            
            NSDictionary *data_facemash_8 = [participantData objectAtIndex:7];
            NSString *profilePicPath_facemash_8 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_8 objectForKey:@"userid"], [data_facemash_8 objectForKey:@"pichash"]];
            facemash_8.enabled = YES;
            facemash_8.name = [NSString stringWithFormat:@"%@", [data_facemash_8 objectForKey:@"fullname"]];
            facemash_8.username = [data_facemash_8 objectForKey:@"username"];
            facemash_8.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_8.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_8];
            facemash_9.photo.placeholderImage = nil;
            facemash_9.photo.imageURL = nil;
            facemash_9.enabled = NO;
            break;
        }
            
        case 9:
        {
            NSDictionary *data_facemash_1 = [participantData objectAtIndex:0];
            NSString *profilePicPath_facemash_1 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_1 objectForKey:@"userid"], [data_facemash_1 objectForKey:@"pichash"]];
            facemash_1.enabled = YES;
            facemash_1.name = [NSString stringWithFormat:@"%@", [data_facemash_1 objectForKey:@"fullname"]];
            facemash_1.username = [data_facemash_1 objectForKey:@"username"];
            facemash_1.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_1.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_1];
            
            NSDictionary *data_facemash_2 = [participantData objectAtIndex:1];
            NSString *profilePicPath_facemash_2 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_2 objectForKey:@"userid"], [data_facemash_2 objectForKey:@"pichash"]];
            facemash_2.enabled = YES;
            facemash_2.name = [NSString stringWithFormat:@"%@", [data_facemash_2 objectForKey:@"fullname"]];
            facemash_2.username = [data_facemash_2 objectForKey:@"username"];
            facemash_2.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_2.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_2];
            
            NSDictionary *data_facemash_3 = [participantData objectAtIndex:2];
            NSString *profilePicPath_facemash_3 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_3 objectForKey:@"userid"], [data_facemash_3 objectForKey:@"pichash"]];
            facemash_3.enabled = YES;
            facemash_3.name = [NSString stringWithFormat:@"%@", [data_facemash_3 objectForKey:@"fullname"]];
            facemash_3.username = [data_facemash_3 objectForKey:@"username"];
            facemash_3.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_3.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_3];
            
            NSDictionary *data_facemash_4 = [participantData objectAtIndex:3];
            NSString *profilePicPath_facemash_4 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_4 objectForKey:@"userid"], [data_facemash_4 objectForKey:@"pichash"]];
            facemash_4.enabled = YES;
            facemash_4.name = [NSString stringWithFormat:@"%@", [data_facemash_4 objectForKey:@"fullname"]];
            facemash_4.username = [data_facemash_4 objectForKey:@"username"];
            facemash_4.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_4.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_4];
            
            NSDictionary *data_facemash_5 = [participantData objectAtIndex:4];
            NSString *profilePicPath_facemash_5 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_5 objectForKey:@"userid"], [data_facemash_5 objectForKey:@"pichash"]];
            facemash_5.enabled = YES;
            facemash_5.name = [NSString stringWithFormat:@"%@", [data_facemash_5 objectForKey:@"fullname"]];
            facemash_5.username = [data_facemash_5 objectForKey:@"username"];
            facemash_5.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_5.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_5];
            
            NSDictionary *data_facemash_6 = [participantData objectAtIndex:5];
            NSString *profilePicPath_facemash_6 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_6 objectForKey:@"userid"], [data_facemash_6 objectForKey:@"pichash"]];
            facemash_6.enabled = YES;
            facemash_6.name = [NSString stringWithFormat:@"%@", [data_facemash_6 objectForKey:@"fullname"]];
            facemash_6.username = [data_facemash_6 objectForKey:@"username"];
            facemash_6.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_6.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_6];
            
            NSDictionary *data_facemash_7 = [participantData objectAtIndex:6];
            NSString *profilePicPath_facemash_7 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_7 objectForKey:@"userid"], [data_facemash_7 objectForKey:@"pichash"]];
            facemash_7.enabled = YES;
            facemash_7.name = [NSString stringWithFormat:@"%@", [data_facemash_7 objectForKey:@"fullname"]];
            facemash_7.username = [data_facemash_7 objectForKey:@"username"];
            facemash_7.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_7.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_7];
            
            NSDictionary *data_facemash_8 = [participantData objectAtIndex:7];
            NSString *profilePicPath_facemash_8 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_8 objectForKey:@"userid"], [data_facemash_8 objectForKey:@"pichash"]];
            facemash_8.enabled = YES;
            facemash_8.name = [NSString stringWithFormat:@"%@", [data_facemash_8 objectForKey:@"fullname"]];
            facemash_8.username = [data_facemash_8 objectForKey:@"username"];
            facemash_8.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_8.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_8];
            
            NSDictionary *data_facemash_9 = [participantData objectAtIndex:8];
            NSString *profilePicPath_facemash_9 = [NSString stringWithFormat:@"http://%@/userphotos/%@/profile/m_%@.jpg", SH_DOMAIN, [data_facemash_9 objectForKey:@"userid"], [data_facemash_9 objectForKey:@"pichash"]];
            facemash_9.enabled = YES;
            facemash_9.name = [NSString stringWithFormat:@"%@", [data_facemash_9 objectForKey:@"fullname"]];
            facemash_9.username = [data_facemash_9 objectForKey:@"username"];
            facemash_9.photo.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
            facemash_9.photo.imageURL = [NSURL URLWithString:profilePicPath_facemash_9];
            break;
        }
            
        default:
        {
            break; 
        }
    }
}

- (void)didSwipeView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)gotoTipAuthor:(id)sender
{
	MeViewController *profileView = [[MeViewController alloc] 
													initWithNibName:@"MeView" 
													bundle:[NSBundle mainBundle]];
    
    profileView.isCurrentUser = NO;
    profileView.profileOwnerUsername = tipUsername;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Tip" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:profileView animated:YES];
	[profileView release];
	profileView = nil;
}

- (void)gotoUser:(id)sender
{
    UIButton *gotoUserButton = (UIButton *)sender;
    FacemashPhoto *facemash = (FacemashPhoto *)sender;
	NSString *username = @"";
    
    // Facemash handlers.
    switch (gotoUserButton.tag) {
        case 1:
        {
            username = tipUsername;
            break; 
        }
            
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
            
        case 80:
        {
            NSDictionary *data_facemash_8 = [participantData objectAtIndex:7];
            username = [data_facemash_8 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
            
        case 90:
        {
            NSDictionary *data_facemash_9 = [participantData objectAtIndex:8];
            username = [data_facemash_9 objectForKey:@"username"];
            [facemash.menuController setMenuVisible:NO animated:YES];
            break;
        }
    }
    
	MeViewController *profileView = [[MeViewController alloc] 
                                     initWithNibName:@"MeView" 
                                     bundle:[NSBundle mainBundle]];		// Creating new detail view controller instance.
	
    profileView.isCurrentUser = NO;
    profileView.profileOwnerUsername = username;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Tip" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:profileView animated:YES];	// "Pushing the controller on the screen".
	[profileView release];                                                      // Releasing controller from the memory.
    profileView = nil;
    
}

- (void)gotoTopic:(id)sender
{
    TopicViewController *topicView = [[TopicViewController alloc] 
                                     initWithNibName:@"TopicView" 
                                     bundle:[NSBundle mainBundle]];
    
    topicView.topicName = topicContent;
    topicView.viewTopicid = topicid;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Tip" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:topicView animated:YES];
	[topicView release];
	topicView = nil;
}

#pragma mark UITableViewDataSource
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f
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
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    return cell;
}

/*#pragma mark - TTTAttributedLabelDelegate
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
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Tip" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        [self.navigationController pushViewController:profileView animated:YES];
        [profileView release];
        profileView = nil;
        
        return;
    }
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
    
	WebViewController *webView = [[WebViewController alloc] 
                                  initWithNibName:@"WebView" 
                                  bundle:[NSBundle mainBundle]];
    
    webView.hidesBottomBarWhenPushed = YES;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Tip" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	[self.navigationController pushViewController:webView animated:YES];
    webView.url = [url absoluteString];
    [webView setTitle:[url absoluteString]];
    [webView.browser loadRequest:theRequest];
	[webView release];
	webView = nil;
}*/

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super.view willMoveToSuperview:newSuperview];
	
	if (!newSuperview) {
		[userThmbnl cancelImageLoad];
        [facemash_1.photo cancelImageLoad];
        [facemash_2.photo cancelImageLoad];
        [facemash_3.photo cancelImageLoad];
        [facemash_4.photo cancelImageLoad];
        [facemash_5.photo cancelImageLoad];
        [facemash_6.photo cancelImageLoad];
        [facemash_7.photo cancelImageLoad];
        [facemash_8.photo cancelImageLoad];
        [facemash_9.photo cancelImageLoad];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    [sharingOptions release];
    [deletionOptions release];
    [genericOptions release];
    [scrollView release];
    [card release];
    [tipAuthorButton release];
    [userThmbnlOverlayView release];
	[userThmbnl release];
    [tipTxtLabelShadowCopy release];
	[tipTxtLabel release];
	[nameLabel release];
    [usernameLabel release];
    [topicButton release];
    [topicLabel release];
    [catIcon release];
    [categoryLabel release];
    [geniusIcon release];
    [clockIcon release];
	[timestampLabel release];
    [pane_markUsefulButton release];
    [usefulnessMeter release];
    [usefulnessMeterIconView release];
    [facemashStripBg release];
    [facemash_1 release];
    [facemash_2 release];
    [facemash_3 release];
    [facemash_4 release];
    [facemash_5 release];
    [facemash_6 release];
    [facemash_7 release];
    [facemash_8 release];
    [facemash_9 release];
    [super dealloc];
}


@end
