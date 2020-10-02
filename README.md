# CoreLocation-Redux
A sample Redux app to test the CoreLocationMiddleware

This version contains : 

* start / stop standard and significant location changes monitoring services,
* listens to [location updates](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423615-locationmanager) from the CLLocationManager delegate and dispatches the CLLocation data back to the store,
* listens to [authorization changes](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/3563956-locationmanagerdidchangeauthoriz) from the CLLocationManager delegate and dispatches the authorization status and location accuracy (if available) back to the store
* support for region monitoring
* support for iBeacon ranging (doesn't act as an iBeacon, simply looks for one)
* support for visit-related events
* support for heading updates
