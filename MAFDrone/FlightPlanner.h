//
//  FlightPlanner.h
//  MAFDrone
//
//  Created by Andrew Battle on 2/11/20.
//  Copyright © 2020 i disagree with copyright. no rights reserved.
//

#ifndef FlightPlanner_h
#define FlightPlanner_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CoordObject: NSObject //wouldn't it be nice if structs were just objects
@property(nonatomic, strong) NSNumber* datum1;
@property(nonatomic, strong) NSNumber* datum2;
- (id) initWithDat:(double) dat1 dat2: (double)dat2;
+ (CoordObject*) makeCoordDat1: (double) dat1 dat2: (double) dat2;
- (CLLocationCoordinate2D) toStruct;
+ (CLLocationCoordinate2D) toStructLat: (double)lat lon: (double)lon;
@end

struct MAFDistanceHeading {
    double distance;
    double heading;
};
typedef struct MAFDistanceHeading MAFDistanceHeading;

@interface FlightPlanner:NSObject
+ (CoordObject*) toMagBearing: (CoordObject*)point referenceAngle: (double)ref;
+ (double) magnitude: (CoordObject*) point;
+ (double) distanceBetweenPictures: (double)p_width overlap: (double)k;
+ (MAFDistanceHeading) distBetweenPoint: (CLLocationCoordinate2D)coord1 toPoint: (CLLocationCoordinate2D)coord2;
+ (CoordObject*) destinationCoordinate: (CLLocationCoordinate2D)reference distance:(double)d bearing:(double)b;
+ (NSMutableArray*) generateWaypointMission:(CLLocationCoordinate2D)reference to: (CLLocationCoordinate2D)endpoint;
+ (double) distBetweenCoords: (CLLocationCoordinate2D)coord1 to:(CLLocationCoordinate2D) coord2;
+ (int) totalWaypoints: (CLLocationCoordinate2D) coord1 to:(CLLocationCoordinate2D) coord2;
@end

#endif /* FlightPlanner_h */
