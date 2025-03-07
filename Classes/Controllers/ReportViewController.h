#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"

@interface ReportViewController : UIViewController <MBProgressHUDDelegate> {
    __block ASIFormDataRequest *dataRequest;
    NSDictionary *responseData;
    
    MBProgressHUD *HUD;
    IBOutlet UIBarButtonItem *cancelButton;
    IBOutlet UINavigationItem *navBarTitle;
    IBOutlet UITableView *reportTableView;
    NSDictionary *tableContents;
	NSArray *sortedKeys;
    NSIndexPath *lastIndexPath;
    NSString *reportType;
    int objectid;
    UIButton *reportSubmitButton;
    UILabel *gratitude;
}

@property (nonatomic, retain) IBOutlet IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UINavigationItem *navBarTitle;
@property (nonatomic, retain) IBOutlet UITableView *reportTableView;
@property (nonatomic, retain) NSDictionary *tableContents;
@property (nonatomic, retain) NSArray *sortedKeys;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;
@property (nonatomic, retain) NSString *reportType;
@property (nonatomic) int objectid;

- (IBAction)dismissReportWindow:(id)sender;
- (void)sendReport:(id)sender;

@end