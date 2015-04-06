//
//  MapViewController.m
//  SidebarDemo
//
//  Created by James Cross on 30/6/13.
//  Copyright (c) 2015 Colibri. All rights reserved.
//

#import "MapViewController.h"
#import "SWRevealViewController.h"
#import "ProductDetailViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController {
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
    CLLocationManager *locationManager;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initialiseMenuItems
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5.0, 0.0, 320.0, 44.0)];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 310.0, 44.0)];
    searchBarView.autoresizingMask = 0;
    self.searchBar.delegate = self;
    //searchBar.backgroundImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MaiaMall-Logo-Light" ofType: @"jpg"]];
    self.searchBar.backgroundImage = [[UIImage alloc] init];
    
    
    [searchBarView addSubview:self.searchBar];
    self.navigationItem.titleView = searchBarView;
    
    self.arrayWithSearchResults = [[NSMutableArray alloc] init];

    self.tabBarController.delegate = self;
}

- (void)initMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(-5, 63, 331, 457) camera:camera];
    mapView_.myLocationEnabled = YES;
    [self.view addSubview:mapView_];
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestAlwaysAuthorization];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
    
    mapView_.delegate = self;
    
    self.arrayWithStoresWhichAlreadyOnTheMap = [[NSMutableArray alloc] init];
    self.arrayWithSearchResultsBeforeFiltering = [[NSMutableArray alloc] init];
    
    [self populateMapWithData];

    
//    // Creates a marker in the center of the map.
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
//    marker.title = @"Sydney";
//    marker.snippet = @"Australia";
//    marker.map = mapView_;
}

- (void)dealloc {
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initialiseMenuItems];
    
    [self initMap];

}

