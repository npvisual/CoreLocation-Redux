//
//  ContentViewModel.swift
//  CoreLocation-Redux
//
//  Created by Nicolas Philippe on 9/14/20.
//

import Foundation
import SwiftRex
import CombineRex
import CombineRextensions
import LoggerMiddleware
import CoreLocationMiddleware
import CoreLocation

enum AppAction {
    case appLifecycle(AppLifecycleAction)
    case location(CoreLocationAction)
}

enum CoreLocationAction {
    case toggleLocationServices(Bool)
    case toggleAuthorizationType(Bool)
    case toggleSLCMonitoring(Bool)
    case toggleHeadingUpdates(Bool)
    case toggleRegionMonitoring(Bool, CLRegion)
    case toggleBeaconRanging(Bool, CLBeaconIdentityConstraint)
    case toggleVisitEventUpdates(Bool)
    case pickRegionType(Int)
    case gotAuthorizationStatus(AuthzStatus)
    case lastKnownPosition(CLLocation)
    case lastKnownHeading(CLHeading)
    case lastKnownRegionEvent(CLRegion, CLRegionState)
    case lastKnownBeaconRanging([CLBeacon], CLBeaconIdentityConstraint)
    case lastKnownVisitEvent(CLVisit)
    case gotDeviceCapabilities(DeviceCapabilities)
    case requestAuthorizationType
    case requestPosition
    case requestDeviceCapabilities
    case requestRegionState(CLRegion)
    case triggerError(Error)
}

struct AppState: Equatable {
    
    // TODO: replace with a configurable region
    static let regionToMonitor: CLCircularRegion = CLCircularRegion(
        center: CLLocationCoordinate2D(latitude: 51.50998, longitude: -0.1337),
        radius: CLLocationDistance(500),
        identifier: "London, England"
    )
    // TODO: replace with a configurable beacon
    // Note that the forced unwrapped is necessary here and will always be valid.
    // The UUID is taken from the Apple project in the Core Location documentation.
    static let beaconUUID = UUID.init(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
    static let beaconIdentityConstraint: CLBeaconIdentityConstraint = CLBeaconIdentityConstraint(
        uuid: beaconUUID
    )
    static let beaconRegion: CLBeaconRegion =  CLBeaconRegion(
        beaconIdentityConstraint: beaconIdentityConstraint,
        identifier: "CoreLocation-Redux"
    )

    // MARK: - App lifecycle
    var appLifecycle: AppLifecycle = .backgroundInactive
    
    // MARK: - Static content
    
    // App related content
    let appTitle = "CoreLocation with Redux !"
    let appUsage = "Use the toggle switches to turn on/off some of the Core Location services."
    
    // Section headers
    let titleAuthorization = "Authorization"
    let titleLocationServices = "Location Monitoring"
    let titleSLCServices = "SLC Monitoring"
    let titleRegionMonitoring = "Region Monitoring"
    let titleBeaconRanging = "Beacon Ranging"
    let titleHeadingMonitoring = "Heading Updates"
    let titleVisitMonitoring = "Visits Monitoring"
    let titleDeviceCapabilities = "Device Capabilities"
    
    // Labels
    let labelAuthorizationStatus = "Authorization Status : "
    let labelGetAuthorization = "Request Authorization !"
    let labelPosition = "Position : "
    let labelInfo = "Info : "
    let labelAccuracy = "Authorization accuracy : "
    let labelGetLocation = "Request Position !"
    let labelGetRegionState = "Request Region State !"
    let labelGetBeaconState = "Request Beacon State !"
    let labelToggleLocationServices = "Monitor Location"
    let labelToggleSCLMonitoring = "Significant Location"
    let labelToggleHeadingMonitoring = "Update Heading"
    let labelToggleRegionMonitoring = "Region Monitoring"
    let labelToggleBeaconRanging = "Beacon Ranging"
    let labelToggleVisitsMonitoring = "Receive Visit-related Events"
    let labelToggleAuthType = "Request Always On (no impact on status) ?"
    let labelPickerRegionType = "Region Type : "
    let labelIsAvailableSLC = "SLC service : "
    let labelIsAvailableHeading = "Heading-related events : "
    let labelIsAvailableMonitoring = "Region Monitoring for CLCircularRegion : "
    let labelIsAvailableRanging = "Ranging for iBeacon : "
    let labelRegionMonitoringFootNote = "Region with latitude: 51.50998, longitude: -0.1337"
    let labelBeaconRangingFootNote = "Ranging beacon with identifier : " + beaconUUID.description
    let labelErrorInformation = "Error : "
    
    // MARK: - Application logic
    
    // Service status
    var isAuthorized: Bool = false
    var isLocationMonitoringEnabled: Bool
    var isSLCEnabled: Bool = false
    var isHeadingEnabled: Bool = false
    var isRegionMonitoringEnabled: Bool = false
    var isBeaconRangingEnabled: Bool = false
    var isVisitEventUpdatesEnabled: Bool = false
    // Device Capabilities
    var isSignificantLocationChangeCapable: Bool = false
    var isRegionMonitoringCapable: Bool = false
    var isRangingCapable: Bool = false
    var isHeadingCapable: Bool = false
    var isLocationServiceCapable: Bool = false
    // Authorization data
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var authorizationType: AuthzType = .whenInUse
    var authorizationAccuracy: CLAccuracyAuthorization? = .none
    // Location data
    var location: CLLocation = CLLocation()
    var heading: CLHeading? = nil
    var region: CLRegion? = nil
    var regionStatus: CLRegionState? = nil
    var beacons: [CLBeacon]? = nil
    var beaconConstraint: CLBeaconIdentityConstraint? = nil
    var visit: CLVisit? = nil
    // Configuration data
    var regionChoice: CLRegion = AppState.regionToMonitor
    var regionType: Int = 0
    var isBeaconSlave = false
    
    // Error
    var error: String = ""
    
    static var empty: AppState {
        .init(isLocationMonitoringEnabled: false)
    }
    
    static var mock: AppState {
        .init(isLocationMonitoringEnabled: false)
    }
}

// MARK: - STORE
class Store: ReduxStoreBase<AppAction, AppState> {
    private init() {
        super.init(
            subject: .combine(initialValue: .empty),
            reducer: Reducer.app,
            middleware: appMiddleware
        )
    }

