//
//  HealthData.h
//  ATCHealthKit
//
//  Created by Evan Lin on 2014/12/19.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HealthData : NSObject
@property (nonatomic) NSDate *EstimateDate;
@property (nonatomic) double BloodPressureSystolic;
@property (nonatomic) double BloodPressureDiastolic;
@property (nonatomic) double HeartRate; //Pulse
@property (nonatomic) double StepCount;
@property (nonatomic) double Distance;
@property (nonatomic) double UV;
@property (nonatomic) float Calories;
- (id) initObj;

@end
