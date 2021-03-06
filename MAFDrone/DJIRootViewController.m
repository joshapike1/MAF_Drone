#import "DJIRootViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJISDK.h>
#import "DJIMapController.h"
#import "DJIGSButtonViewController.h"
#import "DJIWaypointConfigViewController.h"
#import "DemoUtility.h"
#import "FlightPlanner.h"

#define ENTER_DEBUG_MODE 0

@interface DJIRootViewController ()<DJIGSButtonViewControllerDelegate, DJIWaypointConfigViewControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, DJISDKManagerDelegate, DJIFlightControllerDelegate>

@property (nonatomic, assign) BOOL isEditingPoints;
@property (nonatomic, strong) DJIGSButtonViewController *gsButtonVC;
@property (nonatomic, strong) DJIWaypointConfigViewController *waypointConfigVC;
@property (nonatomic, strong) DJIMapController *mapController;

@property(nonatomic, strong) CLLocationManager* locationManager;
@property(nonatomic, assign) CLLocationCoordinate2D userLocation;
@property(nonatomic, assign) CLLocationCoordinate2D droneLocation;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property(nonatomic, strong) IBOutlet UILabel* modeLabel;
@property(nonatomic, strong) IBOutlet UILabel* gpsLabel;
@property(nonatomic, strong) IBOutlet UILabel* hsLabel;
@property(nonatomic, strong) IBOutlet UILabel* vsLabel;
@property(nonatomic, strong) IBOutlet UILabel* altitudeLabel;

@property(nonatomic, strong) DJIMutableWaypointMission* waypointMission;
@end

@implementation DJIRootViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startUpdateLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //_mapView.mapType = MKMapTypeHybrid;
    
    [self registerApp];
    
    [self initUI];
    [self initData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark Init Methods

-(void)initData
{
    self.userLocation = kCLLocationCoordinate2DInvalid;
    self.droneLocation = kCLLocationCoordinate2DInvalid;
    
    self.mapController = [[DJIMapController alloc] init];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addWaypoints:)];
    [self.mapView addGestureRecognizer:self.tapGesture];
}

-(void) initUI
{
    self.modeLabel.text = @"N/A";
    self.gpsLabel.text = @"0";
    self.vsLabel.text = @"0.0 M/S";
    self.hsLabel.text = @"0.0 M/S";
    self.altitudeLabel.text = @"0 M";
    
    self.gsButtonVC = [[DJIGSButtonViewController alloc] initWithNibName:@"DJIGSButtonViewController" bundle:[NSBundle mainBundle]];
    [self.gsButtonVC.view setFrame:CGRectMake(0, self.topBarView.frame.origin.y + self.topBarView.frame.size.height, self.gsButtonVC.view.frame.size.width, self.gsButtonVC.view.frame.size.height)];
    self.gsButtonVC.delegate = self;
    [self.view addSubview:self.gsButtonVC.view];
    
    self.waypointConfigVC = [[DJIWaypointConfigViewController alloc] initWithNibName:@"DJIWaypointConfigViewController" bundle:[NSBundle mainBundle]];
    self.waypointConfigVC.view.alpha = 0;
    self.waypointConfigVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    [self.waypointConfigVC.view setCenter:self.view.center];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) //Check if it's using iPad and center the config view
    {
        self.waypointConfigVC.view.center = self.view.center;
    }
    
    self.waypointConfigVC.delegate = self;
    [self.view addSubview:self.waypointConfigVC.view];
}

-(void) registerApp
{
    //Please enter your App key in the info.plist file to register the app.
    [DJISDKManager registerAppWithDelegate:self];
}

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


#pragma mark DJISDKManagerDelegate Methods
- (void)appRegisteredWithError:(NSError *)error
{
    if (error){
        NSString *registerResult = [NSString stringWithFormat:@"Registration Error:%@", error.description];
        [self ShowMessage:@"Registration Result" message:registerResult actionTitle:@"OK"];
    }
    else{
#if ENTER_DEBUG_MODE
        [DJISDKManager enableBridgeModeWithBridgeAppIP:@"Please Enter Your Debug ID"];
#else
        [DJISDKManager startConnectionToProduct];
#endif
    }
}

- (void)productConnected:(DJIBaseProduct *)product
{
    if (product){
        DJIFlightController* flightController = [DemoUtility fetchFlightController];
        if (flightController) {
            flightController.delegate = self;
        }
    }else{
        [self ShowMessage:@"Product disconnected" message:nil actionTitle: @"OK"];
    }
    
    //If this demo is used in China, it's required to login to your DJI account to activate the application. Also you need to use DJI Go app to bind the aircraft to your DJI account. For more details, please check this demo's tutorial.
    [[DJISDKManager userAccountManager] logIntoDJIUserAccountWithAuthorizationRequired:NO withCompletion:^(DJIUserAccountState state, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Login failed: %@", error.description);
        }
    }];
    
}

#pragma mark action Methods

-(DJIWaypointMissionOperator *)missionOperator {
    return [DJISDKManager missionControl].waypointMissionOperator;
}