    static let instance = Store()
}

// MARK: - WORLD
struct World {
    let store: () -> AnyStoreType<AppAction, AppState>
}

extension World {
    static let origin = World(
        store: { Store.instance.eraseToAnyStoreType() }
    )
}

// MARK: - MIDDLEWARE
let appMiddleware = LoggerMiddleware<IdentityMiddleware<AppAction, AppAction, AppState>>
    .default() <> CoreLocationMiddleware().lift(
        inputActionMap: { globalAction in
            switch globalAction {
            case .appLifecycle(.didBecomeActive): return .request(.requestDeviceCapabilities)
            case let .location(.toggleLocationServices(status)):
                if status {
                    return .request(.start(.locationMonitoring))
                } else {
                    return .request(.stop(.locationMonitoring))
                }
            case let .location(.toggleSLCMonitoring(status)):
                if status {
                    return .request(.start(.slcMonitoring))
                } else {
                    return .request(.stop(.slcMonitoring))
                }
            case let .location(.toggleHeadingUpdates(status)):
                if status {
                    return .request(.start(.headingUpdates))
                } else {
                    return .request(.stop(.headingUpdates))
                }
            case let .location(.toggleRegionMonitoring(status, region)):
                if status {
                    return .request(.start(.regionMonitoring(region)))
                } else {
                    return .request(.stop(.regionMonitoring(region)))
                }
            case let .location(.toggleBeaconRanging(status, constraint)):
                if status {
                    return .request(.start(.beaconRanging(constraint)))
                } else {
                    return .request(.stop(.beaconRanging(constraint)))
                }
            case let .location(.toggleVisitEventUpdates(status)):
                if status {
                    return .request(.start(.visitMonitoring))
                } else {
                    return .request(.stop(.visitMonitoring))
                }
            case .location(.requestPosition): return .request(.requestPosition)
            case let .location(.requestRegionState(region)): return .request(.requestState(region))
            case .location(.requestAuthorizationType): return .request(.requestAuthorizationType)
            case .location(.requestDeviceCapabilities): return .request(.requestDeviceCapabilities)
            default: return nil
            }
        },
        outputActionMap: { action in
            switch action {
            case let .status(.gotAuthzStatus(status)): return .location(.gotAuthorizationStatus(status))
            case let .status(.gotPosition(location)): return .location(.lastKnownPosition(location))
            case let .status(.gotHeading(heading)): return .location(.lastKnownHeading(heading))
            case let .status(.gotRegion(region, state)): return .location(.lastKnownRegionEvent(region, state))
            case let .status(.gotBeacon(beacons, constraint)): return .location(.lastKnownBeaconRanging(beacons, constraint))
            case let .status(.gotVisit(visit)): return .location(.lastKnownVisitEvent(visit))
            case let .status(.gotDeviceCapabilities(capabilities)): return .location(.gotDeviceCapabilities(capabilities))
            case let .status(.receiveError(error)): return .location(.triggerError(error))
            default: return .location(.toggleLocationServices(false))
            }
        },
        stateMap: { globalState -> LocationState in
            return LocationState(
                authzType: globalState.authorizationType,
                authzStatus: globalState.authorizationStatus,
                location: globalState.location
            )
        }
    ) <> AppLifecycleMiddleware().lift(
        inputActionMap: { _ in nil },
        outputActionMap: AppAction.appLifecycle,
        stateMap: { _ in }
    )

// MARK: - REDUCERS
extension Reducer where ActionType == AppAction, StateType == AppState {
    static let app = Reducer<AppLifecycleAction, AppLifecycle>.lifecycle.lift(
        action: \AppAction.appLifecycle,
        state: \AppState.appLifecycle
    ) <> Reducer<CoreLocationAction, AppState>.location.lift(
        action: \AppAction.location)
}

extension Reducer where ActionType == CoreLocationAction, StateType == AppState {
    static let location = Reducer { action, state in
        var state = state
        switch action {
        case let .toggleLocationServices(status): state.isLocationMonitoringEnabled = status
        case let .toggleAuthorizationType(status): state.authorizationType = status ? .always : .whenInUse
        case let .toggleSLCMonitoring(status): state.isSLCEnabled = status
        case let .toggleHeadingUpdates(status): state.isHeadingEnabled = status
        case let .toggleRegionMonitoring(status, region):
            state.isRegionMonitoringEnabled = status
            state.regionChoice = region
        case let .toggleBeaconRanging(status, constraint):
            state.isBeaconRangingEnabled = status
            state.beaconConstraint = constraint
        case let .toggleVisitEventUpdates(status): state.isVisitEventUpdatesEnabled = status
        case let .pickRegionType(type):
            state.regionType = type
        case let .lastKnownPosition(location):
            state.location = location
            state.error = ""
        case let .lastKnownHeading(heading):
            state.heading = heading
            state.error = ""
        case let .lastKnownRegionEvent(region, status):
            state.region = region
            state.regionStatus = status
            state.error = ""
        case let .lastKnownBeaconRanging(beacons, constraint):
            state.beacons = beacons
            state.beaconConstraint = constraint
            state.error = ""
        case let .lastKnownVisitEvent(visit):
            state.visit = visit
            state.error = ""
        case let .triggerError(error):
            state.error = error.localizedDescription
            state.location = CLLocation()
        case let .gotAuthorizationStatus(status):
            state.authorizationStatus = status.status
            state.authorizationAccuracy = status.accuracy
            state.error = ""
        case let .gotDeviceCapabilities(capabilities):
            state.isSignificantLocationChangeCapable = capabilities.isSignificantLocationChangeAvailable
            state.isHeadingCapable = capabilities.isHeadingAvailable
            state.isRegionMonitoringCapable = capabilities.isRegionMonitoringAvailable
            state.isRangingCapable = capabilities.isRangingAvailable
            state.isLocationServiceCapable = capabilities.isLocationServiceAvailable
        case .requestAuthorizationType,
             .requestPosition,
             .requestRegionState,
             .requestDeviceCapabilities: break
        }
        return state
    }
}

// MARK: - PROJECTIONS
extension ObservableViewModel where ViewAction == Content.ViewAction, ViewState == Content.ViewState {
    static func content<S: StoreType>(store: S) -> ObservableViewModel
    where S.ActionType == AppAction, S.StateType == AppState {
        return store
            .projection(action: Self.transform, state: Self.transform)
            .asObservableViewModel(initialState: .empty)
    }
    
