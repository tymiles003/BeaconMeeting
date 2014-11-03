//
//  RoomCloudManager.m
//  BeaconMeetings
//
//  Created by Hubert Kunnemeyer on 11/1/14.
//  Copyright (c) 2014 WebMD. All rights reserved.
//
//  User Name,Access Key Id,Secret Access Key
//  "Hubert_Kunnemeyer", AKIAIEGHF3BOMA3OTJHQ, YQw0Zq43xhm+wC3seK69XalX80w/ud3a4pMB95+9

#import <UIKit/UIKit.h>
#import "RoomCloudManager.h"
#import "S3.h"

// Notifications
NSString *const kRoomRequestDidFinishNotification = @"RoomRequestDidFinishNotification";

// Amazon S3 Credentials
NSString *const AWSAccountID = @"758476901827";
NSString *const CognitoPoolID = @"us-east-1:409777be-b5cc-4c7c-8446-d97d7a9ebc0a";
NSString *const CognitoRoleUnauth = @"arn:aws:iam::758476901827:role/Cognito_TransferMangerSampleUnauth_DefaultRole";
NSString *const S3BucketName = @"meetingrooms1";

// Download Parameters
NSString *const S3KeyDownloadName = @"RoomData.json"; // file name on S3
NSString *const LocalFileName = @"downloaded-rooms.json"; // local name

// Notification userData keys
NSString *const FilePathUserDataKey = @"filePath";
NSString *const FileNameUserDataKey = @"fileName";

AWSS3TransferManagerDownloadRequest *downloadRequest;

@implementation RoomCloudManager
+ (void)setUpCloudManager{
    [self setUpCredentials];
    [self checkForNewRooms];
}
+ (void)setUpCredentials{
    AWSCognitoCredentialsProvider *credentialsProvider = [AWSCognitoCredentialsProvider
                                                          credentialsWithRegionType:AWSRegionUSEast1
                                                          accountId:@"758476901827"
                                                          identityPoolId:@"us-east-1:409777be-b5cc-4c7c-8446-d97d7a9ebc0a"
                                                          unauthRoleArn:@"arn:aws:iam::758476901827:role/Cognito_TransferMangerSampleUnauth_DefaultRole"
                                                          authRoleArn:@"arn:aws:iam::758476901827:role/Cognito_TransferMangerSampleAuth_DefaultRole"];
    
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
                                                                          credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

}
+ (void)checkForNewRooms{
 
    downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    downloadRequest.bucket = S3BucketName;
    downloadRequest.key = S3KeyDownloadName;
    downloadRequest.downloadingFileURL = [self localFileUrl];
    downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite){
        // update progress
        dispatch_sync(dispatch_get_main_queue(), ^{
             NSLog(@"Written: %ld/n total written: %ld/n expected: %ld",(long)bytesWritten, (long)totalBytesWritten, (long)totalBytesExpectedToWrite);
        });
        
    };
    
    [self downloadRoomData];

    
}
+ (void)downloadRoomData{
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    [[transferManager download:downloadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error != nil){
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
            }
             NSLog(@"Error:%@",task.error);
        } else {
             NSLog(@"Recieved Data");
            [[NSNotificationCenter defaultCenter]postNotificationName:kRoomRequestDidFinishNotification object:nil userInfo:@{FilePathUserDataKey : [self localFileUrl].path, FileNameUserDataKey : LocalFileName}];
            dispatch_sync(dispatch_get_main_queue(), ^{
                
            });
            downloadRequest = nil;
            }
         NSLog(@"NIL");
        return nil;
    }];
}

+ (NSURL *)localFileUrl{
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:LocalFileName];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    return downloadingFileURL;
}
+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}
@end
