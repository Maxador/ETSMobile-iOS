//
//  ETSCoursesViewController_iPad.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-09.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSCoursesViewController_iPad.h"
#import "ETSCourseDetailViewController.h"
#import "ETSCourse.h"
#import "ETSEvaluation.h"
#import "ETSMenuViewController.h"
#import "MFSideMenu.h"

@interface ETSCoursesViewController_iPad ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end


@implementation ETSCoursesViewController_iPad

@synthesize fetchedResultsController=_fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"COURSES_IPAD_VIEWCONTROLLER"];
    
    self.title =  NSLocalizedString(@"Notes", nil);    
    
    self.cellIdentifier = @"CourseIdentifier";
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForCourses];
    synchronization.entityName = @"Course";
    synchronization.compareKey = @"acronym";
    synchronization.objectsKeyPath = @"d.liste";
    synchronization.ignoredAttributes = @[@"results", @"mean", @"median", @"std", @"percentile"];
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    if (![ETSAuthenticationViewController passwordInKeychain] || ![ETSAuthenticationViewController usernameInKeychain]) {
        ETSAuthenticationViewController *ac = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
        ac.delegate = self;
        [self.navigationController pushViewController:ac animated:YES];
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.fetchBatchSize = 24;
    
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"acronym" ascending:YES]];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"order" cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ETSCourse *course = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    NSString *session = nil;
    if ([course.season integerValue] == 1)      session = NSLocalizedString(@"Hiver", nil);
    else if ([course.season integerValue] == 2) session = NSLocalizedString(@"Été", nil);
    else if ([course.season integerValue] == 3) session = NSLocalizedString(@"Automne", nil);
    
    return [NSString stringWithFormat:@"%@ %@", session, course.year];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSCourse *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([course.grade length] > 0) {
        cell.detailTextLabel.text = course.grade;
    }
    else if ([course.results floatValue] > 0) {
        NSNumber *percent = @([course.results floatValue]/[[course totalEvaluationWeighting] floatValue]*100);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu %%", (long)[percent integerValue]];
    } else {
        cell.detailTextLabel.text = @"";
    }
    
    cell.textLabel.text = course.acronym;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate coursesViewController:self didSelectCourse:[self.fetchedResultsController objectAtIndexPath:indexPath] managedObjectContext:self.managedObjectContext];
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    if ([managedObject isKindOfClass:[ETSEvaluation class]]) return;
    
    ETSCourse *course = (ETSCourse *)managedObject;
    course.year = @([[object[@"session"] substringFromIndex:1] integerValue]);
    
    NSString *seasonString = [object[@"session"] substringToIndex:1];
    if ([seasonString isEqualToString:@"H"])      course.season = @1;
    else if ([seasonString isEqualToString:@"É"]) course.season = @2;
    else if ([seasonString isEqualToString:@"A"]) course.season = @3;
    
    if ([seasonString isEqualToString:@"H"])      course.order = [NSString stringWithFormat:@"%@-%@", course.year, @"1"];
    else if ([seasonString isEqualToString:@"É"]) course.order = [NSString stringWithFormat:@"%@-%@", course.year, @"2"];
    else if ([seasonString isEqualToString:@"A"]) course.order = [NSString stringWithFormat:@"%@-%@", course.year, @"3"];
}

- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller
{
    self.synchronization.request = [NSURLRequest requestForCourses];
    [super controllerDidAuthenticate:controller];
}

- (ETSSynchronizationResponse)synchronization:(ETSSynchronization *)synchronization validateJSONResponse:(NSDictionary *)response
{
    return [ETSAuthenticationViewController validateJSONResponse:response];
}

@end