    private static func transform(_ viewAction: Content.ViewAction) -> AppAction? {
        switch viewAction {
        case .getPositionButtonTapped: return .location(.requestPosition)
        }
    }
    
    private static func transform(from state: AppState) -> Content.ViewState {
        
        return Content.ViewState(
            titleView: state.appTitle,
            sectionBeaconRangingTitle: state.titleBeaconRanging,
            buttonLocationRequest: Content.ContentItem(title: state.labelGetLocation, value: "", action: .getPositionButtonTapped)
        )
    }
}

extension ObservableViewModel where ViewAction == SectionAuthorization.ViewAction, ViewState == SectionAuthorization.ViewState {
    static func authzSection<S: StoreType>(store: S) -> ObservableViewModel
    where S.ActionType == AppAction, S.StateType == AppState {
        return store
            .projection(action: Self.transform, state: Self.transform)
            .asObservableViewModel(initialState: .empty)
    }
    
    private static func transform(_ viewAction: SectionAuthorization.ViewAction) -> AppAction? {
        switch viewAction {
        case .toggleAuthType(let value): return .location(.toggleAuthorizationType(value))
        case .getAuthorizationButtonTapped: return .location(.requestAuthorizationType)
        }
    }
    
    private static func transform(from state: AppState) -> SectionAuthorization.ViewState {
        let authStatus: String
        let authAccuracy: String
        
        switch state.authorizationStatus {
        case .authorizedAlways: authStatus = "Always"
        case .authorizedWhenInUse: authStatus = "When In Use"
        case .denied: authStatus = "Denied"
        case .restricted: authStatus = "Restricted"
        default: authStatus = "Unknown"
        }
        
        switch state.authorizationAccuracy {
        case .fullAccuracy: authAccuracy = "Full"
        case .reducedAccuracy: authAccuracy = "Reduced"
        case .none: authAccuracy = "N/A"
        @unknown default: authAccuracy = "Unknown"
        }

        return SectionAuthorization.ViewState(
            sectionAuthorizationTitle: state.titleAuthorization,
            toggleAuthType: SectionAuthorization.ContentItem(title: state.labelToggleAuthType, value: [AuthzType.always].contains(state.authorizationType)),
            buttonAuthorizationRequest: SectionAuthorization.ContentItem(title: state.labelGetAuthorization, value: "", action: .getAuthorizationButtonTapped),
            textAuthorization: SectionAuthorization.ContentItem(title: state.labelAuthorizationStatus, value:authStatus),
            textAccuracy: SectionAuthorization.ContentItem(title: state.labelAccuracy, value: authAccuracy)
        )
    }
}

extension ObservableViewModel where ViewAction == SectionLocationMonitoring.ViewAction, ViewState == SectionLocationMonitoring.ViewState {
    static func locationSection<S: StoreType>(store: S) -> ObservableViewModel
    where S.ActionType == AppAction, S.StateType == AppState {
        return store
            .projection(action: Self.transform, state: Self.transform)
            .asObservableViewModel(initialState: .empty)
    }
    
