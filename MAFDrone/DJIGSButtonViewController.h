#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DJIGSViewMode) {
    DJIGSViewMode_ViewMode,
    DJIGSViewMode_EditMode,
};

@class DJIGSButtonViewController;

@protocol DJIGSButtonViewControllerDelegate <NSObject>

- (void)clearBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)focusMapBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)addBtn:(UIButton *)button withActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)saveBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)switchToMode:(DJIGSViewMode)mode inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;

/// <----------Not needed right now---------->
//- (void)stopBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
//- (void)loadBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
//- (void)saveBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
//- (void)startBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;

@end

@interface DJIGSButtonViewController : UIViewController

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

@property (assign, nonatomic) DJIGSViewMode mode;
@property (weak, nonatomic) id <DJIGSButtonViewControllerDelegate> delegate;

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
