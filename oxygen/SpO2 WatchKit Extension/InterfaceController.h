//
//  InterfaceController.h
//  SpO2 WatchKit Extension
//
//  Created by jia yu on 2021/12/27.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController
@property (nonatomic) IBOutlet WKInterfaceButton *startStopButton;
@property (nonatomic) IBOutlet WKInterfaceLabel *spo2Label;
@property (nonatomic) IBOutlet WKInterfaceLabel *testTimeLabel;

-(IBAction)buttonAction;
@end
