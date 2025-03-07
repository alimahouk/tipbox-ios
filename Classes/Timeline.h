#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "TipCell.h"
#import "TopicCell.h"
#import "IdCardCell.h"
#import "LoadMoreCell.h"

@interface Timeline : UIViewController <UIScrollViewDelegate> {  
    __block ASIFormDataRequest *dataRequest;
	NSDictionary *responseData;
    NSMutableArray *feedEntries;
    IBOutlet UITableView *timelineFeed;
    TipCell *timelineCell;
    TopicCell *topicCell;
    IdCardCell *idCardCell;
    LoadMoreCell *loadMoreCell;
    NSMutableDictionary *selectedIndexes;
    NSTimer *tapTimer;
    int tapCount;
    int tappedRow;
    int lastTappedRow;
    int doubleTapRow;
    int feed_targetid;
    int batchNo;
    BOOL timelineDidDownload;
    BOOL reloading;
    BOOL endOfFeed;
}

@property (nonatomic, retain) __block ASIFormDataRequest *dataRequest;
@property (nonatomic, retain) NSDictionary *responseData;
@property (nonatomic, retain) NSMutableArray *feedEntries;
@property (nonatomic, retain) IBOutlet UITableView *timelineFeed;
@property (nonatomic, retain) NSMutableDictionary *selectedIndexes;
@property (nonatomic) int tapCount;
@property (nonatomic) int tappedRow;
@property (nonatomic) int lastTappedRow;
@property (nonatomic) int feed_targetid;
@property (nonatomic) int batchNo;
@property (nonatomic) BOOL endOfFeed;

- (void)downloadTimeline:(NSString *)type batch:(int)batch;
- (void)timelineDidFinishDownloading;
- (void)timelineFailedToDownload;
- (BOOL)cellIsSelected:(NSIndexPath *)indexPath;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
- (void)tapTimerFired:(NSTimer *)aTimer;
- (void)loadMoreFeedEntries;
- (void)didSwipeTableViewCell:(UIGestureRecognizer *)gestureRecognizer;
- (void)markUseful:(id)sender;
- (void)gotoTip:(id)sender;
- (void)followTopicAtIndexPath:(NSIndexPath *)indexPath;
- (void)handleTipSharingAtIndexPath:(NSIndexPath *)indexPath forButtonAtIndex:(int)buttonIndex;
- (void)handleTipDeletionAtIndexPath:(NSIndexPath *)indexPath;
- (void)handleTipCreationAtIndexPath:(NSIndexPath *)indexPath;
- (void)handleTipReportingAtIndexPath:(NSIndexPath *)indexPath;
- (void)gotoUser:(id)sender;
- (void)showMoreTipOptions:(id)sender;
- (void)showTipSharingOptions:(id)sender;
- (void)showTipDeletionOptions:(id)sender;

@end
