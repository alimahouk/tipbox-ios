#import "ReportViewController.h"
#import "TipboxAppDelegate.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation ReportViewController

@synthesize cancelButton, navBarTitle, reportTableView, tableContents;
@synthesize sortedKeys, lastIndexPath, reportType, objectid;

#pragma mark setTitle override
- (void)setTitle:(NSString *)title
{
    // NOTE: slightly modded setTitle. We're referring to an IBOutlet here (modal view controller causes fuckage).
    UILabel *titleView = (UILabel *)self.navBarTitle.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        titleView.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        titleView.shadowOffset = CGSizeMake(0, 1);
        
        titleView.textColor = [UIColor colorWithRed:49.0/255.0 green:49.0/255.0 blue:49.0/255.0 alpha:1.0]; // Change to desired color.
        
        self.navBarTitle.titleView = titleView;
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

- (IBAction)dismissReportWindow:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sendReport:(id)sender
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    reportSubmitButton.enabled = NO;
    
    NSString *target_name = @"";
    NSString *target_idType = @"";
    
    if ([reportType isEqualToString:@"user"]) {
        target_name = @"reportuser";
        target_idType = @"userid";
    } else if ([reportType isEqualToString:@"tip"]) {
        target_name = @"reporttip";
        target_idType = @"tipid";
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/tipbox/api/%@", SH_DOMAIN, target_name]];
    
    [appDelegate.strobeLight activateStrobeLight];
    dataRequest = [[ASIFormDataRequest requestWithURL:url] retain];
    [dataRequest setPostValue:appDelegate.SHToken forKey:@"token"];
    [dataRequest setPostValue:[NSNumber numberWithInt:self.lastIndexPath.row + 1] forKey:@"reason"];
    [dataRequest setPostValue:[NSNumber numberWithInt:objectid] forKey:target_idType];
    [dataRequest setCompletionBlock:^{
        NSError *jsonError;
        responseData = [NSJSONSerialization JSONObjectWithData:[dataRequest.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&jsonError];
        NSLog(@"%@", dataRequest.responseString);
        if ([[responseData objectForKey:@"error"] intValue] == 0) {
            reportTableView.hidden = YES;
            gratitude.hidden = NO;
            
            cancelButton.style = UIBarButtonItemStyleDone;
            cancelButton.title = @"Done";
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
        
        reportSubmitButton.enabled = YES;
        [appDelegate.strobeLight negativeStrobeLight];
        
        [HUD show:YES];
        [HUD hide:YES afterDelay:3];
        
        NSError *error = [dataRequest error];
        NSLog(@"%@", error);
    }];
    [dataRequest startAsynchronous];
    
}

- (void)viewDidLoad
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showNavbarShadowAnimated:YES];
    
    reportSubmitButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    [reportSubmitButton setTitle:@"Submit Report" forState:UIControlStateNormal];
    [reportSubmitButton addTarget:self action:@selector(sendReport:) forControlEvents:UIControlEventTouchUpInside];
    reportSubmitButton.frame = CGRectMake(10, 15, 300, 40);
    reportSubmitButton.hidden = YES;
    
    gratitude = [[UILabel alloc] initWithFrame:CGRectMake(20, 64, 280, 50)];
    gratitude.backgroundColor = [UIColor clearColor];
    gratitude.textColor = [UIColor colorWithRed:145.0/255.0 green:145.0/255.0 blue:145.0/255.0 alpha:1.0];
    gratitude.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    gratitude.numberOfLines = 0;
    gratitude.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
    gratitude.text = @"Thanks! We'll look into this and take the appropriate measures.";
    gratitude.hidden = YES;
    
    NSArray *arrTemp1;
    
    if ([reportType isEqualToString:@"user"]) {
        [self setTitle:@"Report User"];
        
        arrTemp1 = [[NSArray alloc]
                    initWithObjects:@"Spam", @"Fake account", @"Inappropriate photo", @"Copyright infringement", @"Pornographic content", nil];
        
    } else if ([reportType isEqualToString:@"tip"]) {
        [self setTitle:@"Report Tip"];
        
        arrTemp1 = [[NSArray alloc]
                    initWithObjects:@"Spam/Not a tip", @"Offensive/Racism", @"Contains harmful info", @"Copyright infringement", @"Pornographic content", nil];
    }
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    reportTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
    
	NSDictionary *temp =[[NSDictionary alloc]
                         initWithObjectsAndKeys:arrTemp1, @"1", nil];
    
	self.tableContents = temp;
	self.sortedKeys =[[self.tableContents allKeys]
                 sortedArrayUsingSelector:@selector(compare:)];
    
    [self.view addSubview:gratitude];
    
	[arrTemp1 release];
    [temp release];
    [super viewDidLoad];
}

#pragma mark Table Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sortedKeys count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	NSArray *listData =[self.tableContents objectForKey:
                        [self.sortedKeys objectAtIndex:section]];
	return [listData count];
}

- (CGFloat)tableView:(UITableView *)table heightForHeaderInSection:(NSInteger)section
{
    return 100.0;
}

- (CGFloat)tableView:(UITableView *)table heightForFooterInSection:(NSInteger)section
{
    return 55.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 44.0)];
        
        // Add the label
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 90)];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.opaque = NO;
        headerLabel.text = @"This is a serious report, and should not be taken lightly. All reports are stricly confidential.";
        headerLabel.textColor = [UIColor colorWithRed:76.0/255.0 green:86.0/255.0 blue:108.0/255.0 alpha:1.0];
        headerLabel.font = [UIFont systemFontOfSize:16];
        headerLabel.shadowColor = [UIColor whiteColor];
        headerLabel.shadowOffset = CGSizeMake(0, 1);
        headerLabel.numberOfLines = 0;
        [headerView addSubview:headerLabel];
        
        [headerLabel release];
        
        return [headerView autorelease];
    } else {
        return nil; 
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 44.0)];
    
    // Add the button
    [footerView addSubview:reportSubmitButton];
    
    return [footerView autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"SimpleTableIdentifier";
    
	NSArray *listData =[self.tableContents objectForKey:
                        [self.sortedKeys objectAtIndex:[indexPath section]]];
    
	UITableViewCell *cell = [tableView
                              dequeueReusableCellWithIdentifier:CellIdentifier];
    
    self.lastIndexPath = indexPath;
    
	if ( cell == nil )
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
    
    cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.text = [listData objectAtIndex:[indexPath row]];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int newRow = [indexPath row];
    int oldRow = [self.lastIndexPath row];
    
    if (newRow != oldRow) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath]; 
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    self.lastIndexPath = indexPath; 
    reportSubmitButton.hidden = NO;
    [reportTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Customizations when the view appears/disappears
- (void)viewWillAppear:(BOOL)animated
{
    TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate navbarShadowMode_navbar];
    [appDelegate tabbarShadowMode_nobar];
    [appDelegate showNavbarShadowAnimated:YES];
    [appDelegate showNavbarShadowAnimated:YES];
    [appDelegate showTabbarShadowAnimated:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count - 2] == self) { // View is disappearing because a new view controller was pushed onto the stack
        
        
    } else if ([viewControllers indexOfObject:self] == NSNotFound) { // View is disappearing because it was popped from the stack
                                                                     // We unhide the navbar shadow, and deactivate the strobe light (in case it was activated).
        TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.strobeLight deactivateStrobeLight];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc
{
    [cancelButton release];
    [navBarTitle release];
    [reportTableView release];
    [tableContents release];
	[sortedKeys release];
    [reportSubmitButton release];
    [gratitude release];
    [super dealloc];
}

@end
