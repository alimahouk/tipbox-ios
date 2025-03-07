#import <UIKit/UIKit.h>

@interface UITableViewActionSheet : UIActionSheet {
    NSIndexPath *indexPath;
}

@property (nonatomic, retain) NSIndexPath *indexPath;

@end
