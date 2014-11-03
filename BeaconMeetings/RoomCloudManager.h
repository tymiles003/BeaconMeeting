//
//  RoomCloudManager.h
//  BeaconMeetings
//
//  Created by Hubert Kunnemeyer on 11/1/14.
//  Copyright (c) 2014 WebMD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
extern NSString *const kRoomRequestDidFinishNotification;
extern NSString *const FilePathUserDataKey;
extern NSString *const FileNameUserDataKey;
extern NSString *const LocalFileName;

typedef void(^RoomRequestCallbackBlock)(BOOL success, id response);

@interface RoomCloudManager : NSObject
+ (void)setUpCloudManager;
+ (void)checkForNewRooms;
@end
