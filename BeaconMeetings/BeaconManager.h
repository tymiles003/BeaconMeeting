//
//  BeaconManager.h
//  BeaconMeetings
//
//  Created by Kunnemeyer, Hubert on 10/26/14.
//  Copyright (c) 2014 WebMD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeetingRoom.h"

@interface BeaconManager : NSObject
@property (strong, nonatomic) MeetingRoom *meetingRoom;

- (instancetype)initWithMajor:(NSNumber *)major;
@end
