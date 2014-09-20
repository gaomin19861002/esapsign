//
//  ContextTableViewCell.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubFolderCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIButton* nameButton;
@property (retain, nonatomic) IBOutlet UILabel *countLabel;

- (void)updateColorWithTargetType:(TargetType)type andParentType:(TargetType)parentType;

@end
