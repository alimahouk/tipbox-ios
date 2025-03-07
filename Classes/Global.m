#import "Global.h"
#import "TipboxAppDelegate.h"
#import "App.h"
#import "User.h"

@implementation Global

@synthesize appsArray, usersArray, managedObjectContext, lastRefreshedDate, usageCount;
@synthesize token, name, username, email, hash, location, url, bio, userid;
@synthesize fbConnected, twitterConnected;

- (id)init
{
    self = [super init];
    if (self) {
        
        if (managedObjectContext == nil) { 
            managedObjectContext = [(TipboxAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        }
        
        /*
         Fetch existing App objects.
         Create a fetch request; find the User entity and assign it to the request; then execute the fetch.
         */
        NSFetchRequest *request_app = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity_app = [NSEntityDescription entityForName:@"App" inManagedObjectContext:managedObjectContext];
        [request_app setEntity:entity_app];
        
        // Execute the fetch -- create a mutable copy of the result.
        NSError *error_app = nil;
        NSMutableArray *mutableFetchResults_app = [[managedObjectContext executeFetchRequest:request_app error:&error_app] mutableCopy];
        if (mutableFetchResults_app == nil) {
            // Handle the error.
            NSLog(@"Empty fetch results.");
        }
        
        // Set self's apps array to the mutable array, then clean up.
        [self setAppsArray:mutableFetchResults_app];
        [mutableFetchResults_app release];
        [request_app release];
        
        /*
         Fetch existing User objects.
         Create a fetch request; find the User entity and assign it to the request; then execute the fetch.
         */
        NSFetchRequest *request_user = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity_user = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
        [request_user setEntity:entity_user];
        
        // Execute the fetch -- create a mutable copy of the result.
        NSError *error_user = nil;
        NSMutableArray *mutableFetchResults_user = [[managedObjectContext executeFetchRequest:request_user error:&error_user] mutableCopy];
        if (mutableFetchResults_user == nil) {
            // Handle the error.
            NSLog(@"Empty fetch results.");
        }
        
        // Set self's users array to the mutable array, then clean up.
        [self setUsersArray:mutableFetchResults_user];
        [mutableFetchResults_user release];
        [request_user release];
    }
    
    return self;
}

- (NSString *)readProperty:(NSString *)property
{
    if ([appsArray count] == 0) {
        [self writeValue:@"" forProperty:@"token"];
    }
        
    App *app = (App *)[appsArray objectAtIndex:0];
    usageCount = [[app usageCount] intValue];
    lastRefreshedDate = [app lastRefreshedDate];
    
    User *user = (User *)[usersArray objectAtIndex:0];
    token = [user token];
    name = [user name];
    username = [user username];
    email = [user email];
    hash = [user userPicHash];
    location = [user location];
    url = [user url];
    bio = [user bio];
    userid = [[user userid] intValue];
    fbConnected = [[user fbConnected] boolValue];
    twitterConnected = [[user twitterConnected] boolValue];
    
    if ([property isEqualToString:@"usageCount"]) {
        return [NSString stringWithFormat:@"%d", usageCount];
    } else if ([property isEqualToString:@"lastRefreshedDate"]) {
        return lastRefreshedDate;
    } else if ([property isEqualToString:@"token"]) {
        return token;
    } else if ([property isEqualToString:@"name"]) {
        return name;
    } else if ([property isEqualToString:@"username"]) {
        return username;
    } else if ([property isEqualToString:@"email"]) {
        return email;
    } else if ([property isEqualToString:@"userPicHash"]) {
        return hash;
    } else if ([property isEqualToString:@"location"]) {
        return location;
    } else if ([property isEqualToString:@"url"]) {
        return url;
    } else if ([property isEqualToString:@"bio"]) {
        return bio;
    } else if ([property isEqualToString:@"userid"]) {
        return [NSString stringWithFormat:@"%d", userid];
    } else if ([property isEqualToString:@"fbConnected"]) {
        return [NSString stringWithFormat:@"%@", fbConnected ? @"YES" : @"NO"];
    } else if ([property isEqualToString:@"twitterConnected"]) {
        return [NSString stringWithFormat:@"%@", twitterConnected ? @"YES" : @"NO"];
    } else {
        return @"Error! Invalid property!";
    }
}

- (void)writeValue:(NSString *)value forProperty:(NSString *)property
{
    App *app;
    User *user;
    
    if ([value isEqual:[NSNull null]]) {
        value = @"";
    }
    
    if ([appsArray count] == 0) {
        app = (App *)[NSEntityDescription insertNewObjectForEntityForName:@"App" inManagedObjectContext:managedObjectContext];
        
        if ([property isEqualToString:@"usageCount"]) {
            [app setUsageCount:value];
        } else if ([property isEqualToString:@"lastRefreshedDate"]) {
            [app setLastRefreshedDate:value];
        }
        
        // Commit the change.
        NSError *error;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
        
        [appsArray insertObject:app atIndex:0];
    } else {
        app = (App *)[appsArray objectAtIndex:0];
        
        if ([property isEqualToString:@"usageCount"]) {
            [app setUsageCount:value];
        } else if ([property isEqualToString:@"lastRefreshedDate"]) {
            [app setLastRefreshedDate:value];
        }
        
        // Commit the change.
        NSError *error;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
    
    if ([usersArray count] == 0) {
        user = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
        
        if ([property isEqualToString:@"token"]) {
            [user setToken:value];
        } else if ([property isEqualToString:@"name"]) {
            [user setName:value];
        } else if ([property isEqualToString:@"username"]) {
            [user setUsername:value];
        } else if ([property isEqualToString:@"email"]) {
            [user setEmail:value];
        } else if ([property isEqualToString:@"userPicHash"]) {
            [user setUserPicHash:value];
        } else if ([property isEqualToString:@"location"]) {
            [user setLocation:value];
        } else if ([property isEqualToString:@"url"]) {
            [user setUrl:value];
        } else if ([property isEqualToString:@"bio"]) {
            [user setBio:value];
        } else if ([property isEqualToString:@"userid"]) {
            [user setUserid:value];
        } else if ([property isEqualToString:@"fbConnected"]) {
            [user setFbConnected:value];
        } else if ([property isEqualToString:@"twitterConnected"]) {
            [user setTwitterConnected:value];
        }
        
        // Commit the change.
        NSError *error;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
        
        [usersArray insertObject:user atIndex:0];
    } else {
        user = (User *)[usersArray objectAtIndex:0];
        
        if ([property isEqualToString:@"token"]) {
            [user setToken:value];
        } else if ([property isEqualToString:@"name"]) {
            [user setName:value];
        } else if ([property isEqualToString:@"username"]) {
            [user setUsername:value];
        } else if ([property isEqualToString:@"email"]) {
            [user setEmail:value];
        } else if ([property isEqualToString:@"userPicHash"]) {
            [user setUserPicHash:value];
        } else if ([property isEqualToString:@"location"]) {
            [user setLocation:value];
        } else if ([property isEqualToString:@"url"]) {
            [user setUrl:value];
        } else if ([property isEqualToString:@"bio"]) {
            [user setBio:value];
        } else if ([property isEqualToString:@"userid"]) {
            [user setUserid:value];
        } else if ([property isEqualToString:@"fbConnected"]) {
            [user setFbConnected:value];
        } else if ([property isEqualToString:@"twitterConnected"]) {
            [user setTwitterConnected:value];
        }
        
        // Commit the change.
        NSError *error;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
}

- (void)clearAll
{
    App *app = (App *)[appsArray objectAtIndex:0];
    User *user = (User *)[usersArray objectAtIndex:0];
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"MMM dd, yyyy HH:mm"];
    NSDate *dateNow = [[[NSDate alloc] init] autorelease];
    
    [app setLastRefreshedDate:[formatter stringFromDate:dateNow]];
    
    [user setToken:@""];
    [user setName:@""];
    [user setUsername:@""];
    [user setEmail:@""];
    [user setUserPicHash:@""];
    [user setLocation:@""];
    [user setUrl:@""];
    [user setBio:@""];
    [user setUserid:@"-1"];
    [user setFbConnected:@""];
    [user setTwitterConnected:@""];
    
    // Commit the change.
    NSError *error;
    if (![managedObjectContext save:&error]) {
        // Handle the error.
    }
}


- (void)dealloc
{
    [managedObjectContext release];
    [appsArray release];
    [usersArray release];
    [super dealloc];
}

@end
