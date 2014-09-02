//
//  SetBlueToothViewController.m
//  esapsign
//
//  Created by Caland on 14-8-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "SetBlueToothViewController.h"

#define SetBlueToothCellIdentifier @"SetBlueToothCellIdentifier"

@interface SetBlueToothViewController ()

@property (nonatomic, retain) NSArray *sectionNames;

@end

@implementation SetBlueToothViewController

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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SetBlueToothCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -UITableViewDataSource Delegate methods
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionNames objectAtIndex:section];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SetBlueToothCellIdentifier forIndexPath:indexPath];
    
    return cell;
}

#pragma mark -UITableViewDelegate methods
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
}

#pragma mark - Private methods
- (NSArray *) sectionNames
{
    if (!_sectionNames) {
        _sectionNames = [NSArray arrayWithObjects:@"淦蓝", @"文鼎创", @"其他", nil];
    }
    return _sectionNames;
}

@end
