//
//  ContactHeadFooterView.h
//  esapsign
//
//  Created by Suzic on 14-7-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactGroupView : UIView

+ (ContactGroupView *)headerFooterView;

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *subTitleLabel;
@property(nonatomic, retain) IBOutlet UIView *rightSmallView;
@property (strong, nonatomic) IBOutlet UIView *background;

@end
