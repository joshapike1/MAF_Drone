
#import "MissionViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJISDK.h>
#import "DJIMapController.h"
#import "MissionButtonViewController.h"
//#import "DJIWaypointConfigViewController.h"
#import "DemoUtility.h"
#import <math.h>

#define ENTER_DEBUG_MODE 0

@interface MissionViewController ()<MissionButtonViewControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, DJISDKManagerDelegate, DJIFlightControllerDelegate>

@property (nonatomic, assign) BOOL isEditingPoints;
@property (nonatomic, strong) MissionButtonViewController *gsButtonVC;
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
@property(nonatomic) MAFDistanceHeading headingData;

@end

@implementation MissionViewController

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
    
    //Probably need to run waypoint setting too
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark Init Methods

-(void) registerApp
{
    //Please enter your App key in the info.plist file to register the app.
    [DJISDKManager registerAppWithDelegate:self];
}

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
    
    self.gsButtonVC = [[MissionButtonViewController alloc] initWithNibName:@"MissionButtonViewController" bundle:[NSBundle mainBundle]];
    [self.gsButtonVC.view setFrame:CGRectMake(0, self.topBarView.frame.origin.y + self.topBarView.frame.size.height, self.gsButtonVC.view.frame.size.width, self.gsButtonVC.view.frame.size.height)];
    self.gsButtonVC.delegate = self;
    [self.view addSubview:self.gsButtonVC.view];
}

- (void)CreateMission
{
    NSArray* wayPoints = self.mapController.wayPoints;
    NSLog(@"Num waypoints: %lu", wayPoints.count);
    
    /*if (wayPoints == nil || wayPoints.count < 2) { //DJIWaypointMissionMinimumWaypointCount is 2.
        NSLog(@"Not enough waypoints");
        [self ShowMessage:@"No or not enough waypoints for mission" message:@"Upload Mission Finished" actionTitle:@"OK"];
        return;
    }*/ //Will not be two given the situation we have.
    
    if (self.waypointMission){
        NSLog(@"Deleting waypoints");
        [self.waypointMission removeAllWaypoints];
    }
    else{
        NSLog(@"No old waypoint mission!");
        self.waypointMission = [[DJIMutableWaypointMission alloc] init];
    }
    
    double missionAltitude = [FlightPlanner heightForResolution:_resolution];
    NSLog(@"Altitude: %f", missionAltitude);
    
    double head = self.headingData.heading;
    if (head > 180) {
        head = head - 360;
    }
    
    self.waypointMission.rotateGimbalPitch = YES; //enable moving the camera gimbal
    self.waypointMission.headingMode = DJIWaypointMissionHeadingUsingWaypointHeading;
    for (int i = 0; i < wayPoints.count; i++) {
        CLLocation* location = [wayPoints objectAtIndex:i];
        if (CLLocationCoordinate2DIsValid(location.coordinate)) {
            DJIWaypoint* waypoint = [[DJIWaypoint alloc] initWithCoordinate:location.coordinate];
            waypoint.gimbalPitch = -90.0; //POINT CAMERA STRAIGHT DOWN
            waypoint.heading = head;
            waypoint.altitude = missionAltitude;
            if (i == 0) {
                DJIWaypointAction* a = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeStay param:7000];
                [waypoint addAction:a];
            }
            
            DJIWaypointAction* action = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeShootPhoto param:0]; //param is ignored for this action
            [waypoint addAction: action]; //take a photo at this waypoint
            
            [self.waypointMission addWaypoint:waypoint];
        }
    }
    NSLog(@"Waypoints Added");
}

