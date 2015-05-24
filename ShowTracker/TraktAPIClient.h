#import "AFNetworking/AFNetworking.h"
extern NSString * const kTraktAPIKey;
extern NSString * const kTraktBaseURLString;

@interface TraktAPIClient : AFHTTPSessionManager

+ (TraktAPIClient *) sharedClient;

- (void)getShowsForDate:(NSDate *)date numberOfDays:(int)numberOfDays success:(void(^)(NSURLSessionDataTask *task, id responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
