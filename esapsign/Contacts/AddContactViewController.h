//
//  AddContactViewController.h
//  esapsign
//
//  Created by Gaomin on 14-8-7.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddContactViewController;

@protocol  AddContactViewControllerDelegate <NSObject>

- (void)AddContactViewControllerDidCancel:(AddContactViewController *)addContactController;
- (void)AddContactViewControllerDidDone:(AddContactViewController *)addContactController userBasicItems:(NSDictionary *)userBasic contactItems:(NSArray *)contactItems;

@end

@interface AddContactViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView *headImageView;
@property (nonatomic, retain) IBOutlet UITextField *familyNameField;
@property (nonatomic, retain) IBOutlet UITextField *personNameField;
@property (nonatomic, retain) IBOutlet UITableView *contactTableView;

@property (nonatomic, assign) id <AddContactViewControllerDelegate> delegate;

@end
