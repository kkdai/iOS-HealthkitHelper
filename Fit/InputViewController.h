//
//  BPInputViewController.h
//  Fit
//
//  Created by Evan Lin on 2014/12/16.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

@import UIKit;
@import HealthKit;
#import "HealthKitHelper.h"

@interface InputViewController : UITableViewController
@property (nonatomic) HKHealthStore *healthStore;
@property (nonatomic) HealthKitHelper *HLKHelper;
@end
