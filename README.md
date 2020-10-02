# CoreLocation-Redux
A sample Redux app to test the [CoreLocationMiddleware](https://github.com/SwiftRex/CoreLocationMiddleware)

This version contains : 

* start / stop standard and significant location changes monitoring services,
* listens to [location updates](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423615-locationmanager) from the CLLocationManager delegate and dispatches the CLLocation data back to the store,
* listens to [authorization changes](https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/3563956-locationmanagerdidchangeauthoriz) from the CLLocationManager delegate and dispatches the authorization status and location accuracy (if available) back to the store
* support for region monitoring
* support for iBeacon ranging (doesn't act as an iBeacon, simply looks for one)
* support for visit-related events
* support for heading updates

For more information on using Beacon Ranging, please take a look at[this post](https://github.com/npvisual/CoreLocation-Redux/wiki/Using-Beacon-Ranging) on the Wiki. Setting up an iBeacon for playing with beacon ranging isn't too complicated, but is somewhat out of scope for this middleware. Luckily, Apple provides a project that can be downloaded and easily used on a secondary device to test beacon ranging.
