//
//  BeaconManager.m
//  BeaconMeetings
//
//  Created by Kunnemeyer, Hubert on 10/26/14.
//  Copyright (c) 2014 WebMD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconManager.h"
#import "ESTBeaconManager.h"

NSString *const macAddress = @"fad429da6755";
NSString *const proximityUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";

static CGFloat major = 26453;
static CGFloat minor = 10714;

@interface BeaconManager ()
@property (strong, nonatomic) ESTBeaconManager *manager;
@property (nonatomic) MeetingRoom meetingRoom;
@end

@implementation BeaconManager
- (instancetype)initWithMeetingRoom:(MeetingRoom)room{
    self = [super init];
    if (self) {
        _meetingRoom = room;
    }
    return self;
}
@end