/*- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    
    [self initialiseMenuItems];
}*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
    
    [self initialiseMenuItems];
}

- (void)viewWillDisappear:(BOOL)animated {
    [locationManager stopUpdatingLocation];
    [super viewWillDisappear:animated];
}


-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        UINavigationController *map = [storyboard instantiateViewControllerWithIdentifier:@"profileNav"];
        
        [self showViewController:map sender:self];
        
    } else if (item.tag == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        UINavigationController *map = [storyboard instantiateViewControllerWithIdentifier:@"mapNav"];
        
        // [self performSegueWithIdentifier:@"mapNav" sender:self];
        
        [self showViewController:map sender:self];
    } else if (item.tag == 2) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        UINavigationController *map = [storyboard instantiateViewControllerWithIdentifier:@"homeNav"];
        
        // [self performSegueWithIdentifier:@"mapNav" sender:self];
        
        [self showViewController:map sender:self];

    } else if (item.tag == 3) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        UINavigationController *map = [storyboard instantiateViewControllerWithIdentifier:@"blogNav"];
        
        // [self performSegueWithIdentifier:@"mapNav" sender:self];
        
        [self showViewController:map sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Searching...";
    
    dispatch_async(dispatch_queue_create("Search", nil), ^{
        NSMutableArray * arrayWithSearchResults = [[NSMutableArray alloc] init];
        
        for (MMDItem* item in [[MMDDataBase database] arrayWithItems]) {
            if ([[item.itemTitle lowercaseString] rangeOfString:[searchBar.text lowercaseString]].location != NSNotFound) {
                [arrayWithSearchResults addObject:item];
            }
        }
        
        if (arrayWithSearchResults.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                
                self.arrayWithSearchResults = arrayWithSearchResults;
                
                [self populateMapWithData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"No Results Found";
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });
        }
        
    });
    
}

- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.searchBar resignFirstResponder];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    [self.searchBar resignFirstResponder];
    for (NSDictionary * dictWithMarkerAndData in self.arrayWithStoresWhichAlreadyOnTheMap) {
        if ([marker isEqual:[dictWithMarkerAndData objectForKey:@"marker"]]) {
            if (((NSMutableArray*)[[dictWithMarkerAndData objectForKey:@"data"] objectForKey:kStoreItems]).count == 1) {
                UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                ProductDetailViewController * detailPage = [storyboard instantiateViewControllerWithIdentifier:@"prodDetailView"];
                [detailPage initWithItem:[((NSMutableArray*)[[dictWithMarkerAndData objectForKey:@"data"] objectForKey:kStoreItems]) firstObject]];
                [self.navigationController pushViewController:detailPage animated:YES];
            } else if (((NSMutableArray*)[[dictWithMarkerAndData objectForKey:@"data"] objectForKey:kStoreItems]).count > 1) {
               UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                 ListOfItemsInTheStoreViewController* listPage = [storyboard instantiateViewControllerWithIdentifier:@"listOfItemsInTheStore"];
                [listPage initWithDict:[[NSMutableDictionary alloc] initWithDictionary:[dictWithMarkerAndData objectForKey:@"data"]]];
                [self.navigationController pushViewController:listPage animated:YES];
            }
        }
    }
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    [self.searchBar resignFirstResponder];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    [self.searchBar resignFirstResponder];
    return NO;
}

#pragma mark - working with the map

- (void)populateMapWithData {
    
    if (self.arrayWithStoresWhichAlreadyOnTheMap.count > 0) {
        [mapView_ clear];
        [self.arrayWithStoresWhichAlreadyOnTheMap removeAllObjects];
    }
    
    //getting stores with list of products in them
    NSMutableArray * arrayWithStoresAndArrayOfItemsAvailableInThatStore = [[NSMutableArray alloc] init];
    
    for (MMDItem* item in self.arrayWithSearchResults) {
        
        if (arrayWithStoresAndArrayOfItemsAvailableInThatStore.count == 0) {
            
            [arrayWithStoresAndArrayOfItemsAvailableInThatStore addObject:[NSMutableDictionary dictionaryWithObjects:@[item.itemStore.storeId, item.itemStore.storeTitle, [NSNumber numberWithDouble:item.itemStore.storeLatitude], [NSNumber numberWithDouble:item.itemStore.storeLongitude], [NSMutableArray arrayWithObject:item]] forKeys:@[kStoreId, kStoreTitle, kStoreLatitude, kStoreLongitude, kStoreItems]]];
            
        } else if (![arrayWithStoresAndArrayOfItemsAvailableInThatStore containsObject:item]){
            
            
            for (int i = 0; i < arrayWithStoresAndArrayOfItemsAvailableInThatStore.count; i++) {
                
                if ([[[arrayWithStoresAndArrayOfItemsAvailableInThatStore objectAtIndex:i] objectForKey:kStoreId] isEqualToString:item.itemStore.storeId]) {
                    [[[arrayWithStoresAndArrayOfItemsAvailableInThatStore objectAtIndex:i] objectForKey:kStoreItems] addObject:item];
                    break;
                } else if (i == arrayWithStoresAndArrayOfItemsAvailableInThatStore.count - 1) {
                    [arrayWithStoresAndArrayOfItemsAvailableInThatStore addObject:[NSMutableDictionary dictionaryWithObjects:@[item.itemStore.storeId, item.itemStore.storeTitle, [NSNumber numberWithDouble:item.itemStore.storeLatitude], [NSNumber numberWithDouble:item.itemStore.storeLongitude], [NSMutableArray arrayWithObject:item]] forKeys:@[kStoreId, kStoreTitle, kStoreLatitude, kStoreLongitude, kStoreItems]]];
                    break;
                }
            }
            
        }
    }
    
    //adding stores to map
    
    for (NSMutableDictionary * dict in arrayWithStoresAndArrayOfItemsAvailableInThatStore) {
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[dict objectForKey:kStoreLatitude] doubleValue], [[dict objectForKey:kStoreLongitude] doubleValue]);
        
        GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
        MMDItem * item = [[dict objectForKey:kStoreItems] firstObject];
        
        marker.title =  [dict objectForKey:kStoreTitle];
        
        if (((NSMutableArray*)[dict objectForKey:kStoreItems]).count == 1) {
            marker.snippet =  item.itemTitle;
        } else if (((NSMutableArray*)[dict objectForKey:kStoreItems]).count > 1) {
            marker.snippet = [NSString stringWithFormat:@"%@ & more", item.itemTitle];
        }
        
        marker.flat = YES;
        
        CGFloat widthOfMarker = 50;
        CGFloat heightOfMarker = 50;
        
        CGFloat widthOfMarkersBoard = 1;
        CGFloat heightOfMarkersTail = heightOfMarker/10 + 1; //this is just works ;)
        
        UIImage * imageOfBubble = [UIImage imageNamed:@"bubbleView"];
        
        UIGraphicsBeginImageContext(CGSizeMake(widthOfMarker, heightOfMarker));
        [imageOfBubble drawInRect:CGRectMake(0, 0, widthOfMarker, heightOfMarker)];
        [item.itemImage drawInRect:CGRectMake(widthOfMarkersBoard, widthOfMarkersBoard, widthOfMarker-widthOfMarkersBoard*2, heightOfMarker - (heightOfMarkersTail + widthOfMarkersBoard))];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        marker.icon = newImage;
        
        marker.map = mapView_;
        
        [self.arrayWithStoresWhichAlreadyOnTheMap addObject:@{@"marker":marker, @"data":[NSMutableDictionary dictionaryWithDictionary:dict]}];
        
    }
    
    [self focusMapToShowAllMarkers];
    
}

- (void)focusMapToShowAllMarkers
{
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    
    for (NSDictionary *dict in self.arrayWithStoresWhichAlreadyOnTheMap) {
        bounds = [bounds includingCoordinate:((GMSMarker*)[dict objectForKey:@"marker"]).position];
    }
    
    [mapView_ animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:100.0f]];
    
    
}



@end
