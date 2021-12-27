//
//  InterfaceController.m
//  SpO2 WatchKit Extension
//
//  Created by jia yu on 2021/12/27.
//

#import "InterfaceController.h"
#import "AppleWatchConnectivityManager.h"
#import <HealthKit/HealthKit.h>
@interface InterfaceController (){
}

@end


@implementation InterfaceController
@synthesize startStopButton;

-(IBAction)start{
    NSLog(@"ABC:%@", startStopButton);
    HKSampleType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:nil endDate:nil options:HKQueryOptionStrictEndDate];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[sort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        return;
    }];
    HKHealthStore *store = [[HKHealthStore alloc] init];
    [store executeQuery:query];
    return;
}

- (void)awakeWithContext:(id)context {
    return;
}

- (void)willActivate {
    return;
}

- (void)didDeactivate {
    return;
}

@end



