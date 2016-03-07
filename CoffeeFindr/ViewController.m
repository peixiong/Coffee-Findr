//
//  ViewController.m
//  CoffeeFindr
//
//  Created by lengshan on 3/5/16.
//  Copyright © 2016 Amber. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CoffeeShop.h"
#import "DirectionsViewController.h"

@interface ViewController () <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property CLLocationManager *locationManager;
@property CLLocation *userLocation;
@property NSArray *coffeeShops;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] init];
    barButtonItem.title = @"Back";
    self.navigationItem.backBarButtonItem = barButtonItem;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.coffeeShops.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    CoffeeShop *coffeeShop = [self.coffeeShops objectAtIndex:indexPath.row];
    cell.textLabel.text = coffeeShop.mapItem.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f miles away", coffeeShop.distance];
    return cell;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    self.userLocation = locations.firstObject;
    [self.locationManager stopUpdatingLocation];
    [self findCoffeePlaces:self.userLocation];
}

-(void)findCoffeePlaces:(CLLocation *)location{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"coffee";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.5, 0.5));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        NSArray *mapItems = response.mapItems;
        NSMutableArray *tempArray = [NSMutableArray new];
        for (int i = 0; i<5; i++) {
            MKMapItem *mapItem = [mapItems objectAtIndex:i];
            CLLocationDistance distance = [mapItem.placemark.location distanceFromLocation:self.userLocation];
            float milsDistance = distance/1609.34;
            CoffeeShop *coffeeShop = [CoffeeShop new];
            coffeeShop.mapItem = mapItem;
            coffeeShop.distance = milsDistance;
            [tempArray addObject:coffeeShop];
        }
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:true];
        NSArray *sortedArray = [tempArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        self.coffeeShops = [NSArray arrayWithArray:sortedArray];
        
        for (CoffeeShop *coffeeShop in self.coffeeShops) {
            NSLog(@"%f", coffeeShop.distance);
        }
        [self.tableView reloadData];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    DirectionsViewController *dvc = segue.destinationViewController;
    dvc.coffeeshop = [self.coffeeShops objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    dvc.userLocation = self.userLocation;
    
    
    
}
@end
