#import <UIKit/UIKit.h>
#import "FlightPlanner.h"

@interface MissionViewController : UIViewController

- (void) ShowMessage:(NSString*)title message:(NSString*) message actionTitle:(NSString*) cancleBtnTitle;
- (void) populateMaplat1: (double)lat1 lon1: (double)lon1 lat2: (double)lat2 lon2: (double)lon2;
@end

