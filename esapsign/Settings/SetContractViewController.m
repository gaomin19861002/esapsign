//
//  SetContractViewController.m
//  esapsign
//
//  Created by Caland on 14-8-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SetContractViewController.h"

#define SetContractCellIdentifier @"SetContractCellIdentifier"
#define SetContractDisplayCellIdentifier @"SetContractDisplayCellIdentifier"

@interface SetContractViewController ()

@property (nonatomic, retain) NSArray *sectionNames;

@end

@implementation SetContractViewController

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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SetContractCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SetContactTableViewCell" bundle:nil] forCellReuseIdentifier:SetContractDisplayCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -UITableViewDataSource Delegate methods
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionNames objectAtIndex:section];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 110;
    }
    
    return 56;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell ;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:SetContractDisplayCellIdentifier forIndexPath:indexPath];
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:SetContractCellIdentifier forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"导入系统通信录";
    }
    
    return cell;
}
#pragma mark -UITableViewDelegate methods
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self importContactFromSystem];
        }
    }
}


#pragma mark - Instance methods
/**
 *  @abstract   导入系统通信录
 */
- (void) importContactFromSystem
{
    
}

#pragma mark - Private methods
- (NSArray *) sectionNames
{
    if (!_sectionNames) {
        _sectionNames = [NSArray arrayWithObjects:@"说明", @"操作", nil];
    }
    return _sectionNames;
}

@end