- (void)focusMap
{
    if (CLLocationCoordinate2DIsValid(self.droneLocation)) {
        MKCoordinateRegion region = {0};
        region.center = self.droneLocation;
        region.span.latitudeDelta = 0.001;
        region.span.longitudeDelta = 0.001;
        
        [self.mapView setRegion:region animated:YES];
    }
}

#pragma mark CLLocation Methods
-(void) startUpdateLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        if (self.locationManager == nil) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = 0.1;
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
            [self.locationManager startUpdatingLocation];
        }
    }else
    {
        [self ShowMessage:@"Location Service is not available" message:@"" actionTitle:@"OK"];
    }
}

#pragma mark UITapGestureRecognizer Methods
- (void)addWaypoints:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:self.mapView];
    
    if(tapGesture.state == UIGestureRecognizerStateEnded){
        if (self.isEditingPoints)
            [self.mapController addPoint:point withMapView:self.mapView];
    }
}

#pragma mark - DJIWaypointConfigViewControllerDelegate Methods

- (void)cancelBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC
{
    WeakRef(weakSelf);
    
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.waypointConfigVC.view.alpha = 0;
    }];
    
}

- (void)showAlertViewWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)finishBtnActionInDJIWaypointConfigViewController:(DJIWaypointConfigViewController *)waypointConfigVC
{
    WeakRef(weakSelf);
    
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.waypointConfigVC.view.alpha = 0;
    }];
    
    if (self.waypointMission.waypointCount != 2) {
        [self ShowMessage:@"" message:@"You must have exactly two waypoints to configure, on each end of the runway" actionTitle:@"OK"];
        return;
    }
    
    CLLocationCoordinate2D c1 = [[self.waypointMission waypointAtIndex: 0] coordinate];
    CLLocationCoordinate2D c2 = [[self.waypointMission waypointAtIndex: 1] coordinate];
    
    if ([FlightPlanner distBetweenCoords:c1 to:c2] > 5000) {
        [self ShowMessage:@"" message:@"Survey over 5000m length limit" actionTitle:@"OK"];
        return;
    }
    
    //WOAH ZONE:
    double res = 1.0;
    double width = 15.0;
    
    
    if ([[FlightPlanner generateWaypointMission: c1 to: c2 resolution:res width:width] count] > 98) {
        [self ShowMessage:@"" message:@"Mission would have over 98 waypoints - would be unable to create a waypoint Mission" actionTitle:@"OK"];
        return;
    }
    
    for (int i = 0; i < self.waypointMission.waypointCount; i++) {
        DJIWaypoint* waypoint = [self.waypointMission waypointAtIndex:i];
        
        ///<-------------------NEEDS TO BE CALCULATED--------------------------->
        waypoint.altitude = 10; //Set altitude to 10m
    }
    
    self.waypointMission.maxFlightSpeed = 10; //Set max speeed to 10m/s
    self.waypointMission.autoFlightSpeed = 5; //Set auto flight speed to 5m/s
    
//    self.waypointMission.headingMode = (DJIWaypointMissionHeadingMode)self.waypointConfigVC.headingSegmentedControl.selectedSegmentIndex;
//    [self.waypointMission setFinishedAction:(DJIWaypointMissionFinishedAction)self.waypointConfigVC.actionSegmentedControl.selectedSegmentIndex];
    
    ///<--------------------------Not Needed for saving mission which is what this method does, will need for loading missions to drone----------------------------->
    //    [[self missionOperator] loadMission:self.waypointMission];
    //
    //    WeakRef(target);
    //
    //    [[self missionOperator] addListenerToFinished:self withQueue:dispatch_get_main_queue() andBlock:^(NSError * _Nullable error) {
    //
    //        WeakReturn(target);
    //
    //        if (error) {
    //            [target showAlertViewWithTitle:@"Mission Execution Failed" withMessage:[NSString stringWithFormat:@"%@", error.description]];
    //        }
    //        else {
    //            [target showAlertViewWithTitle:@"Mission Execution Finished" withMessage:nil];
    //        }
    //    }];
    //
    //    [[self missionOperator] uploadMissionWithCompletion:^(NSError * _Nullable error) {
    //        if (error){
    //            NSString* uploadError = [NSString stringWithFormat:@"Upload Mission failed:%@", error.description];
    //            [self ShowMessage:@"" message:uploadError actionTitle:@"OK"];
    //        }else {
    //            [self ShowMessage:@"" message:@"Upload Mission Finished" actionTitle:@"OK"];
    //        }
    //    }];
    
    ///<-----------Saving the waypoints to a text file-------------->
    //New line is created with string to append
    NSArray* wayPoints = self.mapController.wayPoints;
    NSMutableString *content = [NSMutableString string];
    
    for (int i = 0; i < wayPoints.count; i++) {
        NSString *haystack = [NSString stringWithFormat:@"%@",wayPoints[i]];
        NSString *prefix = @"<";
        NSString *suffix = @">";
        NSRange prefixRange = [haystack rangeOfString:prefix];
        NSRange suffixRange = [[haystack substringFromIndex:prefixRange.location+prefixRange.length] rangeOfString:suffix];
        NSRange needleRange = NSMakeRange(prefixRange.location+prefix.length, suffixRange.location);
        NSString *needle = [haystack substringWithRange:needleRange];
        NSLog(@"needle: %@", needle);
        
        
        [content appendFormat:@"%@", [NSString stringWithFormat: @"%@%@%d%@", needle, @"|", i, @"|"]];
    }
    
    [content appendFormat:@"%@", [NSString stringWithFormat: @"%@", @";\n"]];
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
    
    //Switch storyboards
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"IntroController"];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - DJIGSButtonViewController Delegate Methods

