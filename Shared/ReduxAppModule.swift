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
    case gotAuthorizationStatus(AuthzStatus)
    case lastKnownPosition(CLLocation)
    case lastKnownHeading(CLHeading)
    case gotDeviceCapabilities(DeviceCapabilities)
    case requestAuthorizationType
    case requestPosition
    case requestDeviceCapabilities
    case triggerError(Error)
}

struct AppState: Equatable {
    
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
    let labelHeading = "Heading : "
    let labelAccuracy = "Authorization accuracy : "
    let labelGetLocation = "Request Position !"
    let labelToggleLocationServices = "Monitor Location"
    let labelToggleSCLMonitoring = "Significant Location"
    let labelToggleHeadingMonitoring = "Update Heading"
    let labelToggleVisitsMonitoring = "Receive Visit-related Events"
    let labelToggleAuthType = "Request Always On (no impact on status) ?"
    let labelIsAvailableSLC = "SLC service : "
    let labelIsAvailableHeading = "Heading-related events : "
    let labelIsAvailableMonitoring = "Region Monitoring for CLCircularRegion : "
    let labelIsAvailableRanging = "Ranging for iBeacon : "
    let labelErrorInformation = "Error : "
    
    // MARK: - Application logic
    
    // Service status
    var isAuthorized: Bool = false
    var isLocationEnabled: Bool
    var isSLCEnabled: Bool = false
    var isHeadingEnabled: Bool = false
    // Device Capabilities
    var isSignificantLocationChangeCapable: Bool = false
    var isRegionMonitoringCapable: Bool = false
    var isRangingCapable: Bool = false
    var isGPSCapable: Bool = false                          // Heading capability
    var isLocationServiceCapable: Bool = false
    // Authorization data
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var authorizationType: AuthzType = .whenInUse
    var authorizationAccuracy: CLAccuracyAuthorization? = .none
    // Location data
    var location: CLLocation = CLLocation()
    var heading: CLHeading? = nil
    
    var error: String = ""
    
    static var empty: AppState {
        .init(isLocationEnabled: false)
    }
    
    static var mock: AppState {
        .init(isLocationEnabled: false)
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
            case .location(.requestPosition): return .request(.requestPosition)
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
        case let .toggleLocationServices(status): state.isLocationEnabled = status
        case let .toggleAuthorizationType(status): state.authorizationType = status ? .always : .whenInUse
        case let .toggleSLCMonitoring(status): state.isSLCEnabled = status
        case let .toggleHeadingUpdates(status): state.isHeadingEnabled = status
        case let .lastKnownPosition(location):
            state.location = location
            state.error = ""
        case let .lastKnownHeading(heading):
            state.heading = heading
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
            state.isGPSCapable = capabilities.isHeadingAvailable
            state.isRegionMonitoringCapable = capabilities.isRegionMonitoringAvailable
            state.isRangingCapable = capabilities.isRangingAvailable
            state.isLocationServiceCapable = capabilities.isLocationServiceAvailable
        case .requestAuthorizationType,
             .requestPosition,
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
        case let .toggleHeadingServices(value): return .location(.toggleHeadingUpdates(value))
        case .getPositionButtonTapped: return .location(.requestPosition)
        }
    }
    
    private static func transform(from state: AppState) -> Content.ViewState {
        
        return Content.ViewState(
            titleView: state.appTitle,
            sectionLocationMonitoringTitle: state.titleLocationServices,
            sectionHeadingUpdatesTitle: state.titleHeadingMonitoring,
            sectionRegionMonitoringTitle: state.titleRegionMonitoring,
            sectionBeaconRangingTitle: state.titleBeaconRanging,
            toggleLocationServices: Content.ContentItem(title: state.labelToggleLocationServices, value: state.isLocationEnabled),
            toggleHeadingServices: Content.ContentItem(title: state.titleHeadingMonitoring, value: state.isHeadingEnabled),
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
            toggleLocationServices: SectionLocationMonitoring.ContentItem(title: state.labelToggleLocationServices, value: state.isLocationEnabled),
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
            textIsHeadingCapable: SectionDeviceCapabilities.ContentItem(title: state.labelIsAvailableHeading, value: state.isGPSCapable)
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
            headingInformation: SectionInformation.ContentItem(
                title: state.labelHeading,
                value: state.heading?.description ?? ""
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
