//
//  DetailViewController.h
//  PhotoLocation
//
//  Created by Wu Wenzhi on 13-1-19.
//  Copyright (c) 2013年 Wu Wenzhi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
