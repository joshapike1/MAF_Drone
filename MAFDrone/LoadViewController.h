#import <UIKit/UIKit.h>
#import "FlightPlanner.h"
#include <CoreLocation/CoreLocation.h>
@class LoadViewController;

@protocol LoadViewControllerDelegate <NSObject>

- (void)loadBtnActionInLoadViewController:(LoadViewController *)GSBtnVC;
- (void)detailsBtnActionInLoadViewController:(LoadViewController *)GSBtnVC;

@end
 
@interface LoadViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *loadBtn;
@property (weak, nonatomic) IBOutlet UIButton *detailsMapBtn;

@property (weak, nonatomic) id <LoadViewControllerDelegate> delegate;

- (IBAction)loadBtnAction:(id)sender;
- (IBAction)detailsMapBtnAction:(id)sender;
 
@end
