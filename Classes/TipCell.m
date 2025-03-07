#import <QuartzCore/QuartzCore.h>
#import "TipCell.h"
#import "TipboxAppDelegate.h"

#define CELL_CONTENT_WIDTH 320
#define CELL_CONTENT_MARGIN 5
#define CELL_COLLAPSED_HEIGHT 87
#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 15
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

@implementation TipCell

@synthesize tipCardView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        self.opaque = YES;
        self.contentView.opaque = YES;
        
        CGRect tcvFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		tipCardView = [[TipCardView alloc] initWithFrame:tcvFrame];
		[self.contentView addSubview:tipCardView];
	}
	
	return self;
}

- (void)collapseCell
{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [tipCardView.topicStrip setFrame:CGRectMake(tipCardView.topicStrip.frame.origin.x, tipCardView.topicStrip.frame.origin.y, tipCardView.topicStrip.frame.size.width, tipCardView.topicStrip.frame.size.height + 5)]; // To hide any bleeding edges.
    [CATransaction commit];
    
    if (tipCardView.isSelected) { // Collapse the cell.
        tipCardView.card.layer.masksToBounds = YES;
        
        // The collapsing animation has a slight bounce effect.
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [CATransaction setAnimationDuration:0.15];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            [tipCardView.topicStrip setFrame:CGRectMake(tipCardView.topicStrip.frame.origin.x, tipCardView.topicStrip.frame.origin.y - CELL_COLLAPSED_HEIGHT - 62, tipCardView.topicStrip.frame.size.width, tipCardView.topicStrip.frame.size.height)];
            [tipCardView.card setFrame:CGRectMake(tipCardView.card.frame.origin.x, tipCardView.card.frame.origin.y, tipCardView.card.frame.size.width, tipCardView.card.frame.size.height - CELL_COLLAPSED_HEIGHT - 62)];
            [tipCardView setFrame:CGRectMake(tipCardView.frame.origin.x, tipCardView.frame.origin.y, tipCardView.frame.size.width, tipCardView.frame.size.height - CELL_COLLAPSED_HEIGHT - 62)];
            [CATransaction commit];
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [CATransaction setAnimationDuration:0.2];
                [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
                [tipCardView.topicStrip setFrame:CGRectMake(tipCardView.topicStrip.frame.origin.x, tipCardView.topicStrip.frame.origin.y + 10, tipCardView.topicStrip.frame.size.width, tipCardView.topicStrip.frame.size.height)];
                [tipCardView.card setFrame:CGRectMake(tipCardView.card.frame.origin.x, tipCardView.card.frame.origin.y, tipCardView.card.frame.size.width, tipCardView.card.frame.size.height + 10)];
                [tipCardView setFrame:CGRectMake(tipCardView.frame.origin.x, tipCardView.frame.origin.y, tipCardView.frame.size.width, tipCardView.frame.size.height + 10)];
                [CATransaction commit];
            } completion:^(BOOL finished){
                tipCardView.card.layer.masksToBounds = NO;
                tipCardView.tipOptionsPane.hidden = YES;
                
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                [tipCardView.topicStrip setFrame:CGRectMake(tipCardView.topicStrip.frame.origin.x, tipCardView.topicStrip.frame.origin.y, tipCardView.topicStrip.frame.size.width, tipCardView.topicStrip.frame.size.height - 5)];
                [CATransaction commit];
            }];
        }];
    } else { // Expand the cell.
        [tipCardView setUpFacemash];
        tipCardView.card.layer.masksToBounds = YES;
        tipCardView.tipOptionsPane.hidden = NO;
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [CATransaction setAnimationDuration:0.2];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            [tipCardView.topicStrip setFrame:CGRectMake(tipCardView.topicStrip.frame.origin.x, tipCardView.topicStrip.frame.origin.y + CELL_COLLAPSED_HEIGHT + 52, tipCardView.topicStrip.frame.size.width, tipCardView.topicStrip.frame.size.height)];
            [tipCardView.card setFrame:CGRectMake(tipCardView.card.frame.origin.x, tipCardView.card.frame.origin.y, tipCardView.card.frame.size.width, tipCardView.card.frame.size.height + CELL_COLLAPSED_HEIGHT + 52)];
            [tipCardView setFrame:CGRectMake(tipCardView.frame.origin.x, tipCardView.frame.origin.y, tipCardView.frame.size.width, tipCardView.frame.size.height + CELL_COLLAPSED_HEIGHT + 52)];
            [CATransaction commit];
        } completion:^(BOOL finished){
            tipCardView.card.layer.masksToBounds = NO;
            
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            [tipCardView.topicStrip setFrame:CGRectMake(tipCardView.topicStrip.frame.origin.x, tipCardView.topicStrip.frame.origin.y, tipCardView.topicStrip.frame.size.width, tipCardView.topicStrip.frame.size.height - 5)];
            [CATransaction commit];
        }];
    }
}

// Override these methods to customize cell highlighting.
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    // Disable implicit animations. Make sure to wrap the affected code
    // in a block, otherwise it messes up pushViewController animations!
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    if (highlighted) {
        tipCardView.cardBgTexture.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"feed_button_grey_bg.png"]].CGColor;
    } else {
        tipCardView.cardBgTexture.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper_noise.png"]].CGColor;
    }
    
    [CATransaction commit];

    [super setHighlighted:NO animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	
	if (!newSuperview) {
		[tipCardView.userThmbnl cancelImageLoad];
        [tipCardView.facemash_1.photo cancelImageLoad];
        [tipCardView.facemash_2.photo cancelImageLoad];
        [tipCardView.facemash_3.photo cancelImageLoad];
        [tipCardView.facemash_4.photo cancelImageLoad];
        [tipCardView.facemash_5.photo cancelImageLoad];
        [tipCardView.facemash_6.photo cancelImageLoad];
        [tipCardView.facemash_7.photo cancelImageLoad];
	}
}

- (void)dealloc
{
    [super dealloc];
}

@end
