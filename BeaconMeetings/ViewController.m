//
//  ViewController.m
//  BeaconMeetings
//
//  Created by Kunnemeyer, Hubert on 10/26/14.
//  Copyright (c) 2014 WebMD. All rights reserved.
//

// er = 26453;
// or = 56021;


#import "ViewController.h"
#import "ESTBeaconManager.h"
#import "MeetingRoom.h"
#import "RoomCloudManager.h"

static NSString *appID = @"app_0gayndz1ej";
static NSString *appToken = @"eb8f3cadc1e903b44b1da309baa6079e";

@interface ViewController ()<ESTBeaconManagerDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *occupancyLabel;
@property (weak, nonatomic) IBOutlet UILabel *availableLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomLabel;
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion *region;
@property (strong, nonatomic) ESTBeacon *closestBeacon;
@property (strong, nonatomic) MeetingRoom *meetingRoom;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *beacons;
@property (nonatomic, assign) CGFloat lastKnownDistance;
@property (strong, nonatomic) NSMutableArray *rooms;
@end


@implementation ViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [ESTBeaconManager setupAppID:appID andAppToken:appToken];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetRoomInfo:) name:kRoomRequestDidFinishNotification object:nil];

    [RoomCloudManager setUpCloudManager];
    
    self.roomLabel.text = @"Room";
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.lastKnownDistance = CGFLOAT_MAX;
    self.region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                      identifier:@"EstimoteSampleRegion"];
    self.beacons = [NSMutableArray array];
    [self startRangingBeacons];

}
- (void)updateUIForBeacon:(ESTBeacon *)beacon{
    if (!beacon) {
        self.roomLabel.text = @"Not in a room";
        self.occupancyLabel.text = @"Occupancy: --";
        self.availableLabel.text = @"Available: --";
    }else{
        self.meetingRoom = [self roomWithMajor:beacon.major];
        if (self.meetingRoom) {
            self.roomLabel.text = [NSString stringWithFormat:@"Your now in %@",self.meetingRoom.roomName];
            self.occupancyLabel.text = [NSString stringWithFormat:@"Occupancy: %ld", (long)self.meetingRoom.availableSeating];
            NSString *available = self.meetingRoom.available ? @"YES" : @"NO";
            self.availableLabel.text = [NSString stringWithFormat:@"Available: %@", available];
        }
    }

}
- (void)setClosestBeacon:(ESTBeacon *)closestBeacon{
    if (![closestBeacon isEqualToBeacon:_closestBeacon]) {
        _closestBeacon = closestBeacon;
        [self updateUIForBeacon:_closestBeacon];
    }
}
-(void)startRangingBeacons
{
    NSLog(@"Ranging");
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            /*
             * No need to explicitly request permission in iOS < 8, will happen automatically when starting ranging.
             */
            [self.beaconManager startRangingBeaconsInRegion:self.region];
            NSLog(@"Starting Ranging");
        } else {
            /*
             * Request permission to use Location Services. (new in iOS 8)
             * We ask for "always" authorization so that the Notification Demo can benefit as well.
             * Also requires NSLocationAlwaysUsageDescription in Info.plist file.
             *
             * For more details about the new Location Services authorization model refer to:
             * https://community.estimote.com/hc/en-us/articles/203393036-Estimote-SDK-and-iOS-8-Location-Services
             */
            NSLog(@"Request Auth");

            [self.beaconManager requestAlwaysAuthorization];
        }
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    {
        [self.beaconManager startRangingBeaconsInRegion:self.region];
        NSLog(@"Starting Ranging");

    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Access Denied"
                                                        message:@"You have denied access to location services. Change this in app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Not Available"
                                                        message:@"You have no access to location services."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
}


#pragma mark - ESTBeaconManager delegate

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region{
    NSLog(@"Beacons:%@",beacons);

    for (ESTBeacon *beacon in beacons) {
        CGFloat dist = [beacon.distance floatValue];
        if (dist < _lastKnownDistance) {
            self.closestBeacon = beacon;
        }
        NSLog(@"\n\nDistance :%f\nLast Distance:%f\n\n",dist,_lastKnownDistance);
        if (![self.beacons containsObject:beacon] && dist > 0) {
            [self.beacons addObject:beacon];
        }else if ([self.beacons containsObject:beacon] && dist < 0){
            [self.beacons removeObject:beacon];
        }
        [self.beacons sortedArrayUsingComparator:^NSComparisonResult(ESTBeacon *beacon1, ESTBeacon *beacon2) {
            return beacon1.distance < beacon2.distance;
        }];
        [self.tableView reloadData];
        _lastKnownDistance = dist;
        
        BOOL allAreFar = YES;

        for (ESTBeacon *aBeacon in self.beacons) {
            if (aBeacon.distance.integerValue < 1) {
                allAreFar = NO;
            }
        }
      
        if (allAreFar) {
            [self updateUIForBeacon:nil];
        }else{
            [self updateUIForBeacon:_closestBeacon];
        }
        
    }
}

- (void)beaconManager:(ESTBeaconManager *)manager didDiscoverBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region{
    NSLog(@"Beacons:%@",beacons);

//    ER
//    Proximity UUID: B9407F30-F5F8-466E-AFF9-25556B57FE6D
//    Major:26453
//    Minor:10714
   
    
}

//- (void)showDistanceForBeacon:(ESTBeacon *)beacon{
//    if ([beacon.major isEqualToNumber:@(26453)]) {
//    
//    }else if([beacon.major isEqualToNumber:@(56021)]){
//        
//    }
//    
//
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.beacons.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    
    ESTBeacon *beacon = self.beacons[row];
    cell.textLabel.text = [self nameForBeacon:beacon];
    CGFloat dist = [beacon.distance integerValue];
    
    if (dist > 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.3f",dist];
    }else{
        cell.detailTextLabel.text = @"Close";
    }
 
   
    
    return cell;
}


- (NSString *)nameForBeacon:(ESTBeacon *)beacon{
    if ([beacon.major isEqualToNumber:@(26453)]) {
        return @"ER";
    }else if ([beacon.major isEqualToNumber:@(56021)]){
        return @"OR";
    }else {
        return beacon.name;
    }
}


#pragma mark- Notifications
- (void)didGetRoomInfo:(NSNotification *)notification{
     NSLog(@"Notification from cloud manager");
    if (notification.userInfo) {
        self.rooms = [NSMutableArray array];
        
         NSLog(@"Recieved Update From S3\n\nUer Info:%@",notification.userInfo);
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:LocalFileName];
        if([[NSFileManager defaultManager]fileExistsAtPath:path]){
            NSData *data = [NSData dataWithContentsOfFile:path];
            NSError *error;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (json) {
                 NSLog(@"ROOMS:\n%@",json);
                NSArray *rooms = json[@"rooms"];
                for (NSDictionary *roomData in rooms) {
                    MeetingRoom *meetingRoom = [MeetingRoom meetingRoomWithDictionary:roomData];
                    [self.rooms addObject:meetingRoom];
                }
            }
            
        }
    }
     NSLog(@"Meeting rooms:%@",self.rooms);
}
- (MeetingRoom *)roomWithMajor:(NSNumber *)major{
    for (MeetingRoom *room in self.rooms) {
        if ([room.major isEqualToNumber:major]) {
            return room;
            break;
        }
    }
    return nil;
}

@end
