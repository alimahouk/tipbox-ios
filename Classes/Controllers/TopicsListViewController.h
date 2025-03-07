#import <UIKit/UIKit.h>
#import "Global.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "Timeline.h"

@interface TopicsListViewController : Timeline <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate, UIAlertViewDelegate> {
    Global *global;
    __block ASIFormDataRequest *dataRequest_child;
    NSDictionary *responseData_child;
    
    MBProgressHUD *HUD;
	NSString *listOwner;
    NSString *listOwnerUserid;
    NSString *listType;
    int topicCount;
    UIButton *followAllButton;
    UILabel *followAllButtonLabel;
}

@property (nonatomic, retain) NSString *listOwner;
@property (nonatomic, retain) NSString *listOwnerUserid;
@property (nonatomic, retain) NSString *listType;
@property (nonatomic) int topicCount;

- (void)fetchTopicsForBatch:(int)batch;
- (void)confirmFollowAll;
- (void)followAllTopics;
- (void)followTopic:(id)sender;

@end