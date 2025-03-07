#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *userPicHash;
@property (nonatomic, retain) NSString *userid;
@property (nonatomic, retain) NSString *fbConnected;
@property (nonatomic, retain) NSString *twitterConnected;
@property (nonatomic, retain) NSString *bio;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *location;

@end
