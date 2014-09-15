//
//  Client_signpic.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Client_signpic : NSManagedObject

@property (nonatomic, retain) NSString * signpic_id;
@property (nonatomic, retain) NSString * signpic_path;
@property (nonatomic, retain) NSString * signpic_serverpath;
@property (nonatomic, retain) NSDate *   signpic_updatedate;

@end
