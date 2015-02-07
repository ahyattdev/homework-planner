//
//  HWAssignmentsArrayUtils.m
//  HomeworkPlanner
//
//  Created by Andy Hyatt on 9/13/14.
//
//

#import "HWUtilities.h"

@interface HWUtilities ()

@property HWPreferencesManager *preferencesManager;

@end

@implementation HWUtilities

- (id)init {
    self = [super init];
    self.preferencesManager = [[HWPreferencesManager alloc] init];
    return self;
}

- (NSArray *)assignmentsDueFromArray:(NSArray *)array forDate:(NSDate *)date {
    [self removeTimeFromDate:date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateDue == %@", date];
    return [array filteredArrayUsingPredicate:predicate];
}

- (NSArray *)assignmentsDueTomorrowFromArray:(NSArray *)array {
    return [self assignmentsDueFromArray:array forDate:[[NSDate alloc] initWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970] + 86400]];
}

- (NSDate *)removeTimeFromDate:(NSDate *)date {
    return [[self dateComponentsFromDate:date] date];
}

- (NSDateComponents *)dateComponentsFromDate:(NSDate *)date {
    unsigned components = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:components fromDate:date];
    [dateComponents setCalendar:[NSCalendar currentCalendar]];
    return dateComponents;
}

- (NSArray *)sortAssignmentsInArray:(NSArray *)array {
    // The 3 sort descriptors
    NSArray *sortedArray;
    NSSortDescriptor *dateDueSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateDue" ascending:YES selector:@selector(compare:)];
    NSSortDescriptor *courseSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"course" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *titleSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    // Getting the value of assignmentsSortMode
    NSInteger assignmentsSortMode = self.preferencesManager.assignmentsSortMode;
    if (assignmentsSortMode == 0) {
        sortedArray = [array sortedArrayUsingDescriptors:@[dateDueSortDescriptor, titleSortDescriptor, courseSortDescriptor]];
    } else if (assignmentsSortMode == 1) {
        sortedArray = [array sortedArrayUsingDescriptors:@[courseSortDescriptor, dateDueSortDescriptor, titleSortDescriptor]];
    } else if (assignmentsSortMode == 2) {
        sortedArray = [array sortedArrayUsingDescriptors:@[titleSortDescriptor, dateDueSortDescriptor, courseSortDescriptor]];
    }
    return sortedArray;
}

- (NSArray *)coursesOfAssignmentsInArray:(NSArray *)array {
    NSMutableArray *strings = [NSMutableArray array];
    for (int x = 0; x < [array count]; x ++) {
        HWAssignment *assignment = [array objectAtIndex:x];
        NSString *course = assignment.course;
        if (![strings containsObject:assignment.course.capitalizedString]) {
            //[strings addObject:course.capitalizedString];
            [strings insertObject:course.capitalizedString atIndex:0];
        }
    }
    return [NSArray arrayWithArray:strings];
}

- (NSInteger)numberOfDaysEnabled:(NSDictionary *)dictionary {
    NSInteger numberOfDaysEnabled = 0;
    for (int x = 0; x < 7; x++) {
        NSNumber *number = [dictionary objectForKey:[[[NSDateFormatter new] weekdaySymbols] objectAtIndex:x]];
        if ([number boolValue] == YES) {
            numberOfDaysEnabled ++;
        }
    }
    return numberOfDaysEnabled;
}

- (HWAssignment *)assignmentForUUID:(NSUUID *)uuid inArray:(NSArray *)array {
    for (int x = 0; x < array.count; x ++) {
        HWAssignment *assignment = [array objectAtIndex:x];
        if ([assignment.uuid isEqual:uuid] == YES) {
            return assignment;
        }
    }
    return nil;
}

- (HWAssignment *)assignmentForIndexPath:(NSIndexPath *)indexPath inArray:(NSArray *)array {
    NSArray *courses = [self coursesOfAssignmentsInArray:array];
    NSArray *assignmentsForCourse = [self assignmentsForCourse:[courses objectAtIndex:indexPath.section] inArray:array];
    HWAssignment *assignment = [assignmentsForCourse objectAtIndex:indexPath.row];
    return assignment;
}

- (NSArray *)assignmentsForCourse:(NSString *)course inArray:(NSArray *)array {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"course.capitalizedString == %@", course];
    NSArray *assignmentsForCourse = [NSArray arrayWithArray:[array filteredArrayUsingPredicate:predicate]];
    return assignmentsForCourse;
}

- (NSArray *)searchForTitle:(NSString *)title inArray:(NSArray *)array {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", title];
    return [array filteredArrayUsingPredicate:predicate];
}

- (NSArray *)testAssignments:(NSInteger)numberOfAssignments {
    NSArray *titles = @[@"Chapter 4 review", @"Test", @"Chapters 10 and 11", @"Lab", @"Syllabus", @"Elvis", @"Final", @"Close Read", @"Midterm Exam", @"PW 4-6", @"Bring in reading book", @"Study Vocabulary", @"Study Map", @"Bring in Project", @"Work on Essay"];
    NSArray *courses = @[@"English", @"Math", @"Spanish", @"Biology", @"World History", @"Study Hall", @"Geometry", @"Algebra"];
    NSMutableArray *testAssignments = [NSMutableArray array];
    for (NSInteger x = 0; x < numberOfAssignments; x ++) {
        NSTimeInterval timeInterval = 86400 * x;
        NSDate *now = [self removeTimeFromDate:[NSDate date]];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:now.timeIntervalSince1970 + timeInterval];
        HWAssignment *assignment = [[HWAssignment alloc] init];
        assignment.dateDue = date;
        NSInteger titleIndex = arc4random_uniform((u_int32_t)titles.count - 1);
        assignment.title = [titles objectAtIndex:titleIndex];
        NSInteger courseIndex = arc4random_uniform((u_int32_t)courses.count - 1);
        assignment.course = [courses objectAtIndex:courseIndex];
        assignment.uuid = [NSUUID UUID];
        assignment.notes = @"";
        if (assignment && assignment.title && assignment.course && assignment.dateDue) {
            [testAssignments addObject:assignment];
        }
    }
    return testAssignments;
}

- (NSArray *)completedAssignmentsInArray:(NSArray *)array {
    if (!self.preferencesManager.showCompletedAssignments) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCompleted == YES"];
        return [array filteredArrayUsingPredicate:predicate];
    } else return array;
}

- (HWAssignmentCell *)cellForAssignment:(HWAssignment *)assignment inTableView:(UITableView *)tableView {
    // Initalize the cell
    static NSString *cellIdentifier = @"AssignmentCell";
    HWAssignmentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[HWAssignmentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    // Format the cell
    NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
    if (assignment.isCompleted) {
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:assignment.title attributes:attributes];
        cell.textLabel.attributedText = title;
    } else cell.textLabel.text = assignment.title;
    cell.textLabel.textColor = assignment.color;
    cell.detailTextLabel.text = assignment.humanReadableDate;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    cell.assignment = assignment;
    return cell;
}

@end
