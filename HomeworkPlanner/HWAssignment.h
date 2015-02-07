//
//  HWAssignment.h
//  HomeworkPlanner
//
//  Created by Andrew Hyatt on 8/24/14.
//
//

#import <Foundation/Foundation.h>

@interface HWAssignment : NSObject

@property NSUUID *uuid;
@property NSString *title;
@property NSString *course;
@property NSDate *dateDue;
@property BOOL isCompleted;
@property NSString *notes;

- (id)initWithContentsOfDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)createDictionaryFromAssignment;
- (NSString *)humanReadableDate;
- (UIColor *)color;
- (id)valueForKey:(NSString *)key;

@end
