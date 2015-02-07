//
//  HWAssignment.m
//  HomeworkPlanner
//
//  Created by Andrew Hyatt on 8/24/14.
//
//

#import "HWAssignment.h"

@implementation HWAssignment

- (id)initWithContentsOfDictionary:(NSDictionary *)dictionary {
    self = [super init];
    self.uuid = [[NSUUID alloc] initWithUUIDString:[dictionary objectForKey:@"UUID"]];
    self.title = [dictionary objectForKey:@"Title"];
    self.course = [dictionary objectForKey:@"Course"];
    self.dateDue = [dictionary objectForKey:@"Date Due"];
    self.isCompleted = [[dictionary objectForKey:@"Completed"] boolValue];
    self.notes = [dictionary objectForKey:@"Notes"];
    return self;
}

- (NSDictionary *)createDictionaryFromAssignment {
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:@[[self.uuid UUIDString], [self title], [self course], [self dateDue], [NSNumber numberWithBool:self.isCompleted], self.notes] forKeys:@[@"UUID", @"Title", @"Course", @"Date Due", @"Completed", @"Notes"]];
    return dictionary;
}

- (NSString *)description {
    return self.title;
}

- (NSString *)humanReadableDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *humanReadableDate = [dateFormatter stringFromDate:self.dateDue];
    return humanReadableDate;
}

- (UIColor *)color {
    NSDate *currentDate = [[NSDate alloc] init];
    if (self.isCompleted == YES) {
        return [UIColor grayColor];
    } if ([currentDate timeIntervalSinceDate:self.dateDue] > 0) {
        return [UIColor redColor];
    } if ([currentDate timeIntervalSinceDate:self.dateDue] > -86400) {
        return [UIColor blackColor];
    } else return [UIColor blackColor];
    
}

- (id)valueForKey:(NSString *)key {
    if ([key isEqualToString:@"dateDue"]) {
        return self.dateDue;
    } else if ([key isEqualToString:@"course"]) {
        return self.course;
    } else if ([key isEqualToString:@"title"]) {
        return self.title;
    } else if ([key isEqualToString:@"isCompleted"]) {
        return [NSNumber numberWithBool:self.isCompleted];
    } else if ([key isEqualToString:@"uuid"]) {
        return self.uuid.UUIDString;
    } else return nil;
}

@end
