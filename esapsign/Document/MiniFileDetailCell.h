//
//  MiniFileDetailCell.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Client_target.h"
#import "Client_file.h"

@interface MiniFileDetailCell : UITableViewCell
{
@public
    Client_target* targetInfo;
}
@property (retain, nonatomic) IBOutlet UIImageView *leftImageView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *createLabel;

@end
