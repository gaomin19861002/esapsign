//
//  Client_signfile.h
//  esapsign
//
//  Created by Suzic on 14-8-11.
//  Copyright (c) 2014年 Caland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Client_signfile : NSManagedObject

@property (nonatomic, retain) NSString * signfile_id;
@property (nonatomic, retain) NSString * signfile_path;
@property (nonatomic, retain) NSString * signfile_serverpath;
@property (nonatomic, retain) NSDate * signfile_updatedate;

@end
