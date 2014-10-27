//
//  BeaconManager.h
//  BeaconMeetings
//
//  Created by Kunnemeyer, Hubert on 10/26/14.
//  Copyright (c) 2014 WebMD. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, MeetingRoom){
    MeetingRoomER,
    MeetingRoomOR
};
@interface BeaconManager : NSObject

- (instancetype)initWithMeetingRoom:(MeetingRoom)room;
@end
