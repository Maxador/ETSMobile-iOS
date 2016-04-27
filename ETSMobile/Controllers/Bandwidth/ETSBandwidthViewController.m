//
//  ETSBandwidthViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-12-31.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSBandwidthViewController.h"
#import "ETSBandwidth.h"
#import "ETSConsommation.h"
#import "ETSBandwidthCell.h"
#import "ETSCoreDataHelper.h"

@interface ETSBandwidthViewController ()
@property (nonatomic, strong) NSNumberFormatter *formatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSNumber *usedBandwidth;
@property (nonatomic, strong) NSNumber *limitBandwidth;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *usageLabel;
@property (nonatomic, weak) IBOutlet UIProgressView *usageProgressView;
@property (nonatomic, copy) NSString *apartment;
@property (nonatomic, copy) NSString *phase;
@end

@implementation ETSBandwidthViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)startRefresh:(id)sender
{
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (void)updateBandwidthWithPhase:(NSString *)phase apartment:(NSString *)apartment
{
    if ([phase isEqualToString:self.phase] && [apartment isEqualToString:self.apartment]) return;
    
    //We delete all object in the model to refresh it
    [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Consommation" inManagedObjectContext:self.managedObjectContext];
    self.usageLabel.text = @" ";
    self.usageProgressView.progress = 0;
    self.dateLabel.text = @"Consommation :";
    
    if ([phase length] == 0 || [apartment length] == 0) {
        return;
    }
    
    self.synchronization.request = [NSURLRequest requestForBandwidthWithResidence:apartment phase:phase];
    
    //We update the default values
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:apartment forKey:@"apartment"];
    [userDefaults setObject:phase forKey:@"phase"];
    
    self.phase = phase;
    self.apartment = apartment;
    
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self setModalPresentationStyle:UIModalPresentationCurrentContext];
    
//    self.month = [@([[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:[NSDate date]] month]) stringValue];
    
    self.cellIdentifier = @"BandwidthIdentifier";
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.entityName = @"Consommation";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"consommations";
    synchronization.dateFormatter = self.dateFormatter;
//    synchronization.predicate = [NSPredicate predicateWithFormat:@"month ==[c] %@", self.month];
    
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    self.formatter = [[NSNumberFormatter alloc] init];
    self.formatter.decimalSeparator = @",";
    self.formatter.groupingSeparator = @" ";
    self.formatter.groupingSize = 3;
    self.formatter.usesGroupingSeparator = YES;
    self.formatter.maximumFractionDigits = 2;
    self.formatter.minimumFractionDigits = 2;
    self.formatter.minimumIntegerDigits = 1;
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.apartment = [userDefaults stringForKey:@"apartment"];
    self.phase = [userDefaults stringForKey:@"phase"];
    
    if ([self.apartment length] > 0 && [self.phase integerValue] > 0) {
        self.synchronization.request = [NSURLRequest requestForBandwidthWithResidence:self.apartment phase:self.phase];
        self.phaseSegmentedControl.selectedSegmentIndex = [self.phase integerValue] - 1;
        self.apartmentTextField.text = self.apartment;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_CA"];
        df.dateFormat = @"LLLL yyyy";
        self.dateLabel.text = [NSString stringWithFormat:@"Consommation, %@ :", [df stringFromDate:[NSDate date]]];
    } else {
        self.dataNeedRefresh = NO;
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Consommation" inManagedObjectContext:self.managedObjectContext];
    }
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [self.tableView addGestureRecognizer:tapGesture];
}