- (void) ConfigMission {
    
    for (int i = 0; i < self.waypointMission.waypointCount; i++) {
        DJIWaypoint* waypoint = [self.waypointMission waypointAtIndex:i];
        waypoint.altitude = 10; //Set altitude to 10
    }
     NSLog(@"Waypoints added again");
    NSLog(@"ANum waypoints again: %lu", self.waypointMission.waypointCount);
    
    self.waypointMission.maxFlightSpeed = 10; //Set max speeed to 10m/s
    self.waypointMission.autoFlightSpeed = 5; //Set auto flight speed to 5m/s
    NSLog(@"   Max speed and flight speed set");
    
    self.waypointMission.headingMode = DJIWaypointMissionHeadingUsingInitialDirection;
    self.waypointMission.finishedAction = DJIWaypointMissionFinishedGoHome;
    NSLog(@"Heading and finish actino set");
    
    [[self missionOperator] loadMission:self.waypointMission];
    NSLog(@"Mission loading");
    
    WeakRef(target);
    
    [[self missionOperator] addListenerToFinished:self withQueue:dispatch_get_main_queue() andBlock:^(NSError * _Nullable error) {
        
        WeakReturn(target);
        
        if (error) {
            NSLog(@"Mission failed to execute");
            [target showAlertViewWithTitle:@"Mission Execution Failed" withMessage:[NSString stringWithFormat:@"%@", error.description]];
        }
        else {
            NSLog(@"Mission finished executing!");
            [target showAlertViewWithTitle:@"Mission Execution Finished" withMessage:nil];
        }
    }];
    
    [[self missionOperator] uploadMissionWithCompletion:^(NSError * _Nullable error) {
        if (error){
            NSLog(@"Mission failed to upload to drone");
            NSString* uploadError = [NSString stringWithFormat:@"Upload Mission failed:%@", error.description];
            [self ShowMessage:@"" message:uploadError actionTitle:@"OK"];
        }else {
            NSLog(@"Mission uploaded to drone!");
            [self ShowMessage:@"Upload Mission Finished" message:@"Upload Mission Finished" actionTitle:@"OK"];
        }
    }];
}

- (void)StartMission {
    [[self missionOperator] startMissionWithCompletion:^(NSError * _Nullable error) {
        if (error){
            NSLog(@"Mission failed to start");
          [self ShowMessage:@"Start Mission Failed" message:error.description actionTitle:@"OK" ];
        }else
        {
            NSLog(@"Mission loading and starting successful!");
            [self ShowMessage:@"" message:@"Mission Started" actionTitle:@"OK"];
        }
    }];
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

- (void)showAlertViewWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)createMission:(MissionButtonViewController *)GSBtnVC
{
    //WeakRef(weakSelf);
    
    NSArray* wayPoints = self.mapController.wayPoints;
    if (wayPoints == nil || wayPoints.count < 2) { //DJIWaypointMissionMinimumWaypointCount is 2.
        [self ShowMessage:@"No or not enough waypoints for mission" message:@"" actionTitle:@"OK"];
        return;
    }
    
    if (wayPoints.count <= 1) {
        [self ShowMessage:@"" message:@"Not enough waypoints" actionTitle:@"OK"];
        return;
    }
    
    if (wayPoints.count >= 98) {
        [self ShowMessage:@"Too many waypoints" message:@"" actionTitle:@"OK"];
        return;
    }
    
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

#pragma mark - MissionButtonViewController Delegate Methods

- (void)stopBtnActionInGSButtonVC:(MissionButtonViewController *)GSBtnVC
{
    [[self missionOperator] stopMissionWithCompletion:^(NSError * _Nullable error) {
        if (error){
            [self ShowMessage:@"" message:@"Mission cannot be stopped" actionTitle:@"OK"];
        }else
        {
            [self ShowMessage:@"" message:@"Mission stopped" actionTitle:@"OK"];
        }
        
    }];
    
}

- (void)startBtnActionInGSButtonVC:(MissionButtonViewController *)GSBtnVC
{
    NSLog(@"Start Button Pressed");
    
    NSLog(@"Starting Mission");
    [self StartMission];
    NSLog(@"Mission Started");
}

- (void)uploadBtnActionInGSButtonVC:(MissionButtonViewController *)GSBtnVC
{
    NSLog(@"Upload Button Pressed");
    
    NSLog(@"Creating Mission");
    [self CreateMission];
    NSLog(@"Creation Finished");
    NSLog(@"Configuring Mission");
    [self ConfigMission];
    NSLog(@"Configuration Finished");
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

- (void)populateMaplat1: (double)lat1 lon1: (double)lon1 lat2: (double)lat2 lon2: (double)lon2 {
    CLLocationCoordinate2D Point1 = [CoordObject toStructLat:lat1 lon:lon1];
    CLLocationCoordinate2D Point2 = [CoordObject toStructLat:lat2 lon:lon2];
    self.headingData = [FlightPlanner distBetweenPoint:Point1 toPoint:Point2];
    NSLog(@"resolution: %f width: %f", _resolution, _survey_width);
    double missionAltitude = [FlightPlanner heightForResolution:_resolution];
    NSLog(@"Altitude: %f", missionAltitude);
    NSMutableArray* arr = [FlightPlanner generateWaypointMission:Point1 to:Point2 resolution:_resolution width:_survey_width];
    NSLog(@"Number of waypoints: %lu", (unsigned long)[arr count]);
    for (CoordObject* point in arr) {
        CLLocationCoordinate2D coord = [point toStruct];
        [self.mapController addLocation:coord withMapView:self.mapView];
    }
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

