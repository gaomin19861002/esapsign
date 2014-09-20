//
//  MiniDocViewController.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "MiniDocViewController.h"
#import "MiniDocListViewController.h"

@interface MiniDocViewController () <RootFolderSectionDelegate>

@end

@implementation MiniDocViewController

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    RootFolderSection *rootSection = [RootFolderSection rootSection];
    
    Client_target *target = [super.levelOneFolders objectAtIndex:section];
    [rootSection.titleButton setTitle:target.display_name forState:UIControlStateNormal];
    [rootSection.countLabel setText:[NSString stringWithFormat:@"%u", [target.subFolders count] + [target.subFiles count]]];
    
    rootSection.section = section;
    rootSection.delegate = self;
    
    [rootSection updateShowWithTargetType:[target.type intValue] selected:[super.foldStatus[section] boolValue]];
    
    return rootSection;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    Client_target *target = [super.levelOneFolders objectAtIndex:section];
    UIImageView *footerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 6)];

    if ([target.type intValue] == TargetTypeSystemFolder)
        [footerView setImage:[UIImage imageNamed:@"FolderSysTail"]];
    else
        [footerView setImage:[UIImage imageNamed:@"FolderDefTail"]];
    
    return footerView;
}

- (DocListViewController *)listViewController
{
    return super.listViewController;
}

- (UIBarButtonItem *)rightBarItem
{
    return nil;
}

- (void)setListViewController:(DocListViewController *)listViewController
{
    if (![super.listViewController isEqual:listViewController])
        super.listViewController = listViewController;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        DocViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MiniDocView"];
        Client_target *target = self.levelOneFolders[indexPath.section];
        controller.parent = target;
        controller.lastSection = indexPath.row;
        controller.listViewController = self.listViewController;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
