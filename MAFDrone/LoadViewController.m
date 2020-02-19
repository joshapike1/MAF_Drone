#import "LoadViewController.h"

@implementation LoadViewController 

NSArray *archivedWaypointsArray;
NSArray *missionNames;
NSString *whatToLoad;
NSString *name;
double lat1;
double long1;
double lat2;
double long2;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize table data
    [self loadMissions];
}

//Load button, here data is sent to the FlightPlanner class
- (IBAction)loadBtnAction:(id)sender {
    [self setCoords];
    if (lat1 == 0.0) {
        [self ShowMessage:@"Loading" message:@"Please select a mission" actionTitle:@"OK"];
    } else {
        [self ShowMessage:@"Loading" message:[NSString stringWithFormat:@"%.8lf", lat1 ] actionTitle:@"OK"];
    }
    // HERE IS HOW TO LOAD DATA
}

//Details just returns the data in the array at index and displayes it in a popup
- (IBAction)detailsMapBtnAction:(id)sender {
    [self setCoords];
    if (lat1 == 0.0) {
        [self ShowMessage:@"Loading" message:@"Please select a mission" actionTitle:@"OK"];
    } else {
        [self ShowMessage:@"Details" message:[NSString stringWithFormat:@"%@%@%@%f%@%f%@%f%@%f%@", @"Name: ", name, @"\nCoordinate 1: <", lat1, @",", long1, @">\nCoordinate 2: <", lat2, @"," ,long2, @">"] actionTitle:@"OK"];
    }
}

//Runs to populate the listview
-(void)loadMissions {
    //Reset variables
    archivedWaypointsArray = nil;
    whatToLoad = nil;
    missionNames = nil;
    lat1 = 0.0;
    long1 = 0.0;
    lat2 = 0.0;
    long2 = 0.0;
    
    //Load missinos from text document
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"waypoints.txt"];
    NSString *waypointsText = [NSString stringWithContentsOfFile:fileName];
    
    //Insert data into array seperated by mission
    archivedWaypointsArray = [waypointsText componentsSeparatedByString:@";\n"];
    
    //Temporary mutable array for saving only names
    NSMutableArray *tempArray = [ [ NSMutableArray alloc] init];
    
    //Extract names of mission only (for list population)
    for (int i = 0; i < archivedWaypointsArray.count - 1; i++) {
        NSString *haystack = [NSString stringWithFormat:@"%@",archivedWaypointsArray[i]];
        NSString *prefix = @"[";
        NSString *suffix = @"]";
        NSRange prefixRange = [haystack rangeOfString:prefix];
        NSRange suffixRange = [[haystack substringFromIndex:prefixRange.location+prefixRange.length] rangeOfString:suffix];
        NSRange needleRange = NSMakeRange(prefixRange.location+prefix.length, suffixRange.location);
        NSString *needle = [haystack substringWithRange:needleRange];
        NSLog(@"needle: %@%@%d", needle, @" ", i);
        
        [tempArray addObject:needle];
    }
    
    //Add names to missionNames array
    missionNames = [tempArray copy];
    NSLog(@"missionNames array: %@", missionNames);
}

