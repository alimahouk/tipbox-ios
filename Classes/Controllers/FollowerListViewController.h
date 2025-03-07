#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "Global.h"
#import "MBProgressHUD.h"
#import "Timeline.h"

@interface FollowerListViewController : Timeline <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate> {
    Global *global;
    __block ASIFormDataRequest *dataRequest_child;
    NSDictionary *responseData_child;
    
    MBProgressHUD *HUD;
    int topicid;
}

@property (nonatomic) int topicid;

- (void)getFollowersForBatch:(int)batch;

@end