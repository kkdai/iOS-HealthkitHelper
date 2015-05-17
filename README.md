# iOS-HealthkitHelper

Helper function ti summarized all HealthKit data access and make it to sync call for easy usage.


### How to use it

    //Init HLKHelper
    HealthKitHelper *HLKHelper;
    _HLKHelper = [[HealthKitHelper alloc] initKitWithCheckHealthStore:_healthStore :self];

    //Get your Height from HealthKit
    [_HLKHelper getHeight];
    
    
    //Set heart rate
    [_HLKHelper setHeartRate];
    
    
This still under developing.    