#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MissionViewMode) {
    MissionViewMode_ViewMode,
    MissionViewMode_EditMode,
};

@class MissionButtonViewController;

@protocol MissionButtonViewControllerDelegate <NSObject>

- (void)clearBtnActionInGSButtonVC:(MissionButtonViewController *)GSBtnVC;
- (void)focusMapBtnActionInGSButtonVC:(MissionButtonViewController *)GSBtnVC;
- (void)addBtn:(UIButton *)button withActionInGSButtonVC:(MissionButtonViewController *)GSBtnVC;
- (void)saveBtnActionInGSButtonVC:(MissionButtonViewController *)GSBtnVC;
- (void)switchToMode:(MissionViewMode)mode inGSButtonVC:(MissionButtonViewController *)GSBtnVC;

/// <----------Not needed right now---------->
//- (void)stopBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
//- (void)loadBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
//- (void)saveBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
//- (void)startBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;

@end

@interface MissionButtonViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIButton *focusMapBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
/// <----------Not needed right now---------->
//@property (weak, nonatomic) IBOutlet UIButton *backBtn;
//@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
//@property (weak, nonatomic) IBOutlet UIButton *editBtn;
//@property (weak, nonatomic) IBOutlet UIButton *startBtn;
//@property (weak, nonatomic) IBOutlet UIButton *loadBtn;
//@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (assign, nonatomic) MissionViewMode mode;
@property (weak, nonatomic) id <MissionButtonViewControllerDelegate> delegate;

- (IBAction)clearBtnAction:(id)sender;
- (IBAction)focusMapBtnAction:(id)sender;
- (IBAction)addBtnAction:(id)sender;
- (IBAction)saveBtnAction:(id)sender;
/// <----------Not needed right now---------->
//- (IBAction)loadBtnAction:(id)sender;
//- (IBAction)saveBtnAction:(id)sender;
//- (IBAction)backBtnAction:(id)sender;
//- (IBAction)stopBtnAction:(id)sender;
//- (IBAction)editBtnAction:(id)sender;
//- (IBAction)startBtnAction:(id)sender;


@end

