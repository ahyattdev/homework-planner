//
//  HWNotificationManager.m
//  HomeworkPlanner
//
//  Created by Andy Hyatt on 9/13/14.
//
//

#import "HWNotificationManager.h"

@interface HWNotificationManager ()

@property HWPreferencesManager *preferencesManager;
@property HWUtilities *utils;

@end

@implementation HWNotificationManager

- (id)initWithMutableArray:(NSMutableArray *)mutableArray {
    self = [super init];
    self.assignments = mutableArray;
    self.preferencesManager = [[HWPreferencesManager alloc] init];
    self.utils = [[HWUtilities alloc] init];
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        unsigned notificationTypes = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |UIUserNotificationTypeSound;
        UIUserNotificationSettings  *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
    if (self.preferencesManager.localNotificationsEnabled) {
        [self scheduleNotificationsForNextWeek];
    }
    return self;
}

- (void)scheduleNotificationsForNextWeek {
    // Delete all the notifications that are pending and recieved, and reset the badge
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    // Initialize the utils
    HWUtilities *utils = [[HWUtilities alloc] init];
    // Get the dictionary of enabled schoolDays from the preferences manager
    NSDictionary *schoolDays = self.preferencesManager.schoolDays;
    // Recursively schedule the notifications for the next 7 days, as long as that day has notifications enabled
    for (int x = 0; x < 7; x++) {
        // Multiply x by the number of second in a day
        double timeInvervalAddition = 86400 * x;
        NSTimeInterval today = [[self.utils removeTimeFromDate:[NSDate new]] timeIntervalSince1970];
        NSTimeInterval timeInterval = today + timeInvervalAddition;
        NSDate *dateForNotification = [[NSDate alloc] initWithTimeIntervalSince1970:timeInterval];
        [utils removeTimeFromDate:dateForNotification];
        // Set the time for the time that the user has set
        NSDateComponents *setTime = [utils dateComponentsFromDate:dateForNotification];
        setTime.hour = self.preferencesManager.hourOfDayToNotifyAboutAssignments;
        setTime.minute = self.preferencesManager.minuteOfDayToNotifyAboutAssignments;
        dateForNotification = [setTime date];
        // Get the name of the day of the week for the notification, so the string can be used to get the key for that week from the schoolDays dictionary
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE"];
        //Test if the day is enabled, according to the schoolDays dictionary
        BOOL isDayEnabled = (BOOL)[schoolDays objectForKey:[dateFormatter stringFromDate:dateForNotification]];
        if (isDayEnabled == YES && [dateForNotification timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970]) {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = dateForNotification;
            NSString *alertBody;
            NSInteger assignmentsDue = [[utils assignmentsDueFromArray:self.assignments forDate:dateForNotification] count];
            if (assignmentsDue == 0) {
                alertBody = @"You have no homework due tomorrow!";
            } else if (assignmentsDue == 1) {
                alertBody = @"You have %@ homework due tomorrow";
            } else {
                alertBody = [NSString stringWithFormat:@"You have %li assignments due tomorrow", (long)assignmentsDue];
            }
            localNotification.alertBody = alertBody;
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
}

@end
