//
//  SetSwitchTableViewCell.h
//  esapsign
//
//  Created by Caland on 14-8-29.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetSwitchTableViewCellDelegate <NSObject>

@required
- (void) toogleSwitchTo:(BOOL) on withType:(NSString *) type;

@end

@interface SetSwitchTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

@property (nonatomic, retain) IBOutlet UISwitch *switcher;

@property (nonatomic, retain) id<SetSwitchTableViewCellDelegate> delegate;

@property (nonatomic, retain) NSString *type;



- (IBAction) switchValueChanged:(id)sender;

@end
