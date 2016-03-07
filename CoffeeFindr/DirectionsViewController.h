//
//  DirectionsViewController.h
//  CoffeeFindr
//
//  Created by lengshan on 3/5/16.
//  Copyright © 2016 Amber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CoffeeShop.h"


@interface DirectionsViewController : UIViewController

@property CoffeeShop *coffeeshop;
@property CLLocation *userLocation;

@end