-(void)hideKeyBoard {
    [self.apartmentTextField resignFirstResponder];
    
    NSString *phase = [@(self.phaseSegmentedControl.selectedSegmentIndex+1) stringValue];
    [self updateBandwidthWithPhase:phase apartment:self.apartmentTextField.text];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Consommation" inManagedObjectContext:self.managedObjectContext];
    
    fetchRequest.entity = entity;
    fetchRequest.fetchBatchSize = 10;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"date" cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (ETSSynchronizationResponse)synchronization:(ETSSynchronization *)synchronization validateJSONResponse:(NSDictionary *)response
{
    return ETSSynchronizationResponseValid;
//    return [ETSAuthenticationViewController validateJSONResponse:response];
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveResponse:(ETSSynchronizationResponse)response
{
    
    NSLog(@"TEst");
    
}

- (IBAction)phaseDidChange:(id)sender
{
    [self updateBandwidthWithPhase:[@(self.phaseSegmentedControl.selectedSegmentIndex+1) stringValue] apartment:self.apartmentTextField.text];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ETSConsommation *bandwidth = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    NSDateFormatter *titleFormatter = [[NSDateFormatter alloc] init];
    titleFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_CA"];
    titleFormatter.dateFormat = @"cccc, d LLLL yyyy";
    return [titleFormatter stringFromDate:bandwidth.date];
}

- (void)configureCell:(ETSBandwidthCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSConsommation *bandiwdth = [self.fetchedResultsController objectAtIndexPath:indexPath];

//    cell.portLabel.text = bandiwdth.port;
    cell.uploadLabel.text = [NSString stringWithFormat:@"%@ Mo (⬆︎)", [self.formatter stringFromNumber:bandiwdth.upload]];
    cell.downloadLabel.text = [NSString stringWithFormat:@"%@ Mo (⬇︎)", [self.formatter stringFromNumber:bandiwdth.download]];
}

- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    if (!objects || [objects isKindOfClass:[NSNull class]]) {
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Consommation" inManagedObjectContext:self.managedObjectContext];
        return nil;
    }
    
    NSMutableArray *entries = [NSMutableArray array];
    NSArray *consommations = (NSArray *)objects;

    if ([consommations count] < 2) {
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Consommation" inManagedObjectContext:self.managedObjectContext];
        self.tableView.tableHeaderView.hidden = YES;
        return nil;
    }
    
    for(NSDictionary * consommation in consommations) {
        NSMutableDictionary *entry = [NSMutableDictionary dictionary];
        [entry setValue:[consommation valueForKey:@"date"] forKey:@"date"];
        [entry setValue:[consommation valueForKey:@"download"] forKey:@"download"];
        [entry setValue:[consommation valueForKey:@"idChambre"] forKey:@"idChambre"];
        [entry setValue:[consommation valueForKey:@"upload"]forKey:@"upload"];
        [entries addObject:entry];
        
    }
    
    
//    NSArray *days = [[[tables objectAtIndex:0] valueForKey:@"tbody"] valueForKey:@"tr"];
//
//    NSInteger i = 0;
//    for (NSDictionary * day in days) {
//        if (i++ == 0) continue;
//        if ([day[@"td"] count] != 4) continue;
//        
//        NSString *date = day[@"td"][1];
//        if ([date isEqualToString:@"Journée en cours"]) date = [self.dateFormatter stringFromDate:[NSDate date]];
//        
//        NSMutableDictionary *entry = [NSMutableDictionary dictionary];
//        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[self.dateFormatter dateFromString:date]];
//        
//        [entry setValue:[[day valueForKey:@"td"]objectAtIndex:0] forKey:@"port"];
//        [entry setValue:date forKey:@"date"];
//        [entry setValue:[[[day valueForKey:@"td"]objectAtIndex:2]valueForKey:@"content" ] forKey:@"upload"];
//        [entry setValue:[[[day valueForKey:@"td"]objectAtIndex:3]valueForKey:@"content" ] forKey:@"download"];
//        [entry setValue:[@([components month]) stringValue] forKey:@"month"];
//        [entry setValue:[NSString stringWithFormat:@"%@-%@", [[day valueForKey:@"td"]objectAtIndex:0], date] forKey:@"id"];
//        [entries addObject:entry];
//    }
//    
//    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
//    f.decimalSeparator = @".";
//    self.usedBandwidth = [f numberFromString:[days lastObject][@"td"][1][@"content"]];
//    self.limitBandwidth = [f numberFromString:tables[1][@"tbody"][@"tr"][1][@"td"][1][@"content"]];
//
//    NSNumber *used = @([self.usedBandwidth floatValue]/1024);
//    NSNumber *limit = @([self.limitBandwidth floatValue]/1024);
//    self.usageLabel.text = [NSString stringWithFormat:@"%@ Go sur %@ Go", [self.formatter stringFromNumber:used], [self.formatter stringFromNumber:limit]];
//    self.usageProgressView.progress = [self.usedBandwidth floatValue] / [self.limitBandwidth floatValue];
//    
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_CA"];
//    df.dateFormat = @"LLLL yyyy";
//    self.dateLabel.text = [NSString stringWithFormat:@"Consommation, %@ :", [df stringFromDate:[NSDate date]]];
//    
    self.tableView.tableHeaderView.hidden = NO;
    
    return entries;
}

@end
