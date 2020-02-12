//
//  FlightPlanner.m
//  MAFDrone
//
//  Created by EGRstudent on 2/12/20.
//  Copyright © 2020 CBU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import "FlightPlanner.h"

@implementation FlightPlanner


const double radius = 6371008.8;
const double pictureWidth = 20;
const double overlapPct = 0.3;
const double surveyWidth = 50;

//after functions are done, we convert back to degrees
+ (CoordObject*) toMagBearing: (CoordObject*)point referenceAngle: (double)ref {
    double magnitude = [FlightPlanner magnitude: point];
    double bearing = atan2([point.datum2 doubleValue], [point.datum1 doubleValue]) * 180 / M_PI + ref;
    bearing = fmod(bearing + 360.0, 360.0);
    return [[CoordObject alloc] initWithDat:magnitude dat2:bearing];
}

+ (double) magnitude: (CoordObject*) point {
    double x = [point.datum1 doubleValue];
    double y = [point.datum2 doubleValue];
    return sqrt(x*x+y*y);
}

+ (double) distanceBetweenPictures: (double)p_width overlap: (double)k {
    return sqrt(1.0 - k) * p_width;
}
+ (MAFDistanceHeading) distBetweenPoint:(CLLocationCoordinate2D)coord1 toPoint:(CLLocationCoordinate2D)coord2 {
    double lat1 = coord1.latitude * M_PI / 180;
    double lat2 = coord2.latitude * M_PI / 180;
    double d_lat = lat2 - lat1;
    double d_lon = (coord2.longitude - coord1.longitude) * M_PI / 180;
    
    MAFDistanceHeading new;
    double a = pow(sin(d_lat/2), 2) + cos(lat1) * cos(lat2) * pow(sin(d_lon/2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    new.distance = radius * c;
    
    double y = sin(d_lon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(d_lon);
    new.heading = atan2(y, x) * 180 / M_PI;
    new.heading = fmod(new.heading + 360.0, 360.0);
    return new;
}

+ (CoordObject*) destinationCoordinate: (CLLocationCoordinate2D)reference distance:(double)d bearing:(double)b {
    double bearing = b * M_PI / 180;
    double lat1 = reference.latitude * M_PI / 180;
    double lon1 = reference.longitude * M_PI / 180;
    
    double lat2 = asin(sin(lat1)*cos(d/radius) + cos(lat1)*sin(d/radius)*cos(bearing));
    double lon2 = lon1 + atan2(sin(bearing)*sin(d/radius)*cos(lat1), cos(d/radius)-sin(lat1)*sin(lat2));
    
    return [[CoordObject alloc] initWithDat:lat2 * 180 / M_PI dat2:lon2 * 180 / M_PI];
}

+ (NSMutableArray*) generateXYpointsPictureDist:(double)pictureDist surveyWidth: (double)surveyWidth surveyLength: (double) surveyLength {
    //TODO: perhaps not hardcoding this array capacity
    NSMutableArray* points = [NSMutableArray arrayWithCapacity: 999];
    double yStart = 0;
    while (yStart + pictureWidth / 2 < surveyWidth / 2) {
        yStart += pictureDist;
    }
    bool goRight = TRUE;
    
    for (double y = -yStart; y < surveyWidth / 2; y += pictureDist) {
        if (goRight) {
            for (double x = 0; x < surveyLength; x += pictureDist) {
                [points addObject: [[CoordObject alloc] initWithDat:x dat2:y]];
            }
        } else {
            for (double x = surveyLength; x > 0; x -= pictureDist){
                [points addObject: [[CoordObject alloc] initWithDat:x dat2:y]];
            }
        }
        goRight = !goRight;
    }
    return points;
}

+ (NSMutableArray*) rotatePoints: (NSMutableArray*)xyPoints referenceAngle: (double)ref {
    NSMutableArray* rotatedPoints = [NSMutableArray arrayWithCapacity:[xyPoints count]];
    for(CoordObject* xy in xyPoints) {
        CoordObject* rTh = [FlightPlanner toMagBearing: xy referenceAngle:ref];
        [rotatedPoints addObject: rTh];
    }
    return rotatedPoints;
}

+ (NSMutableArray*) rTHtoGpsCoords: (NSMutableArray*) rThArray referenceCoord: (CLLocationCoordinate2D)reference{
    NSMutableArray* output = [NSMutableArray arrayWithCapacity:[rThArray count]];
    for(CoordObject* rTh in rThArray) {
        CoordObject* gpsCoord = [FlightPlanner destinationCoordinate:reference distance: [rTh.datum1 doubleValue] bearing:[rTh.datum2 doubleValue]];
        [output addObject:gpsCoord];
    }
    return output;
}

+ (NSMutableArray*) generateWaypointMission:(CLLocationCoordinate2D)reference to: (CLLocationCoordinate2D)endpoint {
    MAFDistanceHeading surveyLength = [FlightPlanner distBetweenPoint:reference toPoint:endpoint];
    //distance is distance of the survey
    //angle is reference angle (in radians)

    
    double pictureDist = (pictureWidth + sqrt(1-overlapPct) * pictureWidth) / 2;
    
    NSMutableArray* xyPoints = [FlightPlanner generateXYpointsPictureDist:pictureDist surveyWidth:surveyWidth surveyLength:surveyLength.distance];
    NSMutableArray* rThPoints = [FlightPlanner rotatePoints: xyPoints referenceAngle: surveyLength.heading];
    NSMutableArray* gpsCoords = [FlightPlanner rTHtoGpsCoords:rThPoints referenceCoord:reference];
    
    return gpsCoords;
}

@end

//If I can't keep track of structs, then this just this holds latitude/longitude information
@implementation CoordObject
@synthesize datum1;
@synthesize datum2;

- (id) initWithDat:(double)dat1 dat2: (double)dat2 {
    if(self = [super init]) {
        self.datum1 = [NSNumber numberWithDouble: dat1];
        self.datum2 = [NSNumber numberWithDouble: dat2];
    }
    return self;
}

- (CLLocationCoordinate2D) toStruct {
    CLLocationCoordinate2D new;
    new.latitude = [self.datum1 doubleValue];
    new.longitude = [self.datum2 doubleValue];
    return new;
}

+ (CoordObject*) makeCoordDat1: (double) dat1 dat2: (double) dat2 {
    CoordObject* newCoord;
    return [newCoord initWithDat: dat1 dat2: dat2];
}

@end
