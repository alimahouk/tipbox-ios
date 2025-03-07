#import <UIKit/UIKit.h>

@interface UITableViewActivityViewController : UIActivityViewController {
    NSIndexPath *indexPath;
}

@property (nonatomic, retain) NSIndexPath *indexPath;

@end