    private static func transform(_ viewAction: SectionLocationMonitoring.ViewAction) -> AppAction? {
        switch viewAction {
        case .toggleLocationMonitoring(let value): return .location(.toggleLocationServices(value))
        case .getPositionButtonTapped: return .location(.requestPosition)
        }
    }
    
    private static func transform(from state: AppState) -> SectionLocationMonitoring.ViewState {
        
        return SectionLocationMonitoring.ViewState(
            sectionLocationMonitoringTitle: state.titleLocationServices,
            toggleLocationServices: SectionLocationMonitoring.ContentItem(title: state.labelToggleLocationServices, value: state.isLocationMonitoringEnabled),
            buttonLocationRequest: SectionLocationMonitoring.ContentItem(title: state.labelGetLocation, value: "", action: .getPositionButtonTapped)
        )
    }
}

extension ObservableViewModel where ViewAction == SectionDeviceCapabilities.ViewAction, ViewState == SectionDeviceCapabilities.ViewState {
    static func capabilitiesSection<S: StoreType>(store: S) -> ObservableViewModel
    where S.ActionType == AppAction, S.StateType == AppState {
        return store
            .projection(action: { _ in nil }, state: Self.transform)
            .asObservableViewModel(initialState: .empty)
    }
        
    private static func transform(from state: AppState) -> SectionDeviceCapabilities.ViewState {
        
        return SectionDeviceCapabilities.ViewState(
            sectionDeviceCapabilitiesTitle: state.titleDeviceCapabilities,
            textIsSLCCapable: SectionDeviceCapabilities.ContentItem(title: state.labelIsAvailableSLC, value: state.isSignificantLocationChangeCapable),
            textIsRegionMonitoringCapable: SectionDeviceCapabilities.ContentItem(title: state.labelIsAvailableMonitoring, value: state.isRegionMonitoringCapable),
            textIsRangingCapable: SectionDeviceCapabilities.ContentItem(title: state.labelIsAvailableRanging, value: state.isRangingCapable),
            textIsHeadingCapable: SectionDeviceCapabilities.ContentItem(title: state.labelIsAvailableHeading, value: state.isHeadingCapable)
        )
    }
}

extension ObservableViewModel where ViewAction == SectionInformation.ViewAction, ViewState == SectionInformation.ViewState {
    static func informationSection<S: StoreType>(store: S) -> ObservableViewModel
    where S.ActionType == AppAction, S.StateType == AppState {
        return store
            .projection(action: { _ in nil }, state: Self.transform)
            .asObservableViewModel(initialState: .empty)
    }
        
