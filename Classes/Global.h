#import <UIKit/UIKit.h>

@interface Global : NSObject {
    NSMutableArray *appsArray;
    NSMutableArray *usersArray;
    NSManagedObjectContext *managedObjectContext;
    
    NSString *lastRefreshedDate;
    int usageCount;
    NSString *token;
    NSString *name;
    NSString *username;
    NSString *email;
    NSString *hash;
    NSString *location;
    NSString *url;
    NSString *bio;
    int userid;
    BOOL fbConnected;
    BOOL twitterConnected;
}

@property (nonatomic, retain) NSMutableArray *appsArray;
@property (nonatomic, retain) NSMutableArray *usersArray;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSString *lastRefreshedDate;
@property (nonatomic) int usageCount;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *hash;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *bio;
@property (nonatomic) int userid;
@property (nonatomic) BOOL fbConnected;
@property (nonatomic) BOOL twitterConnected;

- (NSString *)readProperty:(NSString *)property;
- (void)writeValue:(NSString *)value forProperty:(NSString *)property;
- (void)clearAll;

@end