///<------Old save and load buttons------>
//
//-(void)loadBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC {
//    [self loadMissions];
//}

//Old save button
//-(void)saveBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC {
//    [self saveMission];
//}
//________________________________________________________________________//

///<------Stop and start buttons not needed right now------>
//- (void)stopBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
//{
//    [[self missionOperator] stopMissionWithCompletion:^(NSError * _Nullable error) {
//        if (error){
//            [self ShowMessage:@"" message:@"Mission cannot be stopped" actionTitle:@"OK"];
//        }else
//        {
//            [self ShowMessage:@"" message:@"Mission stopped" actionTitle:@"OK"];
//        }
//
//    }];
//
//}

//- (void)startBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
//{
//    [[self missionOperator] startMissionWithCompletion:^(NSError * _Nullable error) {
//        if (error){
//            [self ShowMessage:@"Start Mission Failed" message:error.description actionTitle:@"OK"];
//        }else
//        {
//            [self ShowMessage:@"" message:@"Mission Started" actionTitle:@"OK"];
//        }
//    }];
//
//}

- (void)clearBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [self.mapController cleanAllPointsWithMapView:self.mapView];
}

- (void)focusMapBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    [self focusMap];
}

- (void)saveBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    WeakRef(weakSelf);
    
    NSArray* wayPoints = self.mapController.wayPoints;
    if (wayPoints == nil || wayPoints.count < 2) { //DJIWaypointMissionMinimumWaypointCount is 2.
        [self ShowMessage:@"No or not enough waypoints for mission" message:@"" actionTitle:@"OK"];
        return;
    }
    if (wayPoints.count > 2) {
        [self ShowMessage:@"Too many waypoints" message:@"" actionTitle:@"OK"];
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        WeakReturn(weakSelf);
        weakSelf.waypointConfigVC.view.alpha = 1.0;
    }];
    
    if (self.waypointMission){
        [self.waypointMission removeAllWaypoints];
    }
    else{
        self.waypointMission = [[DJIMutableWaypointMission alloc] init];
    }
    
    //USE THIS FOR LOADING MISSIONS____________________________________________________///////
    for (int i = 0; i < wayPoints.count; i++) {
        CLLocation* location = [wayPoints objectAtIndex:i];
        if (CLLocationCoordinate2DIsValid(location.coordinate)) {
            DJIWaypoint* waypoint = [[DJIWaypoint alloc] initWithCoordinate:location.coordinate];
            [self.waypointMission addWaypoint:waypoint];
        }
    }
    
}

- (void)switchToMode:(DJIGSViewMode)mode inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    if (mode == DJIGSViewMode_EditMode) {
        [self focusMap];
    }
    
}

- (void)addBtn:(UIButton *)button withActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC
{
    if (self.isEditingPoints) {
        self.isEditingPoints = NO;
        [button setTitle:@"Add" forState:UIControlStateNormal];
    }else
    {
        self.isEditingPoints = YES;
        [button setTitle:@"Done" forState:UIControlStateNormal];
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    self.userLocation = location.coordinate;
}

#pragma mark MKMapViewDelegate Method
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin_Annotation"];
        pinView.pinTintColor = [UIColor purpleColor];
        return pinView;
        
    }else if ([annotation isKindOfClass:[DJIAircraftAnnotation class]])
    {
        DJIAircraftAnnotationView* annoView = [[DJIAircraftAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Aircraft_Annotation"];
        ((DJIAircraftAnnotation*)annotation).annotationView = annoView;
        return annoView;
    }
    
    return nil;
}

#pragma mark DJIFlightControllerDelegate

- (void)flightController:(DJIFlightController *)fc didUpdateState:(DJIFlightControllerState *)state
{
    self.droneLocation = state.aircraftLocation.coordinate;
    self.modeLabel.text = state.flightModeString;
    self.gpsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)state.satelliteCount];
    self.vsLabel.text = [NSString stringWithFormat:@"%0.1f M/S",state.velocityZ];
    self.hsLabel.text = [NSString stringWithFormat:@"%0.1f M/S",(sqrtf(state.velocityX*state.velocityX + state.velocityY*state.velocityY))];
    self.altitudeLabel.text = [NSString stringWithFormat:@"%0.1f M",state.altitude];
    
    [self.mapController updateAircraftLocation:self.droneLocation withMapView:self.mapView];
    double radianYaw = RADIAN(state.attitude.yaw);
    [self.mapController updateAircraftHeading:radianYaw];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


@end

