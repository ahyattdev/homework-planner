//
//  HWNavigationController.m
//  HomeworkPlanner
//
//  Created by Andrew Hyatt on 8/24/14.
//
//

#import "HWAddAssignmentNavigationController.h"

@interface HWAddAssignmentNavigationController ()

@end

@implementation HWAddAssignmentNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        HWAddAssignmentViewController *assignmentViewController = [[self childViewControllers] objectAtIndex:0];
        assignmentViewController.assignments = self.assignments;
        assignmentViewController.uuidOfTargetAssignment = self.uuidOfTargetAssignment;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
