#import <UIKit/UIKit.h>

@class IntroController;

@protocol IntroControllerDelegate <NSObject>

- (void)loadBtnActionInIntroVC:(IntroController *)GSBtnVC;
@end

@interface IntroController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *loadBtn;


@property (weak, nonatomic) id <IntroControllerDelegate> delegate;

- (IBAction)loadBtnAction:(id)sender;


@end
