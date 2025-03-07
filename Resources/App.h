#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface App : NSManagedObject

@property (nonatomic, retain) NSString *lastRefreshedDate;
@property (nonatomic, retain) NSString *usageCount;

@end
