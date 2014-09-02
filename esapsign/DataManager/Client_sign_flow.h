//
//  Client_sign_flow.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Client_file, Client_sign;

@interface Client_sign_flow : NSManagedObject

@property (nonatomic, retain) NSNumber * current_sequence;
@property (nonatomic, retain) NSString * current_sign_id;
@property (nonatomic, retain) NSNumber * current_sign_status;
@property (nonatomic, retain) NSString * file_id;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * sign_flow_id;
@property (nonatomic, retain) Client_file *clientFile;
@property (nonatomic, retain) NSSet *clientSigns;
@end

@interface Client_sign_flow (CoreDataGeneratedAccessors)

- (void)addClientSignsObject:(Client_sign *)value;
- (void)removeClientSignsObject:(Client_sign *)value;
- (void)addClientSigns:(NSSet *)values;
- (void)removeClientSigns:(NSSet *)values;

@end
