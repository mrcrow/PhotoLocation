//
//  PhotoObject.h
//  PhotoLocation
//
//  Created by Wu Wenzhi on 13-1-21.
//  Copyright (c) 2013年 Wu Wenzhi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PhotoObject : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * hasLocation;
@property (nonatomic, retain) NSNumber * hasPhoto;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * photoPath;
@property (nonatomic, retain) NSString * storagePath;
@property (nonatomic, retain) NSDate * timeStamp;

@end
