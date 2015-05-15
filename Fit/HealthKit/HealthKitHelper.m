//
//  HealthKitHelper.m
//  ATCHealthKit
//
//  Created by Evan Lin on 2014/12/17.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "HealthKitHelper.h"

@interface HealthKitHelper()
{
    NSMutableArray *localDataList;
}

@end
@implementation HealthKitHelper
- (id) initKitWithCheckHealthStore:(HKHealthStore*) appHLStore :(UIViewController *) parentView //:(void (^)(BOOL success, NSError* error))compleUIAction
{
    id _id= [super init];
    localDataList = nil;
    //get healthStore instance from appdelegate in Bar
    _healthStore = appHLStore;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                
                return;
            }
            
            dispatch_semaphore_signal(sema);
        }];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"HealthKit init failed."
                                                                       message:@"HealthKit is not avaliable in this device, please use iPhone with iOS8+"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [parentView presentViewController:alert animated:YES completion:nil];
        //return nil;
        
        localDataList = [[NSMutableArray alloc] init];
        [self loadDataFromPref];
        return _id;
    }

    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    sema = NULL;
    return _id;
}

#pragma mark - Data Schema.
-(void)saveDataToPref
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    //sensor data- BP
    NSMutableArray *bp_BloodPressureSystolic = [[NSMutableArray alloc] init];
    NSMutableArray *bp_BloodPressureDiastolic = [[NSMutableArray alloc] init];
    NSMutableArray *bp_HeartRate = [[NSMutableArray alloc] init];
    NSMutableArray *bp_EstimateDate = [[NSMutableArray alloc] init];

    //Running
    NSMutableArray *sp_StepCount = [[NSMutableArray alloc] init];
    
    for(HealthData *peripheralData in localDataList)
    {
        //sensor data- BP
        [bp_BloodPressureSystolic addObject:[NSNumber numberWithDouble:peripheralData.BloodPressureDiastolic]];
        [bp_BloodPressureDiastolic addObject:[NSNumber numberWithFloat:peripheralData.BloodPressureSystolic]];
        [bp_HeartRate addObject:[NSNumber numberWithFloat:peripheralData.HeartRate]];
        [bp_EstimateDate addObject:peripheralData.EstimateDate];
        [sp_StepCount addObject:[NSNumber numberWithDouble:peripheralData.StepCount]];
    }
    
    //sensor data- BP
    [pref setObject:bp_BloodPressureSystolic forKey:@"bp_BloodPressureSystolic"];
    [pref setObject:bp_BloodPressureDiastolic forKey:@"bp_BloodPressureDiastolic"];
    [pref setObject:bp_HeartRate forKey:@"bp_HeartRate"];
    [pref setObject:bp_EstimateDate forKey:@"bp_BloodPresureEstimateDate"];
    [pref setObject:sp_StepCount forKey:@"sp_StepCount"];
    [pref synchronize];
}

-(void)freeBPDataList
{
    @synchronized(localDataList)
    {
        while(localDataList.count)
        {
            [localDataList removeObjectAtIndex:0];
        }
    }
}

-(void)loadDataFromPref
{    
    @synchronized(localDataList)
    {
        [self freeBPDataList];
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        
        
        //sensor data- BP
        NSArray *bp_BloodPressureSystolic = [pref objectForKey:@"bp_BloodPressureSystolic"];
        NSArray *bp_BloodPressureDiastolic = [pref objectForKey:@"bp_BloodPressureDiastolic"];
        NSArray *bp_HeartRate = [pref objectForKey:@"bp_HeartRate"];
        NSArray *bp_EstimateDate = [pref objectForKey:@"bp_BloodPresureEstimateDate"];
        NSArray *sp_StepCount = [pref objectForKey:@"sp_StepCount"];
        
        
        HealthData *BPObj = [[HealthData alloc] init];
        
        for(int i=0;i<bp_EstimateDate.count;i++)
        {
            //sensor data- BP
            if(bp_BloodPressureSystolic != nil)
                BPObj.BloodPressureSystolic = [(NSNumber*)bp_BloodPressureSystolic[i] doubleValue];
            if(bp_BloodPressureDiastolic != nil)
                BPObj.BloodPressureDiastolic = [(NSNumber*)bp_BloodPressureDiastolic[i] doubleValue];
            if(bp_HeartRate != nil)
                BPObj.HeartRate = [(NSNumber*)bp_HeartRate[i] doubleValue];
            if(bp_EstimateDate != nil)
                BPObj.EstimateDate = (NSDate*)bp_EstimateDate[i];
            if(sp_StepCount != nil)
                BPObj.StepCount = [(NSNumber*)sp_StepCount[i] doubleValue];
        }
        
        [localDataList addObject:BPObj];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //
        });
    }
}

