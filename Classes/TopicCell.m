#import <QuartzCore/QuartzCore.h>
#import "TopicCell.h"

#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation TopicCell

@synthesize rowNumber, _id, topicid, tipCount, followCount, showsFollowButton;
@synthesize showsDisclosureIndicator, followsTopic, content, configuration, followerCountLabel;
@synthesize followerCountTextLabel, topicLabel, followButtonLabel, followButton, disclosureButton, disclosureAdd;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.opaque = YES;
        self.contentView.opaque = YES;
        self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_paper_texture.png"]];
        
        showsFollowButton = YES;
        
        card = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"card_shadow_bg.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0]];
        card.opaque = YES;
        card.userInteractionEnabled = YES;
        
        cardBgTexture = [CALayer layer];
        cardBgTexture.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]].CGColor;
        cardBgTexture.opaque = YES;
        [cardBgTexture setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)]; // Sets the co-ordinates right.
        
        statsSeparator = [CALayer layer];
        statsSeparator.masksToBounds = NO;
        statsSeparator.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0].CGColor;
        statsSeparator.opaque = YES;
        statsSeparator.frame = CGRectMake(153, 4, 1, 57);
        
        tipCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 13, 100, 20)];
        tipCountLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
        tipCountLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
        tipCountLabel.numberOfLines = 1;
        tipCountLabel.minimumFontSize = 8.;
        tipCountLabel.adjustsFontSizeToFitWidth = YES;
        tipCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
        tipCountLabel.opaque = YES;
        
        tipCountTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 28, 100, 20)];
        tipCountTextLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
        tipCountTextLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
        tipCountTextLabel.numberOfLines = 1;
        tipCountTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
        tipCountTextLabel.opaque = YES;
        
        followerCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(168, 13, 100, 20)];
        followerCountLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
        followerCountLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
        followerCountLabel.numberOfLines = 1;
        followerCountLabel.minimumFontSize = 8.;
        followerCountLabel.adjustsFontSizeToFitWidth = YES;
        followerCountLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:MIN_MAIN_FONT_SIZE];
        followerCountLabel.opaque = YES;
        
        followerCountTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(168, 28, 100, 20)];
        followerCountTextLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
        followerCountTextLabel.textColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0];
        followerCountTextLabel.numberOfLines = 1;
        followerCountTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:SECONDARY_FONT_SIZE];
        followerCountTextLabel.opaque = YES;
        
        topicStrip = [CALayer layer];
        topicStrip.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor;
        topicStrip.borderWidth = 0.7;
        topicStrip.borderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor;
        topicStrip.frame = CGRectMake(4, 58, 300, 33);
        topicStrip.opaque = YES;
        
        UIImageView *topicStripIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_bar_topics.png"]] autorelease];
        topicStripIcon.frame = CGRectMake(7, 1, 30, 30);
        
        topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 7, 170, 19)];
		topicLabel.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0];
		topicLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
		topicLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        topicLabel.shadowOffset = CGSizeMake(0, 1);
		topicLabel.numberOfLines = 1;
		topicLabel.minimumFontSize = 8.;
        topicLabel.adjustsFontSizeToFitWidth = YES;
		topicLabel.font = [UIFont fontWithName:@"Georgia" size:MIN_MAIN_FONT_SIZE];
        topicLabel.opaque = YES;
        
        followButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [followButton setBackgroundImage:[[UIImage imageNamed:@"quickfollow.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0] forState:UIControlStateNormal];
        [followButton setBackgroundImage:[[UIImage imageNamed:@"quickfollow_highlighted.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0] forState:UIControlStateHighlighted];
        followButton.adjustsImageWhenHighlighted = NO;
        followButton.frame = CGRectMake(221, 56, 80, 44);
        
        followButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
        followButtonLabel.backgroundColor = [UIColor clearColor];
        followButtonLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        followButtonLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        followButtonLabel.shadowOffset = CGSizeMake(0, -1);
        followButtonLabel.textAlignment = UITextAlignmentCenter;
        followButtonLabel.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
        followButtonLabel.text = @"FOLLOW";
        followButtonLabel.opaque = YES;
        
        disclosureButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [disclosureButton setImage:[UIImage imageNamed:@"disclosure_detail.png"] forState:UIControlStateNormal];
        disclosureButton.frame = CGRectMake(272, 64, 29, 29);
		disclosureButton.hidden = YES;
        
        disclosureAdd = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure_add.png"]];
        disclosureAdd.frame = CGRectMake(271, 7, 29, 31);
        disclosureAdd.hidden = YES;
        
        dottedDivider = [CALayer layer];
        dottedDivider.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dotted_line_grey.png"]].CGColor;
        dottedDivider.opaque = YES;
        [dottedDivider setTransform:CATransform3DMakeScale(1.0, -1.0, 1.0)];
        dottedDivider.frame = CGRectMake(0, 58, 320, 2);
        dottedDivider.hidden = YES;
        
        [card.layer addSublayer:cardBgTexture];
        [card.layer addSublayer:statsSeparator];
        [card addSubview:tipCountLabel];
        [card addSubview:tipCountTextLabel];
        [card addSubview:followerCountLabel];
        [card addSubview:followerCountTextLabel];
        [card.layer addSublayer:topicStrip];
        [card addSubview:disclosureAdd];
        [card addSubview:followButton];
        [card addSubview:disclosureButton];
        [topicStrip addSublayer:topicStripIcon.layer];
        [topicStrip addSublayer:topicLabel.layer];
        [followButton addSubview:followButtonLabel];
		
        self.userInteractionEnabled = YES;
		[self.contentView addSubview:card];
        [self.contentView.layer addSublayer:dottedDivider];
        
	}
	
	return self;
}

- (void)populateCellWithContent:(NSMutableDictionary *)topic
{
    self.tag = rowNumber; // Special identifier.
    
    _id = [[topic objectForKey:@"id"] intValue];
    topicid = [[topic objectForKey:@"topicid"] intValue];
    tipCount = [[topic objectForKey:@"tipCount"] intValue];
    followCount = [[topic objectForKey:@"followCount"] intValue];
    content = [topic objectForKey:@"content"];
    followsTopic = [[topic objectForKey:@"followsTopic"] boolValue];
    
    topicLabel.text = content;
    
    if (tipCount == 1) {
        tipCountLabel.text = @"1";
    } else {
        tipCountLabel.text = [NSString stringWithFormat:@"%d", tipCount];
    }
    
    if (followCount == 1) {
        followerCountLabel.text =  @"1";
    } else {
        followerCountLabel.text =  [NSString stringWithFormat:@"%d", followCount];
    }
    
    tipCountTextLabel.text = [NSString stringWithFormat:@"TIP%@", tipCount == 1 ? @"" : @"S"];
    followerCountTextLabel.text = [NSString stringWithFormat:@"FOLLOWER%@", followCount == 1 ? @"" : @"S"];
    
    if (followsTopic) {
        [followButton setBackgroundImage:[[UIImage imageNamed:@"quickunfollow.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0] forState:UIControlStateNormal];
        followButtonLabel.font = [UIFont boldSystemFontOfSize:11];
        followButtonLabel.text = @"FOLLOWING";
    } else {
        [followButton setBackgroundImage:[[UIImage imageNamed:@"quickunfollow.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0] forState:UIControlStateNormal];
        followButtonLabel.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
        followButtonLabel.text = @"FOLLOW";
    }
    
    // The "Create topic" configuration.
    if ([configuration isEqualToString:@"create"]) {
        statsSeparator.hidden = YES;
        tipCountLabel.hidden = YES;
        tipCountTextLabel.hidden = YES;
        followerCountLabel.hidden = YES;
        followerCountTextLabel.hidden = YES;
        followButton.hidden = YES;
        disclosureAdd.hidden = NO;
        dottedDivider.hidden = NO;
        
        self.frame = CGRectMake(0, 0, 320, 60);
        card.frame = CGRectMake(6, 10, 308, 40);
        cardBgTexture.frame = CGRectMake(4, 4, 300, 33);
        topicStrip.frame = CGRectMake(4, 4, 300, 33);
    } else {
        statsSeparator.hidden = NO;
        tipCountLabel.hidden = NO;
        tipCountTextLabel.hidden = NO;
        followerCountLabel.hidden = NO;
        followerCountTextLabel.hidden = NO;
        disclosureAdd.hidden = YES;
        dottedDivider.hidden = YES;
        
        self.frame = CGRectMake(0, 0, 320, 107);
        card.frame = CGRectMake(6, 10, 308, 97);
        cardBgTexture.frame = CGRectMake(4, 4, 300, 90);
        topicStrip.frame = CGRectMake(4, 61, 300, 33);
        
        if (showsFollowButton) {
            followButton.hidden = NO;
        } else {
            followButton.hidden = YES;
        }
        
        if (showsDisclosureIndicator) {
            disclosureButton.hidden = NO;
        } else {
            disclosureButton.hidden = YES;
        }
    }
}

- (void)toggleFollowStatus
{
    if (followsTopic) {
        followCount--;
        followsTopic = 0;
        [followButton setBackgroundImage:[[UIImage imageNamed:@"quickunfollow.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0] forState:UIControlStateNormal];
        followButtonLabel.font = [UIFont boldSystemFontOfSize:SECONDARY_FONT_SIZE];
        followButtonLabel.text = @"FOLLOW";
    } else {
        followCount++;
        followsTopic = 1;
        [followButton setBackgroundImage:[[UIImage imageNamed:@"quickunfollow.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:7.0] forState:UIControlStateNormal];
        followButtonLabel.font = [UIFont boldSystemFontOfSize:11];
        followButtonLabel.text = @"FOLLOWING";
    }
    
    followerCountLabel.text =  [NSString stringWithFormat:@"%d", followCount];
    followerCountTextLabel.text = [NSString stringWithFormat:@"FOLLOWER%@", followCount == 1 ? @"" : @"S"];
}

// Override these methods to customize cell highlighting.
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    // Disable implicit animations. Make sure to wrap the affected code
    // in a block, otherwise it messes up pushViewController animations!
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    if (highlighted) {
        cardBgTexture.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"feed_button_grey_bg.png"]].CGColor;
        tipCountLabel.backgroundColor = [UIColor clearColor];
        tipCountTextLabel.backgroundColor = [UIColor clearColor];
        followerCountLabel.backgroundColor = [UIColor clearColor];
        followerCountTextLabel.backgroundColor = [UIColor clearColor];
        
        if ([configuration isEqualToString:@"create"]) {
            topicStrip.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"feed_button_grey_bg.png"]].CGColor;
            topicLabel.backgroundColor = [UIColor clearColor];
        }
    } else {
        cardBgTexture.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]].CGColor;
        tipCountLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
        tipCountTextLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
        followerCountLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
        followerCountTextLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]];
        
        if ([configuration isEqualToString:@"create"]) {
            topicStrip.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0].CGColor;
            topicLabel.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:201.0/255.0 alpha:1.0];
        }
    }
    
    [CATransaction commit];
    
    [super setHighlighted:NO animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];
}

- (void)dealloc
{
    [topicLabel release];
    [followButtonLabel release];
    [followButton release];
    [disclosureAdd release];
    [super dealloc];
}

@end
