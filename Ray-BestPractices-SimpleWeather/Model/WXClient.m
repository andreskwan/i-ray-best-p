//
//  WXClient.m
//  Ray-BestPractices-SimpleWeather
//
//  Created by Andres Kwan on 4/21/15.
//  Copyright (c) 2015 Andres.Kwan. All rights reserved.
//

#import "WXClient.h"

@interface WXClient ()
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation WXClient

- (id)init {
    if (self = [super init])
    {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url
{
    NSLog(@"Fetching: %@",url.absoluteString);
    // 1 Returns the signal
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber)
    {
        // 2 fetch data from the URL
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                if (! error) {
                    NSError *jsonError = nil;
                    id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                    if (! jsonError) {
                        // 1 send the subscriber the JSON serialized as either an array or dictionary.
                        [subscriber sendNext:json];
                    } else {
                        // 2 If there is an error in either case, notify the subscriber.
                        [subscriber sendError:jsonError];
                    }
                } else {
                    // 2 If there is an error in either case, notify the subscriber.
                    [subscriber sendError:error];
                }
                // 3 let the subscriber know that the request has completed.
                [subscriber sendCompleted];
            }];
        // 3 start the session, network request once someone subscribes to the signal
        [dataTask resume];
        // 4 handles any cleanup when the singal is destroyed
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error)
    {
        // 5 side effects do not subscribe to the signal
        NSLog(@"%@",error);
    }];
}

- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate
{
    // 1 Set the URL with coordinates
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial",coordinate.latitude, coordinate.longitude];
    // turn the NSString into a NSURL
    NSURL *url = [NSURL URLWithString:urlString];
    // 2 create the signal fetch with url, Here you map the returned value — an instance of NSDictionary — into a different value.
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json){
            // 3 Use MTLJSONAdapter to convert the JSON into an WXCondition object
            return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:json error:nil];
    }];
}

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 1
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // 2
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // 3
        return [[list map:^(NSDictionary *item) {
            // 4
            return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:item error:nil];
            // 5
        }] array];
    }];
}

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use the generic fetch method and map results to convert into an array of Mantle objects
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // Build a sequence from the list of raw JSON
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // Use a function to map results from JSON to Mantle objects
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[WXDailyForecast class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}
@end
