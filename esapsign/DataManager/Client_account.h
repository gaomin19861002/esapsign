//
//  Client_account.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Client_account : NSManagedObject

@property (nonatomic, retain) NSString * account_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * major_email;
@property (nonatomic, retain) NSString * cert;
@property (nonatomic, retain) NSNumber * sign_count;

@end
