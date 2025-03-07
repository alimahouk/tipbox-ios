#import <UIKit/UIKit.h>

@interface LoadMoreCell : UITableViewCell {
    UIImageView *card;
    UIButton *button;
    UILabel *buttonTxtShadow;
    UIImageView *feedEndMarker;
}

@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) UILabel *buttonTxtShadow;

- (void)showEndMarker;
- (void)hideEndMarker;

@end
