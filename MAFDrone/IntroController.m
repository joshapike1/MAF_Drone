#import "IntroController.h"

@implementation IntroController

//Load button, here data is sent to the FlightPlanner class
- (IBAction)loadBtnAction:(id)sender {
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"waypoints.txt"];
    NSString *waypointsText = [NSString stringWithContentsOfFile:fileName];

    NSLog(@"Waypoints Texet %@", waypointsText);
    
    if ([waypointsText length] == 0) {
        [self ShowMessage:@"No Missions Saved" message:@"No missions are saved to this device, please create a new one" actionTitle:@"OK"];
    }
    else { //Switch storyboards
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoadViewController"];
        [self presentViewController:vc animated:YES completion:nil];}
}

//Simple message popup
- (void) ShowMessage:(NSString*)title message:(NSString*) message actionTitle:(NSString*) cancleBtnTitle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alert addAction:okButton];
        [self presentViewController:alert animated:(YES) completion:nil];
        
    });
}

@end