//Sets lat and long double
- (void)setCoords{
    //String to parse through
    NSString *haystack = whatToLoad;
    
    //Find name
    NSString *prefix = @"[";
    NSString *suffix = @"]";
    NSRange prefixRange = [haystack rangeOfString:prefix];
    NSRange suffixRange = [[haystack substringFromIndex:prefixRange.location+prefixRange.length] rangeOfString:suffix];
    NSRange needleRange = NSMakeRange(prefixRange.location+prefix.length, suffixRange.location);
    name = [haystack substringWithRange:needleRange];
    NSLog(@"Mission Name: %@", name);
    
    //Find Latitude 1
    NSString *prefix1 = @"]||";
    NSString *suffix1 = @",";
    NSRange prefixRangeLat1 = [haystack rangeOfString:prefix1];
    NSRange suffixRangeLat1 = [[haystack substringFromIndex:prefixRangeLat1.location+prefixRangeLat1.length] rangeOfString:suffix1];
    NSRange needleRangeLat1 = NSMakeRange(prefixRangeLat1.location+prefix1.length, suffixRangeLat1.location);
    NSString *lat1String = [haystack substringWithRange:needleRangeLat1];
    NSLog(@"Lat1: %@", lat1String);
    
    //Check if + or - and set lat1
    if([lat1String hasPrefix:@"+"]) {
        lat1 = [[lat1String substringFromIndex:1] doubleValue];
        NSLog(@"Lat1 Num: %.8lf", lat1);
    }
    else {
        lat1 =[[lat1String substringFromIndex:1] doubleValue] * -1;
        NSLog(@"Lat1 Num: %.8lf", lat1);
    }
    
    //Find Longitude 1
    NSString *prefixLong1 = @",";
    NSString *suffixLong1 = @"|0|";
    NSRange prefixRangeLong1 = [haystack rangeOfString:prefixLong1];
    NSRange suffixRangeLong1 = [[haystack substringFromIndex:prefixRangeLong1.location+prefixRangeLong1.length] rangeOfString:suffixLong1];
    NSRange needleRangeLong1 = NSMakeRange(prefixRangeLong1.location+prefixLong1.length, suffixRangeLong1.location);
    NSString *long1String = [haystack substringWithRange:needleRangeLong1];
    NSLog(@"Long1: %@", lat1String);
    
    //Check if + or - and set long1
    if([long1String hasPrefix:@"+"]) {
        long1 = [[long1String substringFromIndex:1] doubleValue];
        NSLog(@"Long1 Num: %.8lf", long1);
    }
    else {
        long1 =[[long1String substringFromIndex:1] doubleValue] * -1;
        NSLog(@"Long1 Num: %.8lf", long1);
    }
    
    //Find Latitude 2
    NSString *prefixLat2 = @"|0|";
    NSString *suffixLat2 = @",";
    NSRange prefixRangeLat2 = [haystack rangeOfString:prefixLat2];
    NSRange suffixRangeLat2 = [[haystack substringFromIndex:prefixRangeLat2.location+prefixRangeLat2.length] rangeOfString:suffixLat2];
    NSRange needleRangeLat2 = NSMakeRange(prefixRangeLat2.location+prefixLat2.length, suffixRangeLat2.location);
    NSString *lat2String = [haystack substringWithRange:needleRangeLat2];
    NSLog(@"Lat2: %@", lat2String);
    
    //Check if + or - and set lat2
    if([lat2String hasPrefix:@"+"]) {
        lat2 = [[lat2String substringFromIndex:1] doubleValue];
        NSLog(@"Lat2 Num: %.8lf", lat2);
    }
    else {
        lat2 = [[lat2String substringFromIndex:1] doubleValue] * -1;
        NSLog(@"Lat2 Num: %.8lf", lat2);
    }
    
    //Find Longitude 2
    NSString *prefixLong2 = [NSString stringWithFormat:@"%@%@", lat2String, @","];
    NSString *suffixLong = @"|1|";
    NSRange prefixRangeLong2 = [haystack rangeOfString:prefixLong2];
    NSRange suffixRangeLong2 = [[haystack substringFromIndex:prefixRangeLong2.location+prefixRangeLong2.length] rangeOfString:suffixLong];
    NSRange needleRangeLong2 = NSMakeRange(prefixRangeLong2.location+prefixLong2.length, suffixRangeLong2.location);
    NSString *long2String = [haystack substringWithRange:needleRangeLong2];
    NSLog(@"Long2: %@", long2String);
    
    //Check if + or - and set long2
    if([long2String hasPrefix:@"+"]) {
        long2 = [[long2String substringFromIndex:1] doubleValue];
        NSLog(@"Long2 Num: %.8lf", long2);
    }
    else {
        long2 = [[long2String substringFromIndex:1] doubleValue] * -1;
        NSLog(@"Long2 Num: %.8lf", long2);
    }
}

//Sets whatToLoad string with data selected by user
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *inStr = archivedWaypointsArray[indexPath.row];
    whatToLoad = inStr;
}

//Return count of missions
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [missionNames count];
}

//Create list view with missino names only
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [missionNames objectAtIndex:indexPath.row];
    return cell;
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
