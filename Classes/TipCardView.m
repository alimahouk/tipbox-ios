#import <QuartzCore/QuartzCore.h>
#import "TipCardView.h"
#import "TipboxAppDelegate.h"

#define CELL_CONTENT_WIDTH 320
#define CELL_CONTENT_MARGIN 5
#define CELL_COLLAPSED_HEIGHT 87
#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation TipCardView

@synthesize rowNumber, tipid, tipUserid, fullname, username, userPicHash;
@synthesize content, catid, subcat, parentCat, topicid, topicContent, timestamp, timestamp_short, actualTime;
@synthesize cardBgTexture, tipTxtLabel, nameLabel, usefulCount, usernameLabel, timestampLabel;
@synthesize userThmbnl, markUsefulButton, participantData, genius, marked, followsTopic;
@synthesize isSelected, card, topicStrip, topicLabel, tipOptionsPane, usefulnessMeter, pane_gotoTipButton;
@synthesize pane_gotoUserButton, pane_shareButton, pane_tipOptionsButton, pane_deleteButton;
@synthesize facemash_1, facemash_2, facemash_3, facemash_4, facemash_5, facemash_6, facemash_7;

- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
        self.opaque = YES;
		self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
        
        TipboxAppDelegate *appDelegate = (TipboxAppDelegate *)[[UIApplication sharedApplication] delegate];
        global = appDelegate.global;
        
        card = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]] ;
        card.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
        card.opaque = YES;
        card.userInteractionEnabled = YES;
        
        cardBgTexture = [CALayer layer];
        cardBgTexture.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]].CGColor;
        cardBgTexture.opaque = YES;
        [cardBgTexture setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)]; // Sets the co-ordinates right.
        
		userThmbnlOverlay = [[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:3.0];
		userThmbnlOverlayView = [[UIImageView alloc] initWithImage:userThmbnlOverlay];
        userThmbnlOverlayView.opaque = YES;
        userThmbnlOverlayView.frame = CGRectMake(9, 10, 36, 36);
		
		userThmbnl = [[EGOImageView alloc] initWithFrame:CGRectMake(12, 12, 30, 30)];
		userThmbnl.placeholderImage = [UIImage imageNamed:@"user_placeholder_default.png"];
        userThmbnl.opaque = YES;
        
		nameLabel = [[UILabel alloc] init];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
		nameLabel.numberOfLines = 1;
		nameLabel.minimumFontSize = 8.;
        nameLabel.adjustsFontSizeToFitWidth = YES;
		nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
        nameLabel.opaque = YES;
        
        usernameLabel = [[LPLabel alloc] init];
		usernameLabel.backgroundColor = [UIColor clearColor];
		usernameLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
		usernameLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		usernameLabel.numberOfLines = 1;
		usernameLabel.minimumFontSize = 8.;
        usernameLabel.adjustsFontSizeToFitWidth = YES;
		usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
        usernameLabel.opaque = YES;
        
        geniusIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genius_star.png"]];
        geniusIcon.opaque = YES;
        geniusIcon.hidden = YES;
        genius = NO;
        
        clockIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock_grey.png"]];
        clockIcon.opaque = YES;
		
		timestampLabel = [[LPLabel alloc] initWithFrame:CGRectMake(198, 18, 100, 20)];
        timestampLabel.backgroundColor = [UIColor clearColor];
		timestampLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
		timestampLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		timestampLabel.numberOfLines = 1;
		timestampLabel.minimumFontSize = 8.;
        timestampLabel.adjustsFontSizeToFitWidth = YES;
		timestampLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
        timestampLabel.textAlignment = UITextAlignmentRight;
        timestampLabel.opaque = YES;
		
        detailsSeparator = [CALayer layer];
        detailsSeparator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"solid_line_red.png"]].CGColor;
        detailsSeparator.frame = CGRectMake(10, 53, 288, 2);
        detailsSeparator.opaque = YES;
        [detailsSeparator setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
        
		tipTxtLabel = [[UILabel alloc] init];
		tipTxtLabel.backgroundColor = [UIColor clearColor];
		tipTxtLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
		tipTxtLabel.numberOfLines = 0;
		tipTxtLabel.lineBreakMode = UILineBreakModeWordWrap;
        tipTxtLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE];
        tipTxtLabel.opaque = YES;
        
        markUsefulButton = [[ToggleButton alloc] init];
        [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button.png"] forState:UIControlStateNormal];
        [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button_pressed.png"] forState:UIControlStateHighlighted];
        markUsefulButton.showsTouchWhenHighlighted = YES;
        markUsefulButton.opaque = YES;
        marked = NO;
        
        stretchyMarkUsefulButton = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"feed_useful_button_marked.png"] stretchableImageWithLeftCapWidth:26.0 topCapHeight:0.0]];
        stretchyMarkUsefulButton.opaque = YES;
        stretchyMarkUsefulButton.userInteractionEnabled = YES;
        stretchyMarkUsefulButton.hidden = YES;
        
        stretchyMarkUsefulButtonBulb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feed_bulb_marked.png"]];
        stretchyMarkUsefulButtonBulb.opaque = YES;
        stretchyMarkUsefulButtonBulb.frame = CGRectMake(14, 14, 22, 22);
        
        stretchyMarkUsefulButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 14, 70, 22)];
		stretchyMarkUsefulButtonLabel.backgroundColor = [UIColor clearColor];
		stretchyMarkUsefulButtonLabel.textColor = [UIColor whiteColor];
		stretchyMarkUsefulButtonLabel.shadowColor = [UIColor colorWithRed:25.0/255.0 green:93.0/255.0 blue:190.0/255.0 alpha:1.0];
        stretchyMarkUsefulButtonLabel.shadowOffset = CGSizeMake(0, 1);
		stretchyMarkUsefulButtonLabel.numberOfLines = 1;
		stretchyMarkUsefulButtonLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:SECONDARY_FONT_SIZE];
        stretchyMarkUsefulButtonLabel.opaque = YES;
        stretchyMarkUsefulButtonLabel.alpha = 0.0;
        stretchyMarkUsefulButtonLabel.hidden = YES;
        stretchyMarkUsefulButtonLabel.text = @"Useful!";
        
        topicStrip = [CALayer layer];
        topicStrip.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor;
        topicStrip.borderWidth = 0.7;
        topicStrip.borderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
        topicStrip.opaque = YES;
        
        topicStripIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_bar_topics.png"]];
        topicStripIcon.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0];
        topicStripIcon.frame = CGRectMake(7, 1, 30, 30);
        topicStripIcon.opaque = YES;
        
        topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 7, 200, 19)];
		topicLabel.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0];
		topicLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
		topicLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        topicLabel.shadowOffset = CGSizeMake(0, 1);
		topicLabel.numberOfLines = 1;
		topicLabel.minimumFontSize = 8.;
        topicLabel.adjustsFontSizeToFitWidth = YES;
		topicLabel.font = [UIFont fontWithName:@"Georgia" size:MIN_MAIN_FONT_SIZE];
        topicLabel.opaque = YES;
        
        catIcon = [[UIImageView alloc] initWithFrame:CGRectMake(275, 8, 20, 20)];
        catIcon.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0];
        catIcon.opaque = YES;
        
        tipOptionsPane = [[UIView alloc] init];
        tipOptionsPane.opaque = YES;
        tipOptionsPane.hidden = YES;
        
        tipOptionsLinen = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feed_tip_options.png"]];
        tipOptionsLinen.frame = CGRectMake(0, 0, 300, 139);
        tipOptionsLinen.opaque = YES;
        
        tipOptionsStripFrame = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_square_shadow_bg.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0]];
        tipOptionsStripFrame.frame = CGRectMake(11, 11, 278, 118);
        tipOptionsStripFrame.opaque = YES;
        tipOptionsStripFrame.userInteractionEnabled = YES;
        
        tipOptionsStripBg = [CALayer layer];
        tipOptionsStripBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]].CGColor;
        tipOptionsStripBg.frame = CGRectMake(5, 5, 268, 108);
        tipOptionsStripBg.opaque = YES;
        
        usefulnessMeterIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small_grey_bulb.png"]];
        usefulnessMeterIconView.frame = CGRectMake(5, 5, 14, 14);
        usefulnessMeterIconView.opaque = YES;
        
        usefulnessMeter = [[LPLabel alloc] initWithFrame:CGRectMake(20, 6, 203, 12)];
        usefulnessMeter.backgroundColor = [UIColor clearColor];
		usefulnessMeter.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
		usefulnessMeter.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		usefulnessMeter.numberOfLines = 1;
		usefulnessMeter.minimumFontSize = 8.;
        usefulnessMeter.adjustsFontSizeToFitWidth = YES;
		usefulnessMeter.font = [UIFont fontWithName:@"HelveticaNeue" size:MIN_SECONDARY_FONT_SIZE];
        usefulnessMeter.opaque = YES;
        
        tipOptionsSeparator = [CALayer layer];
        tipOptionsSeparator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_red.png"]].CGColor;
        tipOptionsSeparator.frame = CGRectMake(7, 20, 213, 2);
        tipOptionsSeparator.opaque = YES;
        [tipOptionsSeparator setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
        
        facemash_1 = [[FacemashPhoto alloc] init];
        facemash_1.tag = 10;
        facemash_1.photo.imageURL = nil;
        facemash_1.enabled = NO;
        facemash_2 = [[FacemashPhoto alloc] init];
        facemash_2.tag = 20;
        facemash_2.photo.imageURL = nil;
        facemash_2.enabled = NO;
        facemash_3 = [[FacemashPhoto alloc] init];
        facemash_3.tag = 30;
        facemash_3.photo.imageURL = nil;
        facemash_3.enabled = NO;
        facemash_4 = [[FacemashPhoto alloc] init];
        facemash_4.tag = 40;
        facemash_4.photo.imageURL = nil;
        facemash_4.enabled = NO;
        facemash_5 = [[FacemashPhoto alloc] init];
        facemash_5.tag = 50;
        facemash_5.photo.imageURL = nil;
        facemash_5.enabled = NO;
        facemash_6 = [[FacemashPhoto alloc] init];
        facemash_6.tag = 60;
        facemash_6.photo.imageURL = nil;
        facemash_6.enabled = NO;
        facemash_7 = [[FacemashPhoto alloc] init];
        facemash_7.tag = 70;
        facemash_7.photo.imageURL = nil;
        facemash_7.enabled = NO;
        
        pane_gotoTipButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        pane_gotoTipButton.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:0.9];
        [pane_gotoTipButton setImage:[UIImage imageNamed:@"feed_chevron_grey.png"] forState:UIControlStateNormal];
        [pane_gotoTipButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
        pane_gotoTipButton.adjustsImageWhenHighlighted = NO;
        pane_gotoTipButton.layer.borderWidth = 0.7;
        pane_gotoTipButton.layer.borderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
        pane_gotoTipButton.opaque = YES;
        
        pane_gotoUserButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        pane_gotoUserButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        [pane_gotoUserButton setImage:[UIImage imageNamed:@"feed_person.png"] forState:UIControlStateNormal];
        [pane_gotoUserButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
        pane_gotoUserButton.adjustsImageWhenHighlighted = NO;
        pane_gotoUserButton.layer.borderWidth = 0.7;
        pane_gotoUserButton.layer.borderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
        pane_gotoUserButton.opaque = YES;
        
        pane_tipOptionsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        pane_tipOptionsButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        [pane_tipOptionsButton setImage:[UIImage imageNamed:@"feed_gear.png"] forState:UIControlStateNormal];
        [pane_tipOptionsButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
        pane_tipOptionsButton.adjustsImageWhenHighlighted = NO;
        pane_tipOptionsButton.layer.borderWidth = 0.7;
        pane_tipOptionsButton.layer.borderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
        pane_tipOptionsButton.opaque = YES;
        
        pane_shareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        pane_shareButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        [pane_shareButton setImage:[UIImage imageNamed:@"feed_action.png"] forState:UIControlStateNormal];
        [pane_shareButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
        pane_shareButton.adjustsImageWhenHighlighted = NO;
        pane_shareButton.layer.borderWidth = 0.7;
        pane_shareButton.layer.borderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
        pane_shareButton.opaque = YES;
        
        pane_deleteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        pane_deleteButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        [pane_deleteButton setImage:[UIImage imageNamed:@"feed_delete.png"] forState:UIControlStateNormal];
        [pane_deleteButton setBackgroundImage:[[UIImage imageNamed:@"feed_button_grey_bg.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
        pane_deleteButton.adjustsImageWhenHighlighted = NO;
        pane_deleteButton.layer.borderWidth = 0.7;
        pane_deleteButton.layer.borderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
        pane_deleteButton.opaque = YES;
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
    [card.layer addSublayer:cardBgTexture];
    [card addSubview:userThmbnlOverlayView];
    [card addSubview:userThmbnl];
    [card addSubview:nameLabel];
    [card addSubview:usernameLabel];
    [card addSubview:geniusIcon];
    [card addSubview:timestampLabel];
    [card addSubview:clockIcon];
    [card.layer addSublayer:detailsSeparator];
    [card addSubview:tipTxtLabel];
    [card addSubview:markUsefulButton];
    [card addSubview:stretchyMarkUsefulButton];
    [card addSubview:tipOptionsPane];
    [card.layer addSublayer:topicStrip];
    [stretchyMarkUsefulButton addSubview:stretchyMarkUsefulButtonBulb];
    [stretchyMarkUsefulButton addSubview:stretchyMarkUsefulButtonLabel];
    [tipOptionsPane addSubview:tipOptionsLinen];
    [tipOptionsPane addSubview:tipOptionsStripFrame];
    [tipOptionsStripFrame.layer addSublayer:tipOptionsStripBg];
    [tipOptionsStripFrame addSubview:facemash_1];
    [tipOptionsStripFrame addSubview:facemash_2];
    [tipOptionsStripFrame addSubview:facemash_3];
    [tipOptionsStripFrame addSubview:facemash_4];
    [tipOptionsStripFrame addSubview:facemash_5];
    [tipOptionsStripFrame addSubview:facemash_6];
    [tipOptionsStripFrame addSubview:facemash_7];
    [tipOptionsStripFrame addSubview:pane_gotoUserButton];
    [tipOptionsStripFrame addSubview:pane_shareButton];
    [tipOptionsStripFrame addSubview:pane_tipOptionsButton];
    [tipOptionsStripFrame addSubview:pane_deleteButton];
    [tipOptionsStripFrame addSubview:pane_gotoTipButton];
    [tipOptionsStripBg addSublayer:usefulnessMeterIconView.layer];
    [tipOptionsStripBg addSublayer:usefulnessMeter.layer];
    [tipOptionsStripBg addSublayer:tipOptionsSeparator];
    [topicStrip addSublayer:topicStripIcon.layer];
    [topicStrip addSublayer:topicLabel.layer];
    [topicStrip addSublayer:catIcon.layer];
    
    [self addSubview:card];
}

- (void)populateViewWithContent:(NSMutableDictionary *)tip
{
    self.tag = rowNumber; // Special identifier.
	
    tipid = [[tip objectForKey:@"id"] intValue];
    tipUserid = [[tip objectForKey:@"userid"] intValue];
    fullname = [tip objectForKey:@"fullname"];
	username = [tip objectForKey:@"username"];
    userPicHash = [tip objectForKey:@"pichash"];
    catid = [[tip objectForKey:@"catid"] intValue];
    subcat = [tip objectForKey:@"subcat"];
    parentCat = [tip objectForKey:@"parentcat"];
	content = [tip objectForKey:@"content"];
    topicid = [[tip objectForKey:@"topicid"] intValue];
    topicContent = [tip objectForKey:@"topicContent"];
    followsTopic = [[tip objectForKey:@"followsTopic"] boolValue];
	timestamp = [tip objectForKey:@"relativeTime"];
    timestamp_short = [tip objectForKey:@"relativeTimeShort"];
    actualTime = [tip objectForKey:@"time"];
    //location_lat = [[tip objectForKey:@"location_lat"] floatValue];
    //location_long = [[tip objectForKey:@"location_long"] floatValue];
    usefulCount = [[tip objectForKey:@"likerCount"] intValue];
    participantData = [[tip objectForKey:@"likers"] mutableCopy];
    NSString *profilePicPath = [NSString stringWithFormat:@"http://%@/userphotos/%d/profile/m_%@.jpg", SH_DOMAIN, tipUserid, userPicHash];
	userThmbnl.imageURL = [NSURL URLWithString:profilePicPath];
    marked = [[tip objectForKey:@"marked"] boolValue];
    
    if (![[NSNull null] isEqual:[tip objectForKey:@"genius"]]) {
        genius = [[tip objectForKey:@"genius"] intValue];
    } else {
        genius = -1;
    }
    
    // Genius.
    if (genius == tipUserid) {
        geniusIcon.hidden = NO;
    } else {
        geniusIcon.hidden = YES;
    }
    
    // Marked useful.
    if (marked) {
        [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button_activated.png"] forState:UIControlStateNormal];
        markUsefulButton.activated = YES;
    } else {
        [markUsefulButton setBackgroundImage:[UIImage imageNamed:@"feed_useful_button.png"] forState:UIControlStateNormal];
        markUsefulButton.activated = NO;
    }
    
    // Useful count.
    [self redisplayUsefulnessData];
    
    // Categories, subcategories.
    if ([parentCat isEqualToString:@"thing"]) {
        catIcon.image = [UIImage imageNamed:@"feed_category_thing.png"];
    } else if ([parentCat isEqualToString:@"place"]) {
        catIcon.image = [UIImage imageNamed:@"feed_category_place.png"];
    } else {
        catIcon.image = [UIImage imageNamed:@"feed_category_idea.png"];
    }
    
    nameLabel.text = fullname;
    usernameLabel.text = [NSString stringWithFormat:@"@%@", username];
	timestampLabel.text = timestamp_short;
    topicLabel.text = topicContent;
    tipTxtLabel.text = content;
    
    /*NSRegularExpression *urlRegex = [NSRegularExpression 
                                     regularExpressionWithPattern:@"(?i)\\b((https?|ftp):\\/\\/www\\d{0,3}[.])" 
                                     options:0 
                                     error:NULL];
    NSArray *allLinks = [urlRegex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    
    for (NSTextCheckingResult *urlMatch in allLinks) {
        tipTxt.text = [tipTxt.text stringByReplacingOccurrencesOfString:[tipTxt.text substringWithRange:urlMatch.range]
                                                      withString:@""];
    }*/
	
    CGSize tipTxtSize;
	CGSize nameSize = [fullname sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(240, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    CGSize usernameSize = [usernameLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(240, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	CGSize timestampSize = [timestamp_short sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(100, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    // Customizations if the current user owns the current tip.
    if ([[global readProperty:@"userid"] intValue] == tipUserid) {
        markUsefulButton.hidden = YES;
        pane_deleteButton.enabled = YES;
        
        // Since the mark button is hidden, we might as well use up that otherwise wasted space. ;)
        tipTxtSize = [tipTxtLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(288, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    } else {
        markUsefulButton.hidden = NO;
        pane_deleteButton.enabled = NO;
        
        tipTxtSize = [tipTxtLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MIN_MAIN_FONT_SIZE] constrainedToSize:CGSizeMake(253, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    }
	
    // Disable implicit animations.
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
	nameLabel.frame = CGRectMake(51, 10, nameSize.width, 18);
    usernameLabel.frame = CGRectMake(51, 30, usernameSize.width, 17);
    geniusIcon.frame = CGRectMake(nameSize.width + 53, 11, 16, 16);
    clockIcon.frame = CGRectMake(279 - timestampSize.width, 19, 17, 17); // The clock icon should be exactly before the time + a bit of padding.
    markUsefulButton.frame = CGRectMake(258, 41 + (tipTxtSize.height / 2), 50, 50); // We use half of the height of the icon (32px in this case) 'cuz we wanna center the button with respect to the height of the tip text.
    stretchyMarkUsefulButton.frame = CGRectMake(258, 41 + (tipTxtSize.height / 2), 50, 50);
    tipTxtLabel.frame = CGRectMake(11, 65, tipTxtSize.width, tipTxtSize.height);
    tipOptionsPane.frame = CGRectMake(4, tipTxtSize.height + 77, 300, 139);
    facemash_1.frame = CGRectMake(11, 31, 25, 26);
    facemash_2.frame = CGRectMake(facemash_1.frame.size.width + 16, 31, 25, 26);
    facemash_3.frame = CGRectMake(facemash_2.frame.size.width * 2 + 22, 31, 25, 26);
    facemash_4.frame = CGRectMake(facemash_3.frame.size.width * 3 + 28, 31, 25, 26);
    facemash_5.frame = CGRectMake(facemash_4.frame.size.width * 4 + 35, 31, 25, 26);
    facemash_6.frame = CGRectMake(facemash_4.frame.size.width * 5 + 42, 31, 25, 26);
    facemash_7.frame = CGRectMake(facemash_6.frame.size.width * 6 + 49, 31, 25, 26);
    pane_gotoTipButton.frame = CGRectMake(233, 4, 41, 110);
    pane_gotoUserButton.frame = CGRectMake(4, 64, 58, 50);
    pane_tipOptionsButton.frame = CGRectMake(61, 64, 58, 50);
    pane_shareButton.frame = CGRectMake(118, 64, 58, 50);
    pane_deleteButton.frame = CGRectMake(175, 64, 59, 50);
    cardBgTexture.frame = CGRectMake(4, 4, 300, tipTxtSize.height + 106);
    
    if (isSelected) {
        tipOptionsPane.hidden = NO;
        
        topicStrip.frame = CGRectMake(4, tipTxtSize.height + 216, 300, 33);
        card.frame = CGRectMake(6, 10, 308, tipTxtSize.height + 253);
    } else {
        tipOptionsPane.hidden = YES;
        
        topicStrip.frame = CGRectMake(4, tipTxtSize.height + 164 - CELL_COLLAPSED_HEIGHT, 300, 33);
        card.frame = CGRectMake(6, 10, 308, tipTxtSize.height + 201 - CELL_COLLAPSED_HEIGHT);
    }
    
    self.frame = CGRectMake(0, 0, 320, card.frame.size.height + 10);
    
    [CATransaction commit];
}

- (void)redisplayUsefulnessData
{
    if (usefulCount > 1) {
        usefulnessMeter.text = [NSString stringWithFormat:@"%d people found this useful.", usefulCount];
        
        if (marked) {
            if (usefulCount == 2) {
                usefulnessMeter.text = [NSString stringWithFormat:@"You & 1 other person found this useful."];
            } else if (usefulCount > 2) {
                usefulnessMeter.text = [NSString stringWithFormat:@"You & %d people found this useful.", usefulCount - 1];
            }
            
            if ([participantData count] < 8) {
                
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
            }
        }
    } else if (usefulCount == 1) {
        usefulnessMeter.text = [NSString stringWithFormat:@"1 person found this useful."];
        
        if (marked) {
            usefulnessMeter.text = [NSString stringWithFormat:@"You found this useful."];
            
            if ([participantData count] < 8) {
                
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
            }
        }
    } else if (usefulCount == 0) {
        usefulnessMeter.text = [NSString stringWithFormat:@"Nobody found this useful yet."];
        
        [participantData removeAllObjects];
    }
    
    [self setUpFacemash];
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
            break;
        }
        case 7:
        case 8:
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
            break;
        }
            
        default:
        {
            break;
        }
    }
}

- (void)collapseCell
{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [topicStrip setFrame:CGRectMake(topicStrip.frame.origin.x, topicStrip.frame.origin.y, topicStrip.frame.size.width, topicStrip.frame.size.height + 5)]; // To hide any bleeding edges.
    [CATransaction commit];
    
    if (isSelected) { // Collapse the cell.
        card.layer.masksToBounds = YES;
        
        // The collapsing animation has a slight bounce effect.
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [CATransaction setAnimationDuration:0.15];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            [topicStrip setFrame:CGRectMake(topicStrip.frame.origin.x, topicStrip.frame.origin.y - CELL_COLLAPSED_HEIGHT - 62, topicStrip.frame.size.width, topicStrip.frame.size.height)];
            [card setFrame:CGRectMake(card.frame.origin.x, card.frame.origin.y, card.frame.size.width, card.frame.size.height - CELL_COLLAPSED_HEIGHT - 62)];
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height - CELL_COLLAPSED_HEIGHT - 62)];
            [CATransaction commit];
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [CATransaction setAnimationDuration:0.2];
                [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
                [topicStrip setFrame:CGRectMake(topicStrip.frame.origin.x, topicStrip.frame.origin.y + 10, topicStrip.frame.size.width, topicStrip.frame.size.height)];
                [card setFrame:CGRectMake(card.frame.origin.x, card.frame.origin.y, card.frame.size.width, card.frame.size.height + 10)];
                [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + 10)];
                [CATransaction commit];
            } completion:^(BOOL finished){
                card.layer.masksToBounds = NO;
                tipOptionsPane.hidden = YES;
                
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                [topicStrip setFrame:CGRectMake(topicStrip.frame.origin.x, topicStrip.frame.origin.y, topicStrip.frame.size.width, topicStrip.frame.size.height - 5)];
                [CATransaction commit];
            }];
        }];
    } else { // Expand the cell.
        [self setUpFacemash];
        card.layer.masksToBounds = YES;
        tipOptionsPane.hidden = NO;
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [CATransaction setAnimationDuration:0.2];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            [topicStrip setFrame:CGRectMake(topicStrip.frame.origin.x, topicStrip.frame.origin.y + CELL_COLLAPSED_HEIGHT + 52, topicStrip.frame.size.width, topicStrip.frame.size.height)];
            [card setFrame:CGRectMake(card.frame.origin.x, card.frame.origin.y, card.frame.size.width, card.frame.size.height + CELL_COLLAPSED_HEIGHT + 52)];
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + CELL_COLLAPSED_HEIGHT + 52)];
            [CATransaction commit];
        } completion:^(BOOL finished){
            card.layer.masksToBounds = NO;
            
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            [topicStrip setFrame:CGRectMake(topicStrip.frame.origin.x, topicStrip.frame.origin.y, topicStrip.frame.size.width, topicStrip.frame.size.height - 5)];
            [CATransaction commit];
        }];
    }
}

- (void)playMarkingAnimation
{
    // Note: this animation doesn't play when you unmark a tip.
    
    markUsefulButton.hidden = YES;
    stretchyMarkUsefulButton.hidden = NO;
    
    // Rotate the bulb.
    CABasicAnimation *fullBackwardRotation;
    fullBackwardRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullBackwardRotation.fromValue = [NSNumber numberWithFloat:0];
    fullBackwardRotation.toValue = [NSNumber numberWithFloat:(M_PI * 2)];
    fullBackwardRotation.duration = 0.3;
    fullBackwardRotation.repeatCount = 0;
    
    [stretchyMarkUsefulButtonBulb.layer addAnimation:fullBackwardRotation forKey:@"360"];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        // Stretch the button (aiming for a bounce effect).
        [stretchyMarkUsefulButton setFrame:CGRectMake(stretchyMarkUsefulButton.frame.origin.x - 55, stretchyMarkUsefulButton.frame.origin.y, 105, stretchyMarkUsefulButton.frame.size.height)];
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            // Contract the button a bit.
            [stretchyMarkUsefulButton setFrame:CGRectMake(stretchyMarkUsefulButton.frame.origin.x + 10, stretchyMarkUsefulButton.frame.origin.y, 95, stretchyMarkUsefulButton.frame.size.height)];
        } completion:^(BOOL finished){
            // Revert.
            [UIView animateWithDuration:0.2 delay:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [stretchyMarkUsefulButton setFrame:CGRectMake(stretchyMarkUsefulButton.frame.origin.x + 45, stretchyMarkUsefulButton.frame.origin.y, 50, stretchyMarkUsefulButton.frame.size.height)];
            } completion:^(BOOL finished){
                markUsefulButton.hidden = NO;
                stretchyMarkUsefulButton.hidden = YES;
            }];
            
            [UIView animateWithDuration:0.03 delay:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                stretchyMarkUsefulButtonLabel.alpha = 0.0;
            } completion:^(BOOL finished){
                stretchyMarkUsefulButtonLabel.hidden = YES;
            }];
        }];
    }];
    
    [UIView animateWithDuration:0.15 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        stretchyMarkUsefulButtonLabel.hidden = NO;
        stretchyMarkUsefulButtonLabel.alpha = 1.0;
    } completion:^(BOOL finished){
        
    }];
}

- (void)dealloc
{
    [card release];
	[userThmbnlOverlayView release];
	[nameLabel release];
    [usernameLabel release];
	[tipTxtLabel release];
    [geniusIcon release];
    [clockIcon release];
	[timestampLabel release];
	[userThmbnl release];
    [markUsefulButton release];
    [stretchyMarkUsefulButton release];
    [stretchyMarkUsefulButtonBulb release];
    [stretchyMarkUsefulButtonLabel release];
    [topicStripIcon release];
    [catIcon release];
    [tipOptionsPane release];
    [tipOptionsLinen release];
    [usefulnessMeterIconView release];
    [usefulnessMeter release];
    [facemash_1 release];
    [facemash_2 release];
    [facemash_3 release];
    [facemash_4 release];
    [facemash_5 release];
    [facemash_6 release];
    [facemash_7 release];
    [super dealloc];
}

@end
