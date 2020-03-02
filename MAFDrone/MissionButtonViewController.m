#import "MissionButtonViewController.h"

@implementation MissionButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be rUIAlertViewecreated.
}

#pragma mark - IBAction Methods

- (IBAction)uploadBtnAction:(id)sender {

    if ([_delegate respondsToSelector:@selector(uploadBtnActionInGSButtonVC:)]) {
        [_delegate uploadBtnActionInGSButtonVC:self];
    }
}

- (IBAction)startBtnAction:(id)sender {

    if ([_delegate respondsToSelector:@selector(startBtnActionInGSButtonVC:)]) {
        [_delegate startBtnActionInGSButtonVC:self];
    }
}

- (IBAction)stopBtnAction:(id)sender {

    if ([_delegate respondsToSelector:@selector(stopBtnActionInGSButtonVC:)]) {
        [_delegate stopBtnActionInGSButtonVC:self];
    }

}

@end

