#import "DJIWaypointConfigViewController.h"

@interface DJIWaypointConfigViewController ()

@end

@implementation DJIWaypointConfigViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    self.nameTextField.text = @""; //Set the name to "" (Default)
    self.resolutionTextField.text = @"1"; //Set the resolution to 1 (Default)
    self.widthTextField.text = @"15"; //Set the width to 15 meters (default)
    
}


- (IBAction)cancelBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(cancelBtnActionInDJIWaypointConfigViewController:)]) {
        [_delegate cancelBtnActionInDJIWaypointConfigViewController:self];
    }
}

- (IBAction)finishBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(finishBtnActionInDJIWaypointConfigViewController:)]) {
        NSMutableString *content = [NSMutableString string];
        [content appendFormat:@"%@", [NSString stringWithFormat: @"%@%@%@", @"R[", self.resolutionTextField.text, @"]"]];
        [content appendFormat:@"%@", [NSString stringWithFormat: @"%@%@%@", @"W[", self.widthTextField.text, @"]"]];
        [content appendFormat:@"%@", [NSString stringWithFormat: @"%@%@%@", @"N[", self.nameTextField.text, @"]||"]];
        //Get the documents directory:
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"waypoints.txt"];
        
        //Append the string to the file, if no file then create it
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
        if (fileHandle){
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandle closeFile];
        }
        else{
            [content writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
        }
        [_delegate finishBtnActionInDJIWaypointConfigViewController:self];
    }
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