    private static func transform(from state: AppState) -> SectionInformation.ViewState {
        
        return SectionInformation.ViewState(
            locationInformation: SectionInformation.ContentItem(
                title: state.labelPosition,
                value: "Lat : " + state.location.coordinate.latitude.description + " ; Lon : " + state.location.coordinate.longitude.description
            ),
            errorInformation: SectionInformation.ContentItem(title: state.labelErrorInformation, value: state.error)
        )
    }
}

extension ObservableViewModel where ViewAction == SectionSLCMonitoring.ViewAction, ViewState == SectionSLCMonitoring.ViewState {
    static func slcSection<S: StoreType>(store: S) -> ObservableViewModel
    where S.ActionType == AppAction, S.StateType == AppState {
        return store
            .projection(action: Self.transform, state: Self.transform)
            .asObservableViewModel(initialState: .empty)
    }
    
    private static func transform(_ viewAction: SectionSLCMonitoring.ViewAction) -> AppAction? {
        switch viewAction {
        case let .toggleSLCMonitoring(value): return .location(.toggleSLCMonitoring(value))
        }
    }
    
    private static func transform(from state: AppState) -> SectionSLCMonitoring.ViewState {
        
        return SectionSLCMonitoring.ViewState(
            sectionSLCMonitoringTitle: state.titleSLCServices,
            toggleSCLServices: SectionSLCMonitoring.ContentItem(title: state.labelToggleSCLMonitoring, value: state.isSLCEnabled)
        )
    }
}

extension ObservableViewModel where ViewAction == SectionHeadingUpdates.ViewAction, ViewState == SectionHeadingUpdates.ViewState {
    static func headingSection<S: StoreType>(store: S) -> ObservableViewModel
    where S.ActionType == AppAction, S.StateType == AppState {
        return store
            .projection(action: Self.transform, state: Self.transform)
            .asObservableViewModel(initialState: .empty)
    }
    
    private static func transform(_ viewAction: SectionHeadingUpdates.ViewAction) -> AppAction? {
        switch viewAction {
        case let .toggleHeadingServices(value): return .location(.toggleHeadingUpdates(value))
        }
    }
    
    private static func transform(from state: AppState) -> SectionHeadingUpdates.ViewState {
        
        return SectionHeadingUpdates.ViewState(
            sectionHeadingUpdatesTitle: state.titleHeadingMonitoring,
            toggleHeadingServices: SectionHeadingUpdates.ContentItem(
                title: state.labelToggleHeadingMonitoring,
                value: state.isHeadingEnabled
            ),
            headingInformation: SectionHeadingUpdates.ContentItem(
                title: state.labelInfo,
                value: state.heading?.description ?? ""
            )
        )
    }
}

extension ObservableViewModel where ViewAction == SectionRegionMonitoring.ViewAction, ViewState == SectionRegionMonitoring.ViewState {
    static func regionSection<S: StoreType>(store: S) -> ObservableViewModel
    where S.ActionType == AppAction, S.StateType == AppState {
        return store
            .projection(action: Self.transform, state: Self.transform)
            .asObservableViewModel(initialState: .empty)
    }
    
    private static func transform(_ viewAction: SectionRegionMonitoring.ViewAction) -> AppAction? {
        switch viewAction {
        case let .pickRegionType(type): return .location(.pickRegionType(type))
        case let .toggleRegionMonitoring(status, type):
            var region: CLRegion = AppState.regionToMonitor
            if type == 1 {
                region = AppState.beaconRegion
            }
            return .location(.toggleRegionMonitoring(status, region))
        case .getRegionStateButtonTapped: return .location(.requestRegionState(AppState.regionToMonitor))
        }
    }
    
