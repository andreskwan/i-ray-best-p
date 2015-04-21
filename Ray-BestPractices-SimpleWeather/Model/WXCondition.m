//
//  WXCondition.m
//  Ray-BestPractices-SimpleWeather
//
//  Created by Andres Kwan on 4/21/15.
//  Copyright (c) 2015 Andres.Kwan. All rights reserved.
//

#import "WXCondition.h"

@implementation WXCondition

+ (NSDictionary *)imageMap {
    // 1 create a static dictionary is common to all instances of this class
    static NSDictionary *_imageMap = nil;
    if (! _imageMap) {
        // 2 map condition codes to image file
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",
                      };
    }
    return _imageMap;
}

// 3 return an imageName from the static Dictionary an the icon set in the self
- (NSString *)imageName {
    return [WXCondition imageMap][self.icon];
}
/*
{ "dt": 1384279857,
  "id": 5391959, 
  "main": { "humidity": 69, 
            "pressure": 1025,
            "temp": 62.29, 
            "temp_max": 69.01, 
            "temp_min": 57.2 }, 
  "name": "San Francisco", 
  "weather": [ { "description": "haze", 
                 "icon": "50d", 
                 "id": 721, 
                 "main": "Haze" } 
             ]
}
*/
//Key-value coding
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

// 1 transform values to and from obj-c properties
+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str){
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    }
                                                         reverseBlock:^(NSDate *date){
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}

// 2 reuse the transformer for NSDate/float-UnixTime
+ (NSValueTransformer *)sunriseJSONTransformer {
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)sunsetJSONTransformer {
    return [self dateJSONTransformer];
}

//NSString/
+ (NSValueTransformer *)conditionDescriptionJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values) {
        //returns the only value inside the array which should be a NSString
        return [values firstObject];
    } reverseBlock:^(NSString *str) {
        //returns an array with one string
        return @[str];
    }];
}

+ (NSValueTransformer *)conditionJSONTransformer {
    return [self conditionDescriptionJSONTransformer];
}

+ (NSValueTransformer *)iconJSONTransformer {
    return [self conditionDescriptionJSONTransformer];
}

#define MPS_TO_MPH 2.23694f   

+ (NSValueTransformer *)windSpeedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num) {
        return @(num.floatValue*MPS_TO_MPH);
    }
                                                         reverseBlock:^(NSNumber *speed) {
        return @(speed.floatValue/MPS_TO_MPH); }];
}

@end
