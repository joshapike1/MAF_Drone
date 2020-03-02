#import <UIKit/UIKit.h>

@class MissionButtonViewController;

@protocol MissionButtonViewControllerDelegate <NSObject>
- (void)uploadBtnActionInGSButtonVC:(MissionButtonViewController *)GSBtnVC;
- (void)stopBtnActionInGSButtonVC:(MissionButtonViewController *)GSBtnVC;
- (void)startBtnActionInGSButtonVC:(MissionButtonViewController *)GSBtnVC;

@end

@interface MissionButtonViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *UploadBtn;
@property (weak, nonatomic) IBOutlet UIButton *StartBtn;
@property (weak, nonatomic) IBOutlet UIButton *StopBtn;

@property (weak, nonatomic) id <MissionButtonViewControllerDelegate> delegate;

- (IBAction)uploadBtnAction:(id)sender;
- (IBAction)startBtnAction:(id)sender;
- (IBAction)stopBtnAction:(id)sender;

@end