    private static func transform(from state: AppState) -> SectionRegionMonitoring.ViewState {
        
        var status: String = "N/A"
        var region: String = state.region?.identifier ?? ""
        switch state.regionStatus {
        case .inside:
            status = "Inside "
        case .outside:
            status = "Outside "
        default:
            region = ""
        }
        
        var footnote: String = state.labelRegionMonitoringFootNote
        if state.regionType == 1 {
            footnote = state.labelBeaconRangingFootNote
        }
                
        return SectionRegionMonitoring.ViewState(
            sectionRegionMonitoringTitle: state.titleRegionMonitoring,
            pickerRegionType: SectionRegionMonitoring.ContentItem(
                title: state.labelPickerRegionType,
                value: SectionRegionMonitoring.pickerConfig[state.regionType]
            ),
            toggleRegionMonitoringServices:
                SectionRegionMonitoring.ContentItem(
                    title: state.labelToggleRegionMonitoring,
                    value: state.isRegionMonitoringEnabled
                ),
            regionInformation:
                SectionRegionMonitoring.ContentItem(
                    title: state.labelInfo,
                    value: status + region
                ),
            disclaimerInfo:
                SectionRegionMonitoring.ContentItem(
                    title: "",
                    value: footnote
                ),
            buttonRegionStateRequest:
                SectionRegionMonitoring.ContentItem(
                    title: state.labelGetRegionState,
                    value: "",
                    action: .getRegionStateButtonTapped)
        )
    }
}

extension ObservableViewModel where ViewAction == SectionBeaconRanging.ViewAction, ViewState == SectionBeaconRanging.ViewState {
    static func beaconSection<S: StoreType>(store: S) -> ObservableViewModel
    where S.ActionType == AppAction, S.StateType == AppState {
        return store
            .projection(action: Self.transform, state: Self.transform)
            .asObservableViewModel(initialState: .empty)
    }
    
    private static func transform(_ viewAction: SectionBeaconRanging.ViewAction) -> AppAction? {
        switch viewAction {
        case let .toggleBeaconRanging(status): return .location(.toggleBeaconRanging(status, AppState.beaconIdentityConstraint))
        case .getBeaconStateButtonTapped: return .location(.requestRegionState(AppState.beaconRegion))
        }
    }
    
    private static func transform(from state: AppState) -> SectionBeaconRanging.ViewState {
        
        var beaconsInfo: String = ""
        
        if let beacons = state.beacons {
            beaconsInfo = beacons
                .map { (beacon: CLBeacon) in
                    beacon.uuid.uuidString + ": " + beacon.rssi.description
                }
                .reduce("") { result, info in
                    result.isEmpty ? info : result + ", " + info
                }
        }
        
        return SectionBeaconRanging.ViewState(
            sectionBeaconRangingTitle: state.titleBeaconRanging,
            toggleBeaconRangingServices:
                SectionBeaconRanging.ContentItem(
                    title: state.labelToggleBeaconRanging,
                    value: state.isBeaconRangingEnabled
                ),
            beaconInformation:
                SectionBeaconRanging.ContentItem(
                    title: state.labelInfo,
                    value: beaconsInfo
                ),
            buttonBeaconStateRequest:
                SectionBeaconRanging.ContentItem(
                    title: state.labelGetBeaconState,
                    value: "",
                    action: .getBeaconStateButtonTapped)
        )
    }
}

extension ObservableViewModel where ViewAction == SectionVisitMonitoring.ViewAction, ViewState == SectionVisitMonitoring.ViewState {
    static func visitEventsSection<S: StoreType>(store: S) -> ObservableViewModel
    where S.ActionType == AppAction, S.StateType == AppState {
        return store
            .projection(action: Self.transform, state: Self.transform)
            .asObservableViewModel(initialState: .empty)
    }
    
    private static func transform(_ viewAction: SectionVisitMonitoring.ViewAction) -> AppAction? {
        switch viewAction {
        case let .toggleVisitEventsService(value): return .location(.toggleVisitEventUpdates(value))
        }
    }
    
