//
//  BPInputViewController.m
//  Fit
//
//  Created by Evan Lin on 2014/12/16.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "InputViewController.h"

// A mapping of logical sections of the table view to actual indexes.
typedef NS_ENUM(NSInteger, AAPLProfileViewControllerTableViewIndex) {
    AAPLProfileViewControllerTableViewIndexSIS = 0,
    AAPLProfileViewControllerTableViewIndexDIS,
    AAPLProfileViewControllerTableViewIndexHeartRate,
    AAPLProfileViewControllerTableViewIndexStepCount,
    AAPLProfileViewControllerTableViewIndexDistance,
    AAPLProfileViewControllerTableViewIndexActiveCalories
};

@interface InputViewController ()

// Note that the user's age is not editable.
@property (strong, nonatomic) IBOutlet UILabel *SysValueLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *SisValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *DiaValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *HeartRateValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *stepValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *ACaloriesValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *DistanceValueLabel;

@end


@implementation InputViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Set up an HKHealthStore, asking the user for read/write permissions. The profile view controller is the
    // first view controller that's shown to the user, so we'll ask for all of the desired HealthKit permissions now.
    // In your own app, you should consider requesting permissions the first time a user wants to interact with
    // HealthKit data.
    _HLKHelper = [[HealthKitHelper alloc] initKitWithCheckHealthStore:_healthStore :self];
    
    [self updateUsersDISLabel];
    [self updateUserSISLabel];
    [self updateUsersHeartRateLabel];
    [self updateUsersStepCountLabel];
    [self updateUsersDistanceLabel];
    [self updateUsersACaloriesLabel];
}

#pragma mark - Reading HealthKit Data

- (void)updateUsersDISLabel {
    double valueDis = [self.HLKHelper getMostRecentBloodPressureDIS];
   // Update the user interface.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.DiaValueLabel.text = [NSNumberFormatter localizedStringFromNumber:@(valueDis) numberStyle:NSNumberFormatterNoStyle];
    });
}

- (void)updateUserSISLabel {
    double valueSis = [self.HLKHelper getMostRecentBloodPressureSIS];
   // Update the user interface.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.SysValueLabel.text = [NSNumberFormatter localizedStringFromNumber:@(valueSis) numberStyle:NSNumberFormatterNoStyle];
    });
}

- (void)updateUsersHeartRateLabel {
    double valueHR = [self.HLKHelper getMostRecentHeartRate];
    // Update the user interface.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.HeartRateValueLabel.text = [NSNumberFormatter localizedStringFromNumber:@(valueHR) numberStyle:NSNumberFormatterNoStyle];
    });
}

- (void)updateUsersStepCountLabel {
    double valueSP = [self.HLKHelper getMostRecentStepCount];
    // Update the user interface.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.stepValueLabel.text = [NSNumberFormatter localizedStringFromNumber:@(valueSP) numberStyle:NSNumberFormatterNoStyle];
    });
}

- (void)updateUsersDistanceLabel {
    double value = [self.HLKHelper getMostRecentDistance];
    // Update the user interface.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.DistanceValueLabel.text = [NSNumberFormatter localizedStringFromNumber:@(value) numberStyle:NSNumberFormatterNoStyle];
    });
}

- (void)updateUsersACaloriesLabel {
    double value = [self.HLKHelper getMostRecentActiveCalories];
    // Update the user interface.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.ACaloriesValueLabel.text = [NSNumberFormatter localizedStringFromNumber:@(value) numberStyle:NSNumberFormatterNoStyle];
    });
}

#pragma mark - Writing HealthKit Data
- (void)saveBloodPressureDISintoHealthStore:(double)DIS {
    NSLog(@"Input DIS is %02.0f UI SYS is %02.0f", DIS, self.SysValueLabel.text.floatValue);
    [self.HLKHelper saveBloodPressure:self.SysValueLabel.text.floatValue :DIS :NULL];
    [self updateUsersDISLabel];
}

- (void)saveBloodPressureSISintoHealthStore:(double)SIS {
    NSLog(@"Input SIS is %02.0f UI DIA is %02.0f", SIS, self.DiaValueLabel.text.floatValue);
    [self.HLKHelper saveBloodPressure:SIS :self.DiaValueLabel.text.floatValue :NULL];
    [self updateUserSISLabel];
}

- (void)saveBloodHeartRateintoHealthStore:(double)HeartRate {
    [self.HLKHelper setHeartRate:HeartRate :NULL];
    [self updateUsersHeartRateLabel];
}

- (void)saveStepCounttoHealthStore:(double)Stepcount {
    [self.HLKHelper setStepCount:Stepcount :NULL];
    [self updateUsersStepCountLabel];
}

- (void)saveDistancetoHealthStore:(double)distance {
    [self.HLKHelper setDistance:distance :NULL];
    [self updateUsersDistanceLabel];
}

- (void)saveActiveCaloriestoHealthStore:(double)Calories {
    float KCalories = Calories / 1000;
    [self.HLKHelper setActiveCalories:KCalories :NULL];
    [self updateUsersACaloriesLabel];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AAPLProfileViewControllerTableViewIndex index = (AAPLProfileViewControllerTableViewIndex)indexPath.row;
    
    // Set up variables based on what row the user has selected.
    NSString *title;
    void (^valueChangedHandler)(double value);
    if (index == AAPLProfileViewControllerTableViewIndexDIS) {
        title = NSLocalizedString(@"Your DIS", nil);
        
        valueChangedHandler = ^(double value) {
            [self saveBloodPressureDISintoHealthStore:value];
        };
    } else if (index == AAPLProfileViewControllerTableViewIndexSIS) {
        title = NSLocalizedString(@"Your SIS", nil);
        
        valueChangedHandler = ^(double value) {
            [self saveBloodPressureSISintoHealthStore:value];
        };
    } else if (index == AAPLProfileViewControllerTableViewIndexHeartRate) {
        title = NSLocalizedString(@"Your Heart Rate", nil);
        
        valueChangedHandler = ^(double value) {
            [self saveBloodHeartRateintoHealthStore :value];
        };
    } else if (index == AAPLProfileViewControllerTableViewIndexStepCount) {
        title = NSLocalizedString(@"Your Step Count", nil);
        
        valueChangedHandler = ^(double value) {
            [self saveStepCounttoHealthStore:value];
        };
    } else if (index == AAPLProfileViewControllerTableViewIndexDistance) {
        title = NSLocalizedString(@"Your Distance", nil);
        
        valueChangedHandler = ^(double value) {
            [self saveDistancetoHealthStore:value];
        };
    } else if (index == AAPLProfileViewControllerTableViewIndexActiveCalories) {
        title = NSLocalizedString(@"Your Active Calories", nil);
        
        valueChangedHandler = ^(double value) {
            [self saveActiveCaloriestoHealthStore:(float)value];
        };
    }
    
    // Create an alert controller to present.
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    // Add the text field to let the user enter a numeric value.
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // Only allow the user to enter a valid number.
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    
    // Create the "OK" button.
    NSString *okTitle = NSLocalizedString(@"OK", nil);
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        
        double value = textField.text.doubleValue;
        
        valueChangedHandler(value);
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    [alertController addAction:okAction];
    
    // Create the "Cancel" button.
    NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    [alertController addAction:cancelAction];
    
    // Present the alert controller.
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Convenience

- (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *numberFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
    });
    
    return numberFormatter;
}

@end
