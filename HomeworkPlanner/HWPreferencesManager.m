//
//  HWPreferencesManager.m
//  HomeworkPlanner
//
//  Created by Andy Hyatt on 9/13/14.
//
//

#import "HWPreferencesManager.h"

@interface HWPreferencesManager ()

@end

@implementation HWPreferencesManager

- (void)resetSettings {
    [NSUserDefaults resetStandardUserDefaults];
    [self.userDefaults synchronize];
    self.assignmentsSortMode = 0;
    self.localNotificationsEnabled = YES;
    self.hourOfDayToNotifyAboutAssignments = 16;
    self.minuteOfDayToNotifyAboutAssignments = 0;
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    for (int x = 0; x < [[[NSDateFormatter new] weekdaySymbols] count]; x ++) {
        if (x > 0 && x < 6) {
            [dictionary setValue:[[NSNumber alloc] initWithBool:YES] forKey:[[[NSDateFormatter new] weekdaySymbols] objectAtIndex:x]];
        } else {
            [dictionary setValue:[[NSNumber alloc] initWithBool:NO] forKey:[[[NSDateFormatter new] weekdaySymbols] objectAtIndex:x]];
        }
    }
    self.schoolDays = [NSDictionary dictionaryWithDictionary:dictionary];
    self.showCompletedAssignments = NO;
    self.settingsExist = YES;
}

- (NSUserDefaults *)userDefaults {
    return [NSUserDefaults standardUserDefaults];
}

- (NSInteger)assignmentsSortMode {
    return [self.userDefaults integerForKey:@"assignmentsSortMode"];
}

- (void)setAssignmentsSortMode:(NSInteger)assignmentsSortMode {
    [self.userDefaults setInteger:assignmentsSortMode forKey:@"assignmentsSortMode"];
    [self.userDefaults synchronize];
}

- (BOOL)localNotificationsEnabled {
    return [self.userDefaults boolForKey:@"localNotificationsEnabled"];
}

- (void)setLocalNotificationsEnabled:(BOOL)localNotificationsEnabled {
    [self.userDefaults setBool:localNotificationsEnabled forKey:@"localNotificationsEnabled"];
    [self.userDefaults synchronize];
    if (localNotificationsEnabled == NO) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

- (NSInteger)hourOfDayToNotifyAboutAssignments {
    return [self.userDefaults integerForKey:@"hourOfDayToNotifyAboutAssignments"];
}

- (void)setHourOfDayToNotifyAboutAssignments:(NSInteger)hourOfDayToNotifyAboutAssignments{
    [self.userDefaults setInteger:hourOfDayToNotifyAboutAssignments forKey:@"hourOfDayToNotifyAboutAssignments"];
    [self.userDefaults synchronize];
}

- (NSInteger)minuteOfDayToNotifyAboutAssignments {
    return [self.userDefaults integerForKey:@"minuteOfDayToNotifyAboutAssignments"];
}

- (void)setMinuteOfDayToNotifyAboutAssignments:(NSInteger)minuteOfDayToNotifyAboutAssignments {
    [self.userDefaults setInteger:minuteOfDayToNotifyAboutAssignments forKey:@"minuteOfDayToNotifyAboutAssignments"];
    [self.userDefaults synchronize];
}

- (NSDictionary *)schoolDays {
    return [self.userDefaults objectForKey:@"schoolDays"];
}

- (void)setSchoolDays:(NSDictionary *)schoolDays {
    [self.userDefaults setObject:schoolDays forKey:@"schoolDays"];
    [self.userDefaults synchronize];
}

- (BOOL)settingsExist {
    return [self.userDefaults boolForKey:@"settingsExist"];
}

- (void)setSettingsExist:(BOOL)settingsExist {
    NSLog(@"Setting to %i", settingsExist);
    [self.userDefaults setBool:settingsExist forKey:@"settingsExist"];
    [self.userDefaults synchronize];
}

- (BOOL)showCompletedAssignments {
    return [self.userDefaults boolForKey:@"showCompletedAssignments"];
}

- (void)setShowCompletedAssignments:(BOOL)showCompletedAssignments {
    [self.userDefaults setBool:showCompletedAssignments forKey:@"showCompletedAssignments"];
    [self.userDefaults synchronize];
}

@end
