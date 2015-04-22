        //
//  WXClient.h
//  Ray-BestPractices-SimpleWeather
//
//  Created by Andres Kwan on 4/21/15.
//  Copyright (c) 2015 Andres.Kwan. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "WXCondition.h" 
#import "WXDailyForecast.h"

/*
 Responsability
 - create API resquest 
 - parse this responses
*/

@interface WXClient : NSObject
- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;

@end
