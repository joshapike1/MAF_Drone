#import "LoadViewController.h"

@implementation LoadViewController 

NSArray *archivedWaypointsArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize table data
    [self loadMissions];
}


-(void)loadMissions {
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"waypoints.txt"];

    NSString *waypointsText = [NSString stringWithContentsOfFile:fileName];

    archivedWaypointsArray = [waypointsText componentsSeparatedByString:@";\n"];

        // Send to Andrews function IMPORTANT: Coordinates are doubles: CLLocationCoordinate2D
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [archivedWaypointsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
 
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
 
    cell.textLabel.text = [archivedWaypointsArray objectAtIndex:indexPath.row];
    return cell;
}


@end
