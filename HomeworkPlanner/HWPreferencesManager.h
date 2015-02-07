//
//  HWPreferencesManager.h
//  HomeworkPlanner
//
//  Created by Andy Hyatt on 9/13/14.
//
//

#import <Foundation/Foundation.h>

@interface HWPreferencesManager : NSObject

@property (nonatomic) NSInteger assignmentsSortMode;
@property (nonatomic) BOOL localNotificationsEnabled;
@property (nonatomic) NSInteger hourOfDayToNotifyAboutAssignments;
@property (nonatomic) NSInteger minuteOfDayToNotifyAboutAssignments;
@property (nonatomic) NSDictionary *schoolDays;
@property (nonatomic) BOOL settingsExist;
@property (nonatomic) BOOL showCompletedAssignments;

- (NSUserDefaults *)userDefaults;
- (void)resetSettings;

@end
