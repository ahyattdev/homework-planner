//
//  HWAssignmentViewController.h
//  HomeworkPlanner
//
//  Created by Andrew Hyatt on 8/24/14.
//
//

#import <UIKit/UIKit.h>
#import "HWAssignment.h"
#import "HWTextFieldCell.h"
#import "HWDatePickerCell.h"
#import "HWUtilities.h"

@interface HWAddAssignmentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property NSMutableArray *assignments;
@property NSUUID *uuidOfTargetAssignment;

@end
