//
//  WXDailyForecast.m
//  Ray-BestPractices-SimpleWeather
//
//  Created by Andres Kwan on 4/21/15.
//  Copyright (c) 2015 Andres.Kwan. All rights reserved.
//

#import "WXDailyForecast.h"

@implementation WXDailyForecast

//Overrides this method to allow this keys in the paths ditcionary of maps
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    // 1 Create a copy of the Dictionary of maps
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    // 2 add two more paths to the map
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    // 3 return the map
    return paths;
}

@end
