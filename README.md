# iOS-HealthkitHelper

Helper function ti summarized all HealthKit data access and make it to sync call for easy usage.


### How to use it

This package wants to make access HealthKit easier.

### Simple Code
    //Init HLKHelper
    HealthKitHelper *HLKHelper;
    _HLKHelper = [[HealthKitHelper alloc] initKitWithCheckHealthStore:_healthStore :self];

    //Get your Height from HealthKit
    double value = [_HLKHelper getHeight];    
    
    //Set heart rate using current timestamp.
    double heart_rate = 70;
    [_HLKHelper setHeartRate:setHeartRate :[NSDate date]];
    
### Support standard preference

    _HLKHelper = [[HealthKitHelper alloc] initKitWithCheckHealthStore:_healthStore :self];
    [_HLKHelper loadDataFromPref]; //load from user standard preference.
    //Every set value will store in user standard preference.    

This still under developing. 


    