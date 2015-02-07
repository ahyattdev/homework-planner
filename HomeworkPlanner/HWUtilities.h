//
//  HWAssignmentsArrayUtils.h
//  HomeworkPlanner
//
//  Created by Andy Hyatt on 9/13/14.
//
//

#import <Foundation/Foundation.h>
#import "HWAssignment.h"
#import "HWPreferencesManager.h"
#import "HWAssignmentCell.h"

@interface HWUtilities : NSObject

- (NSArray *)assignmentsDueFromArray:(NSArray *)array forDate:(NSDate *)date;
- (NSArray *)assignmentsDueTomorrowFromArray:(NSArray *)array;
- (NSDate *)removeTimeFromDate:(NSDate *)date;
- (NSDateComponents *)dateComponentsFromDate:(NSDate *)date;
- (NSArray *)sortAssignmentsInArray:(NSArray *)array;
- (NSArray *)coursesOfAssignmentsInArray:(NSArray *)array;
- (NSInteger)numberOfDaysEnabled:(NSDictionary *)dictionary;
- (HWAssignment *)assignmentForUUID:(NSUUID *)uuid inArray:(NSArray *)array;
- (NSArray *)assignmentsForCourse:(NSString *)course inArray:(NSArray *)array;
- (NSArray *)searchForTitle:(NSString *)title inArray:(NSArray *)array;
- (NSArray *)testAssignments:(NSInteger)numberOfAssignments; // For testing only
- (HWAssignment *)assignmentForIndexPath:(NSIndexPath *)indexPath inArray:(NSArray *)array;
- (NSArray *)completedAssignmentsInArray:(NSArray *)array;
- (HWAssignmentCell *)cellForAssignment:(HWAssignment *)assignment inTableView:(UITableView *)tableView;

@end
