#import "MissionButtonViewController.h"

@implementation MissionButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setMode:MissionViewMode_ViewMode];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be rUIAlertViewecreated.
}

#pragma mark - Property Method

- (void)setMode:(MissionViewMode)mode
{
    
    _mode = mode;
    [_focusMapBtn setHidden:(mode == MissionViewMode_EditMode)];
    [_clearBtn setHidden:(mode == MissionViewMode_EditMode)];
    [_addBtn setHidden:(mode == MissionViewMode_EditMode)];
    [_saveBtn setHidden:(mode == MissionViewMode_EditMode)];
    ///<--------Not needed right now-------->
    //    [_loadBtn setHidden:(mode == DJIGSViewMode_ViewMode)];
    //    [_saveBtn setHidden:(mode == DJIGSViewMode_ViewMode)];
    //    [_editBtn setHidden:(mode == DJIGSViewMode_EditMode)];
    //    [_backBtn setHidden:(mode == DJIGSViewMode_ViewMode)];
    //    [_startBtn setHidden:(mode == DJIGSViewMode_PreFlyMode)];
    //    [_stopBtn setHidden:(mode == DJIGSViewMode_FlyMode)];
}

#pragma mark - IBAction Methods

- (IBAction)clearBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(clearBtnActionInGSButtonVC:)]) {
        [_delegate clearBtnActionInGSButtonVC:self];
    }
    
}

- (IBAction)focusMapBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(focusMapBtnActionInGSButtonVC:)]) {
        [_delegate focusMapBtnActionInGSButtonVC:self];
    }
}

- (IBAction)addBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(addBtn:withActionInGSButtonVC:)]) {
        [_delegate addBtn:self.addBtn withActionInGSButtonVC:self];
    }
    
}

// New save button
- (IBAction)saveBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(saveBtnActionInGSButtonVC:)]) {
        [_delegate saveBtnActionInGSButtonVC:self];
    }
}

///<------Not needed right now------>
//- (IBAction)editBtnAction:(id)sender {
//
//    [self setMode:DJIGSViewMode_EditMode];
//    if ([_delegate respondsToSelector:@selector(switchToMode:inGSButtonVC:)]) {
//        [_delegate switchToMode:self.mode inGSButtonVC:self];
//    }
//
//}

//Not needed here
//- (IBAction)startBtnAction:(id)sender {
//
//    if ([_delegate respondsToSelector:@selector(startBtnActionInGSButtonVC:)]) {
//        [_delegate startBtnActionInGSButtonVC:self];
//    }
//}

//Added method definitions for load and save buttons
//- (IBAction)loadBtnAction:(id)sender {
//    [self setMode:DJIGSViewMode_ViewMode];
//    if ([_delegate respondsToSelector:@selector(loadBtnActionInGSButtonVC:)]) {
//        [_delegate loadBtnActionInGSButtonVC:self];
//    }
//}

//Old save button
//- (IBAction)saveBtnAction:(id)sender {
//    [self setMode:DJIGSViewMode_ViewMode];
//    if ([_delegate respondsToSelector:@selector(saveBtnActionInGSButtonVC:)]) {
//        [_delegate saveBtnActionInGSButtonVC:self];
//    }
//}

//- (IBAction)backBtnAction:(id)sender {
//    [self setMode:DJIGSViewMode_ViewMode];
//    if ([_delegate respondsToSelector:@selector(switchToMode:inGSButtonVC:)]) {
//        [_delegate switchToMode:self.mode inGSButtonVC:self];
//    }
//}

// Not needed here
//- (IBAction)stopBtnAction:(id)sender {
//
//    if ([_delegate respondsToSelector:@selector(stopBtnActionInGSButtonVC:)]) {
//        [_delegate stopBtnActionInGSButtonVC:self];
//    }
//
//}

@end

