#import <UIKit/UIKit.h>

@interface TBActivity : UIActivity {
    NSString *TBActivityType;
    NSString *TBActivityTitle;
    UIImage *TBActivityImage;
    NSString *data;
}

@property (nonatomic, retain) NSString *TBActivityType;
@property (nonatomic, retain) NSString *TBActivityTitle;
@property (nonatomic, retain) UIImage *TBActivityImage;
@property (nonatomic, retain) NSString *data;

@end
