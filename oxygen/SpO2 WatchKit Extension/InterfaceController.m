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
    HKSampleType *type;
    HKHealthStore *currentStore;
    HKAnchoredObjectQuery *currentQuery;
    HKAnchoredObjectQuery *currentO2Query;
}

@end


@implementation InterfaceController
@synthesize startStopButton;
@synthesize spo2Label;
@synthesize testTimeLabel;
-(void)startTest{
    //立即开会测量不成功
    NSDate *startDate = [NSDate dateWithTimeInterval:-1000.f sinceDate:[NSDate date]];
//    startDate = [NSDate now];
    startDate = nil;
    NSPredicate *datePredicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:nil options:HKQueryOptionStrictStartDate];

    NSSet *devicesSet = [NSSet setWithArray:@[[HKDevice localDevice]]];
    NSPredicate *devicePredicate = [HKQuery predicateForObjectsFromDevices:devicesSet];
    NSPredicate *p = [NSCompoundPredicate andPredicateWithSubpredicates:@[devicePredicate,datePredicate]];

    
//    HKElectrocardiogramQuery *currentQuery = [[HKElectrocardiogramQuery alloc] initWithElectrocardiogram:[HKSampleType electrocardiogramType] dataHandler:^(HKElectrocardiogramQuery * _Nonnull query, HKElectrocardiogramVoltageMeasurement * _Nullable voltageMeasurement, BOOL done, NSError * _Nullable error) {
//        return;
//    }];
    
    
//    HKQuantityType *o2type=[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
//    HKQueryDescriptor *o = [[HKQueryDescriptor alloc] initWithSampleType:o2type predicate:p];
//    HKQueryDescriptor *s = [[HKQueryDescriptor alloc] initWithSampleType:type predicate:p];
//    /* 如果 血氧和心率在一起请求，则不会返回 updateHandler */
//    currentQuery = [[HKAnchoredObjectQuery alloc] initWithQueryDescriptors:@[o,s] anchor:nil limit:HKObjectQueryNoLimit resultsHandler:^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable sampleObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
//        NSLog(@"res");
//        return;
//    }];
    
    currentQuery = [[HKAnchoredObjectQuery alloc] initWithType:type predicate:p anchor:nil limit:HKObjectQueryNoLimit resultsHandler:^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable sampleObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
        NSLog(@"Count:%lu", (unsigned long)sampleObjects.count);
        NSLog(@"%@", sampleObjects.lastObject);
        if (error){
            NSLog(@"Query Error:%@", error);
            return;
        }
    }];

    currentQuery.updateHandler = ^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable addedObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
        //gotted update HeartRate 30 Dec 2021
        NSLog(@"HeartRate Append result:%@", addedObjects);
        return;
    };
    
    
//    currentO2Query = [[HKAnchoredObjectQuery alloc] initWithType:o2type predicate:p anchor:nil limit:HKObjectQueryNoLimit resultsHandler:^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable sampleObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
//        NSLog(@"Count:%lu", (unsigned long)sampleObjects.count);
//        NSLog(@"%@", sampleObjects.lastObject);
//        if (error){
//            NSLog(@"Query Error:%@", error);
//            return;
//        }
//    }];
//    currentO2Query.updateHandler = ^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable addedObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
//        NSLog(@"Oxygen Append result:%@", addedObjects);
//        //Can NOT got Oxygen. Why?
//        return;
//    };
    
    if (nil == currentStore){
        currentStore = [[HKHealthStore alloc] init];
    }
    NSLog(@"Query started.");
    [currentStore executeQuery:currentQuery];
//    [currentStore executeQuery:currentO2Query];
    return;
}

