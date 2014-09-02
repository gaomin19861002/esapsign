//
//  ContextTableViewCell.m
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import "ContextTableViewCell.h"
#import "UIColor+Additions.h"

@implementation ContextTableViewCell

- (void)updateColorWithTargetType:(TargetType)type andParentType:(TargetType)parentType
{
    //self.backgroundColor = [UIColor colorWithPatternImage:(parentType == TargetTypeSystemFolder ?
    //                        [UIImage imageNamed:@"bar_sys_push.png"]:[UIImage imageNamed:@"bar_def_push.png"])];
    
    [self.nameButton setBackgroundImage:(parentType == TargetTypeSystemFolder ? [UIImage imageNamed:@"FolderSysSub"]:[UIImage imageNamed:@"FolderDefSub"])
                               forState:UIControlStateNormal];
    
    //[self.subIcon setImage:(type == TargetTypeSystemFolder ? [UIImage imageNamed:@"icon_top.png"] : [UIImage imageNamed:@"icon_sub.png"])];
}

@end
