#import <UIKit/UIKit.h>

@interface Settings_AboutViewController : UIViewController <UIActionSheetDelegate> {
    IBOutlet UIScrollView *scrollView;
    UIActionSheet *socialLinks;
    int targetIdentity;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)gotoIdentity:(id)sender;
- (IBAction)rateApp:(id)sender;

@end