-(void)startHistory{
    //查询历史
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
        NSPredicate *datePredicate = [HKQuery predicateForSamplesWithStartDate:nil endDate:nil options:HKQueryOptionStrictStartDate];
    //Search history
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:datePredicate limit:HKObjectQueryNoLimit sortDescriptors:@[sort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        if (error){
            NSLog(@"Query error:%@",error);
            return;
        }
        NSLog(@"Query results:%lu", (unsigned long)results.count);
        
        for (HKSample *sample in results){
            if ([sample isKindOfClass:[HKDiscreteQuantitySample class]]){
                NSLog(@"Sample: %@", sample);
                
                HKDiscreteQuantitySample *s = (HKDiscreteQuantitySample *)sample;
                double f = [[s averageQuantity] doubleValueForUnit:[HKUnit percentUnit]];
                NSLog(@"Oxygen is %.1f%%", f * 100.f);
                [self->spo2Label setText:[NSString stringWithFormat:@"%.1f%%", f * 100.f]];
                
                NSLog(@"Test Date is:%@", s.startDate);
                NSTimeInterval ago = [[NSDate date] timeIntervalSinceDate:s.startDate];
                NSLog(@"At %.f sec ago.", ago);
                [self->testTimeLabel setText:[NSString stringWithFormat:@"%.0f sec ago", ago]];
                
                //Device
                NSLog(@"Test From:%@", sample.device.name);
                NSLog(@"Test At Apple Watch:%@", sample.device.hardwareVersion);
                NSLog(@"Test Running Watch OS:%@", sample.device.softwareVersion);
                
                //sourceRevision
        //        NSLog(@"System:%@", sample.sourceRevision.operatingSystemVersion);
                NSLog(@"Product:%@", sample.sourceRevision.productType);
                
                NSLog(@"Meta:%@",sample.metadata);
                //HKMetadataKeyBarometricPressure 血氧 Meta kPa
                
                //心率Meta
//                HKMetadataKeyHeartRateMotionContext
            }else{
                NSLog(@"need debug");
            }
        }
        return;
    }];
    if (nil == currentStore){
        currentStore = [[HKHealthStore alloc] init];
    }
    NSLog(@"Query started.");
    [currentStore executeQuery:query];
}

-(void)startQuery{
    [self startTest];
    return;
    
    [self startHistory];
    return;

}

-(void)stopQuery{
    HKAnchoredObjectQuery *query = currentQuery;
    if (nil == currentStore){
        currentStore = [[HKHealthStore alloc] init];
    }
    [currentStore stopQuery:query];
    currentQuery = nil;
    return;
}

-(IBAction)buttonAction{
    if (nil != currentQuery){
        //Querying now.
        [startStopButton setEnabled:NO];
        [self stopQuery];
        NSLog(@"Query stopped.");
        [startStopButton setTitle:@"SpO2 start"];
        [startStopButton setEnabled:YES];
        return;
    }
    if (NO == [self chectAuthorization]){
        return;
    }
    [startStopButton setEnabled:NO];
    [self startQuery];
    [startStopButton setTitle:@"SpO2 stop"];
    [spo2Label setText:@"--"];
    [testTimeLabel setText:@"..."];
    [startStopButton setEnabled:YES];
    return;
}

-(BOOL)chectAuthorization{
    NSSet *set = [[NSSet alloc] initWithArray:@[type]];
    if (nil == currentStore){
        currentStore = [[HKHealthStore alloc] init];
    }
    HKAuthorizationStatus authorization = [currentStore authorizationStatusForType:type];
    switch (authorization) {
        case HKAuthorizationStatusSharingAuthorized:
            NSLog(@"All Authorized");
            return YES;
            break;
        case HKAuthorizationStatusSharingDenied:
            NSLog(@"Sharing Denied.");
            return YES;
        case HKAuthorizationStatusNotDetermined:
            NSLog(@"No Authorization");
        default:
            break;
    }
    
    [currentStore requestAuthorizationToShareTypes:nil readTypes:set completion:^(BOOL success, NSError * _Nullable error) {
        if (error){
            NSLog(@"Authorization Error:%@", error);
            return;
        }
        if (success && nil == self->currentQuery){
            NSLog(@"Query from app start.");
            [self->startStopButton setEnabled:YES];
            [self performSelectorOnMainThread:@selector(buttonAction) withObject:nil waitUntilDone:NO];
        }else{
            NSLog(@"Unsuccess.");
        }
    }];
    return NO;
}

- (void)awakeWithContext:(id)context {
    NSLog(@"awake");
    
//    HKQuantityTypeIdentifierVO2Max 有氧势能
//    HKQuantityTypeIdentifierBodyTemperature 体温
    
//    type = [HKSampleType electrocardiogramType];
//    type=[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierVO2Max];
//    NSLog(@"Current Type is Testing.");
//    type = [HKElectrocardiogram initialize];
    
//    type=[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
//    NSLog(@"Current Type is Oxygen");
    
    type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSLog(@"Current Type is HeartRate");
    return;
}

- (void)willActivate {
//    NSLog(@"willActivate");
    return;
}

- (void)didDeactivate {
//    NSLog(@"didDeactivate");
    return;
}

@end