#pragma mark - HealthKit Permissions

// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite
{
//    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
//    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];

    //Blood Pressure
    HKQuantityType *bpSISType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    HKQuantityType *bpDISType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    HKQuantityType *bpHRType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    //Running
    HKQuantityType *bpStepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *bpDistance = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *bpActiveCalories = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    return [NSSet setWithObjects:bpSISType, bpDISType, bpHRType, bpStepType, bpDistance, bpActiveCalories, nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead
{
    HKCharacteristicType *sex = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
//    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];

    //Blood Pressure
    HKQuantityType *bpSISType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    HKQuantityType *bpDISType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    HKQuantityType *bpHRType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    //Running
    HKQuantityType *bpStepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *bpDistance = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *bpActiveCalories = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    return [NSSet setWithObjects:bpSISType, bpDISType, bpHRType, bpStepType, bpDistance, bpActiveCalories, heightType, weightType, sex, nil];
}

#pragma -mark Data Write
- (void)saveBloodPressure:(double)Systolic :(double)Diastolic :(NSDate*)times {

    HKUnit *BloodPressureUnit = [HKUnit millimeterOfMercuryUnit];
    
    HKQuantity *SystolicQuantity = [HKQuantity quantityWithUnit:BloodPressureUnit doubleValue:Systolic];
    HKQuantity *DiastolicQuantity = [HKQuantity quantityWithUnit:BloodPressureUnit doubleValue:Diastolic];
    
    HKQuantityType *SystolicType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    HKQuantityType *DiastolicType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    
    if (times == NULL)
        times = [NSDate date];
    
    HKQuantitySample *SystolicSample = [HKQuantitySample quantitySampleWithType:SystolicType quantity:SystolicQuantity startDate:times endDate:times];
    HKQuantitySample *DiastolicSample = [HKQuantitySample quantitySampleWithType:DiastolicType quantity:DiastolicQuantity startDate:times endDate:times];
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    NSSet *objects=[NSSet setWithObjects:SystolicSample,DiastolicSample, nil];
    HKCorrelationType *bloodPressureType = [HKObjectType correlationTypeForIdentifier:
                                            HKCorrelationTypeIdentifierBloodPressure];
    HKCorrelation *BloodPressure = [HKCorrelation correlationWithType:bloodPressureType startDate:times endDate:times objects:objects];
    [self.healthStore saveObject:BloodPressure withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"An error occured saving the height sample %@. In your app, try to handle this gracefully. The error was: %@.", BloodPressure, error);
            abort();
        }
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    sema = NULL;
}

- (void)setHeartRate:(double)heartRate :(NSDate*)times
{
    if (localDataList != nil)
    {
        HealthData *BPObj = [[HealthData alloc] init];
        BPObj.HeartRate = heartRate;
        [localDataList addObject:BPObj];
        [self saveDataToPref];
    }
    
    //HealthKit
    HKUnit *dataUnit = [HKUnit unitFromString:@"count/min"];
    HKQuantity *HRQuantity = [HKQuantity quantityWithUnit:dataUnit doubleValue:heartRate];
    HKQuantityType *HRType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    if (times == NULL)
        times = [NSDate date];
    [self setDataTypeintoHealthStore:dataUnit :HRQuantity :HRType :times :times :heartRate];
}

- (void)setStepCount:(double)stepcount :(NSDate*)times
{
    if (localDataList != nil)
    {
        HealthData *SPObj = [[HealthData alloc] init];
        SPObj.StepCount = stepcount;
        [localDataList addObject:SPObj];
        [self saveDataToPref];
    }
    
    HKUnit *dataUnit = [HKUnit unitFromString:@"count"];
    HKQuantity *Quantity = [HKQuantity quantityWithUnit:dataUnit doubleValue:stepcount];
    HKQuantityType *Type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    if (times == NULL)
        times = [NSDate date];
    [self setDataTypeintoHealthStore:dataUnit :Quantity :Type :times :times :stepcount];
}

- (void)setDistance:(double)meters :(NSDate*)times
{
    if (localDataList != nil)
    {
        HealthData *SPObj = [[HealthData alloc] init];
        SPObj.Distance = meters;
        [localDataList addObject:SPObj];
        [self saveDataToPref];
    }
    
    HKUnit *dataUnit = [HKUnit meterUnit];
    HKQuantity *Quantity = [HKQuantity quantityWithUnit:dataUnit doubleValue:meters];
    HKQuantityType *HRType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    if (times == NULL)
        times = [NSDate date];
    [self setDataTypeintoHealthStore:dataUnit :Quantity :HRType :times :times :meters];
}

- (void)setActiveCalories:(float)KCalories :(NSDate*)times
{
    if (localDataList != nil)
    {
        HealthData *SPObj = [[HealthData alloc] init];
        SPObj.Calories = KCalories;
        [localDataList addObject:SPObj];
        [self saveDataToPref];
    }
    double calories = KCalories * 1000;
    HKUnit *dataUnit = [HKUnit calorieUnit];
    HKQuantity *Quantity = [HKQuantity quantityWithUnit:dataUnit  doubleValue:calories];
    HKQuantityType *HRType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    if (times == NULL)
        times = [NSDate date];
    [self setDataTypeintoHealthStore:dataUnit :Quantity :HRType :times :times :calories];
}

- (void)setDataTypeintoHealthStore:(HKUnit*) dataUnit :(HKQuantity *)dataQuantity :(HKQuantityType*) dataQuantityType :(NSDate*) startDate :(NSDate*) endDate :(double)value  {
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    HKQuantitySample *BPDiastolicSample = [HKQuantitySample quantitySampleWithType:dataQuantityType
                                                                          quantity:dataQuantity
                                                                         startDate:startDate
                                                                           endDate:endDate];
    
    [self.healthStore saveObject:BPDiastolicSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"An error occured saving the sample %@. In your app, try to handle this gracefully. The error was: %@.", dataQuantityType, error);
            abort();
        }
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    sema = NULL;
}

