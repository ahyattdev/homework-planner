//
//  HWNotificationManager.h
//  HomeworkPlanner
//
//  Created by Andy Hyatt on 9/13/14.
//
//

#import <Foundation/Foundation.h>
#import "HWPreferencesManager.h"
#import "HWUtilities.h"

@interface HWNotificationManager : NSObject

@property NSMutableArray *assignments;

- (id)initWithMutableArray:(NSMutableArray *)mutableArray;
- (void)scheduleNotificationsForNextWeek;

@end
