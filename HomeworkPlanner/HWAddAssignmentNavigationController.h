//
//  HWNavigationController.h
//  HomeworkPlanner
//
//  Created by Andrew Hyatt on 8/24/14.
//
//

#import <UIKit/UIKit.h>
#import "HWAddAssignmentViewController.h"

@interface HWAddAssignmentNavigationController : UINavigationController

@property NSMutableArray *assignments;
@property NSUUID *uuidOfTargetAssignment;

@end
