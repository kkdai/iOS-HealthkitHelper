//
//  HealthKitHelper.h
//  ATCHealthKit
//
//  Created by Evan Lin on 2014/12/17.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
@import HealthKit;
@import UIKit;

#import "HealthData.h"

@interface HealthKitHelper : NSObject
@property (nonatomic) HKHealthStore *healthStore;
@property (nonatomic) NSMutableArray *localDataList;

- (id) initKitWithCheckHealthStore:(HKHealthStore*) appHLStore :(UIViewController *) parentView;
//Save/Load Data
- (void)loadDataFromPref;
- (void)saveDataToPref;

// Get single result
- (double)getMostRecentBloodPressureDIS;
- (double)getMostRecentBloodPressureSIS;
- (double)getMostRecentHeartRate;
- (double)getMostRecentStepCount;
- (double)getMostRecentActiveCalories;
- (double)getMostRecentDistance;
- (double)getHeight; //cm
- (double)getWeight; //kg
- (double)getGender; //0:not set, 1: Female, 2: Male, 3:Other

// Set Data
- (void)setActiveCalories:(float)KCalories :(NSDate*)times;
- (void)setDistance:(double)meters :(NSDate*)times;
- (void)setStepCount:(double)stepcount :(NSDate*)times;
- (void)setHeartRate:(double)heartRate :(NSDate*)times;
- (void)saveBloodPressure:(double)Systolic :(double)Diastolic :(NSDate*)times;
@end