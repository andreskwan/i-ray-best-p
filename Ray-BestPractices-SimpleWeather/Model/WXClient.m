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
@end
