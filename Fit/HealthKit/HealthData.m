//
//  HealthData.m
//  ATCHealthKit
//
//  Created by Evan Lin on 2014/12/19.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "HealthData.h"

@implementation HealthData
- (id) initObj
{
    id _id = [super init];
    _BloodPressureDiastolic = 0.0;
    _BloodPressureSystolic = 0.0;
    _HeartRate = 0;
    _StepCount = 0;
    _Distance = 0;
    _Calories = 0.0;
    return _id;
}
@end
