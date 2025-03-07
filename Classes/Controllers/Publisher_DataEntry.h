#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "Global.h"
#import "Publisher.h"
#import "TopicCell.h"
#import "LoadMoreCell.h"
#import "LPLabel.h"
#import "ToggleButton.h"

@interface Publisher_DataEntry : UIViewController <UINavigationControllerDelegate, UISearchBarDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate, UIAlertViewDelegate> {
    ASIFormDataRequest *dataRequest;
    NSString *activeConnectionIdentifier;
    NSDictionary *responseData;
    Global *global;
    
    MBProgressHUD *HUD;
    NSString *configuration;
    Publisher *pub;
    
    /**********************************/
    /* Category/Subcategory Selection */
    /**********************************/
    
    UIView *categorySelectionOverlay;
    UIButton *categoryButton_thing;
    UIButton *categoryButton_place;
    UIButton *categoryButton_idea;
    UIButton *cancelCategoryButton;
    CALayer *dottedDivider;
    UIView *categorySelectionOverlayDivider_1;
    UIView *categorySelectionOverlayDivider_2;
    UITableView *subcategoryTableView;
    UIActivityIndicatorView *activityIndicator_subcategories;
    NSDictionary *tableContents;
	NSArray *sortedKeys;
    NSArray *subcategories_main;
    NSMutableArray *subcategories_thing;
    NSMutableArray *subcategories_place;
    NSDictionary *subcategoriesDict;
    NSIndexPath *selectedSubcategoryIndexPath;
    BOOL didDownloadSubcategories_thing;
    BOOL didDownloadSubcategories_place;
    int selectedSubcategory;
    int category;
    int subcategory;
    
    /*******************/
    /* Topic Selection */
    /*******************/
    
    UIView *topicSelectionOverlay;
    UIView *keyboardTouchpad;
    UISearchBar *topicSearchBox;
    UIActivityIndicatorView *activityIndicator_topics;
    LPLabel *topicSelectionTip;
    LPLabel *topicSelectionTipSubtitle;
    NSMutableArray *topics;
    UITableView *topicTableView;
    TopicCell *topicCell;
    TopicCell *createTopicCell;
    LoadMoreCell *loadMoreCell;
    NSString *query;
    NSString *topic;
    BOOL didDownloadTopics;
    BOOL endOfFeed;
    int batchNo;
    int topicid;
}

@property (nonatomic, retain) ASIFormDataRequest *dataRequest;
@property (nonatomic, retain) NSDictionary *responseData;
@property (nonatomic, retain) NSString *configuration;
@property (nonatomic) int category;
@property (nonatomic) int subcategory;
@property (nonatomic, retain) NSDictionary *tableContents;
@property (nonatomic, retain) NSArray *sortedKeys;
@property (nonatomic, retain) NSArray *subcategories_main;
@property (nonatomic, retain) NSMutableArray *subcategories_thing;
@property (nonatomic, retain) NSMutableArray *subcategories_place;
@property (nonatomic, retain) NSDictionary *subcategoriesDict;
@property (nonatomic, retain) NSIndexPath *selectedSubcategoryIndexPath;
@property (nonatomic) int selectedSubcategory;
@property (nonatomic, retain) NSMutableArray *topics;
@property (nonatomic, retain) NSString *topic;
@property (nonatomic) int topicid;

- (void)showCategoryOverlay;
- (void)dismissCategoryOverlay:(id)sender;
- (void)resetCategories;
- (void)fetchSubcategoriesOfType:(NSString *)type;
- (void)showTopicSearchOverlay;
- (void)hideKeyboardPad;
- (void)dismissTopicSearchOverlay;
- (void)searchTopicsforQuery:(NSString *)searchQuery batch:(int)batch;
- (void)gotoTopic:(id)sender;
- (void)loadMoreTopics;

@end