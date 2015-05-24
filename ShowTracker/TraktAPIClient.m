//
//  TraktAPIClient.m
//  ShowTracker
//
//  Created by victor on 5/21/15.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

#import "TraktAPIClient.h"

NSString * const kTraktClientID = @"ba086f2ddd7e20301a9024fc2a56121224f5cba457ce6b048b03ccf384f98c3c";
NSString * const kTraktBaseURLString = @"https://api-v2launch.trakt.tv";

@implementation TraktAPIClient

+ (TraktAPIClient *) sharedClient {
    static TraktAPIClient *_shareClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{_shareClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kTraktBaseURLString]];});
    return _shareClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    return self;
        
}

- (void)getShowsForDate:(NSDate *)date numberOfDays:(int)numberOfDays success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [self.requestSerializer setValue:kTraktClientID forHTTPHeaderField:@"trakt-api-key"];
    [self.requestSerializer setValue:@"2" forHTTPHeaderField:@"trakt-api-version"];

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString* dateString = [formatter stringFromDate:date];
    NSString* path = [NSString stringWithFormat:@"calendars/all/shows/new/%@/%d", dateString, numberOfDays];
    NSLog(@"path = %@", path);
    [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
    
}
@end
