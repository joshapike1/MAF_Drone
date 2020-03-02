#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>
#import "DJIRootViewController.h"
#import "MissionViewController.h"

@implementation DemoUtility

+(DJIFlightController*) fetchFlightController {
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).flightController;
    }
    
    return nil;
}

@end