    private static func transform(from state: AppState) -> SectionVisitMonitoring.ViewState {
        
        return SectionVisitMonitoring.ViewState(
            sectionVisitEventUpdatesTitle: state.titleVisitMonitoring,
            toggleVisitEventsService: SectionVisitMonitoring.ContentItem(
                title: state.labelToggleVisitsMonitoring,
                value: state.isVisitEventUpdatesEnabled
            ),
            visitEventsInformation: SectionVisitMonitoring.ContentItem(
                title: state.labelInfo,
                value: state.visit?.description ?? ""
            )
        )
    }
}

// MARK: - VIEW PRODUCERS
extension ViewProducer where Context == Void, ProducedView == Content {
    static func content<S: StoreType>(store: S) -> ViewProducer
    where S.ActionType == AppAction, S.StateType == AppState {
        ViewProducer {
            Content(
                viewModel: .content(store: store),
                authzSectionProducer: .authzSection(store: store),
                locationSectionProducer: .locationSection(store: store),
                informationSectionProducer: .informationSection(store: store),
                slcSectionProducer: .slcSection(store: store),
                headingSectionProducer: .headingSection(store: store),
                regionSectionProducer: .regionSection(store: store),
                beaconSectionProducer: .beaconSection(store: store),
                visitEventsSectionProducer: .visitEventsSection(store: store),
                capabilitiesSectionProducer: .capabilitiesSection(store: store)
            )
        }
    }
}

extension ViewProducer where Context == Void, ProducedView == SectionAuthorization {
    static func authzSection<S: StoreType>(store: S) -> ViewProducer
    where S.ActionType == AppAction, S.StateType == AppState {
        ViewProducer {
            SectionAuthorization(viewModel: .authzSection(store: store))
        }
    }
}

extension ViewProducer where Context == Void, ProducedView == SectionLocationMonitoring {
    static func locationSection<S: StoreType>(store: S) -> ViewProducer
    where S.ActionType == AppAction, S.StateType == AppState {
        ViewProducer {
            SectionLocationMonitoring(viewModel: .locationSection(store: store))
        }
    }
}

extension ViewProducer where Context == Void, ProducedView == SectionDeviceCapabilities {
    static func capabilitiesSection<S: StoreType>(store: S) -> ViewProducer
    where S.ActionType == AppAction, S.StateType == AppState {
        ViewProducer {
            SectionDeviceCapabilities(viewModel: .capabilitiesSection(store: store))
        }
    }
}

extension ViewProducer where Context == Void, ProducedView == SectionInformation {
    static func informationSection<S: StoreType>(store: S) -> ViewProducer
    where S.ActionType == AppAction, S.StateType == AppState {
        ViewProducer {
            SectionInformation(viewModel: .informationSection(store: store))
        }
    }
}

extension ViewProducer where Context == Void, ProducedView == SectionSLCMonitoring {
    static func slcSection<S: StoreType>(store: S) -> ViewProducer
    where S.ActionType == AppAction, S.StateType == AppState {
        ViewProducer {
            SectionSLCMonitoring(viewModel: .slcSection(store: store))
        }
    }
}

extension ViewProducer where Context == Void, ProducedView == SectionHeadingUpdates {
    static func headingSection<S: StoreType>(store: S) -> ViewProducer
    where S.ActionType == AppAction, S.StateType == AppState {
        ViewProducer {
            SectionHeadingUpdates(viewModel: .headingSection(store: store))
        }
    }
}

extension ViewProducer where Context == Void, ProducedView == SectionRegionMonitoring {
    static func regionSection<S: StoreType>(store: S) -> ViewProducer
    where S.ActionType == AppAction, S.StateType == AppState {
        ViewProducer {
            SectionRegionMonitoring(viewModel: .regionSection(store: store))
        }
    }
}

extension ViewProducer where Context == Void, ProducedView == SectionBeaconRanging {
    static func beaconSection<S: StoreType>(store: S) -> ViewProducer
    where S.ActionType == AppAction, S.StateType == AppState {
        ViewProducer {
            SectionBeaconRanging(viewModel: .beaconSection(store: store))
        }
    }
}

extension ViewProducer where Context == Void, ProducedView == SectionVisitMonitoring {
    static func visitEventsSection<S: StoreType>(store: S) -> ViewProducer
    where S.ActionType == AppAction, S.StateType == AppState {
        ViewProducer {
            SectionVisitMonitoring(viewModel: .visitEventsSection(store: store))
        }
    }
}