#pragma -mark Data Read
- (double)getGender
{
    NSError *err = [[NSError alloc] init];
    HKBiologicalSexObject *gender = [self.healthStore biologicalSexWithError:&err];
    return  (double)gender.biologicalSex;
}


- (double)getWeight
{
    HKQuantityType *HealthType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKUnit *HealthUnit = [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo];
    return [self getMostRecentWithTypeUnit:HealthType :HealthUnit];
}

- (double)getHeight
{
    HKQuantityType *HealthType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKUnit *HealthUnit = [HKUnit meterUnit];
    return [self getMostRecentWithTypeUnit:HealthType :HealthUnit] * 100;
}

- (double)getMostRecentActiveCalories
{
    HKQuantityType *DistanceType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKUnit *DistanceUnit = [HKUnit calorieUnit];
    return [self getMostRecentWithTypeUnit:DistanceType :DistanceUnit];
}

- (double)getMostRecentDistance
{
    HKQuantityType *DistanceType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKUnit *DistanceUnit = [HKUnit meterUnit];
    return [self getMostRecentWithTypeUnit:DistanceType :DistanceUnit];
}

- (double)getMostRecentStepCount
{
    HKQuantityType *HeartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKUnit *HeartRateUnit = [HKUnit unitFromString:@"count"];
    return [self getMostRecentWithTypeUnit:HeartRateType :HeartRateUnit];
}


- (double)getMostRecentHeartRate
{
    HKQuantityType *HeartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKUnit *HeartRateUnit = [HKUnit unitFromString:@"count/min"];
    return [self getMostRecentWithTypeUnit:HeartRateType :HeartRateUnit];
}

- (double)getMostRecentBloodPressureSIS
{
    HKQuantityType *BPType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    HKUnit *BPUnit = [HKUnit millimeterOfMercuryUnit];
    return [self getMostRecentWithTypeUnit:BPType :BPUnit];
}
- (double)getMostRecentBloodPressureDIS
{
    HKQuantityType *BPType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    HKUnit *BPUnit = [HKUnit millimeterOfMercuryUnit];
    return [self getMostRecentWithTypeUnit:BPType :BPUnit];
}

- (double)getMostRecentWithTypeUnit:(HKQuantityType*) dataType :(HKUnit*) dataUnit
{
    __block double retData = 0;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self getMostRecentQuantitySampleOfType:dataType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        if (!mostRecentQuantity) {
            NSLog(@"Either an error occured fetching the user information or none has been stored yet. In your app, try to handle this gracefully.");
            retData = 0;
            dispatch_semaphore_signal(sema);
        }
        else {
            double userData = [mostRecentQuantity doubleValueForUnit:dataUnit];
            // Update the user interface.
            retData = userData;
            dispatch_semaphore_signal(sema);
        }
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    sema = NULL;
    return retData;
}

- (void)getMostRecentQuantitySampleOfType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate completion:(void (^)(HKQuantity *, NSError *))completion {
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    // Since we are interested in retrieving the user's latest sample, we sort the samples in descending order, and set the limit to 1. We are not filtering the data, and so the predicate is set to nil.
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType predicate:nil limit:1 sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            if (completion) {
                completion(nil, error);
            }
            
            return;
        }
        
        if (completion) {
            // If quantity isn't in the database, return nil in the completion block.
            HKQuantitySample *quantitySample = results.firstObject;
            HKQuantity *quantity = quantitySample.quantity;
            completion(quantity, error);
        }
    }];
    
    [self.healthStore executeQuery:query];
}

@end
