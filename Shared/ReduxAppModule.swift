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
    case toggleLocationServices(Bool)
    case toggleAuthorization(Bool)
    case lastKnownPosition(CLLocation)
    case requestPosition
    case triggerError(Error)
}

struct AppState: Equatable {
    
    // Static content
    let appTitle = "Core Location with Redux !"
    let appUsage = "Use the toggle switches to turn on/off some of the Core Location services."
    let titleLocationServices = "Location Services"
    let titleSLCServices = "SLC Monitoring"
    let titleRegionMonitoring = "Region Monitoring"
    let titleBeaconRanging = "Beacon Ranging"
    let titleLocation = "Position : "
    let titleGetLocation = "Request Position !"
    let titleAuthorizationStatus = "Authorization Status : "
    
    // Application logic
    var isLocationEnabled: Bool
    var isLocationCapable: Bool
    var isGPSCapable: Bool
    var isSignificantLocationChangeEnabled: Bool = false
    var isRegionMonitoringEnabled: Bool = false
    var isAuthorized: Bool = false
    
    var location: CLLocation = CLLocation()
    
    var error: String = ""
    
    static var empty: AppState {
        .init(
            isLocationEnabled: false,
            isLocationCapable: false,
            isGPSCapable: false)
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
            case let .toggleLocationServices(status):
                if status {
                    return LocationAction.startMonitoring
                } else {
                    return LocationAction.stopMonitoring
                }
            case .requestPosition: return LocationAction.startMonitoring
            default: return nil
            }
        },
        outputActionMap: { action in
            switch action {
            case .startMonitoring: return AppAction.toggleLocationServices(true)
            case .stopMonitoring: return AppAction.toggleLocationServices(false)
            case .authorized: return AppAction.toggleAuthorization(true)
            case let .gotPosition(location): return AppAction.lastKnownPosition(location)
            case let .receiveError(error): return AppAction.triggerError(error)
            default: return AppAction.toggleLocationServices(false)
            }
        },
        stateMap: { globalState in
            if globalState.isAuthorized && globalState.isLocationEnabled {
                return LocationState.authorized(lastPosition: globalState.location)
            } else {
                return LocationState.notAuthorized
            }
        }
    )

// MARK: - REDUCERS
extension Reducer where ActionType == AppAction, StateType == AppState {
    static let app = Reducer { action, state in
        var state = state
        switch action {
        case let .toggleLocationServices(status): state.isLocationEnabled = status
        case let .toggleAuthorization(status): state.isAuthorized = status
        case let .lastKnownPosition(location): state.location = location
        case .requestPosition: break
        case let .triggerError(error): state.error = error.localizedDescription
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
        case .toggleA(let value): return .toggleLocationServices(value)
        case .button1Tapped: return .requestPosition
        case .button2Tapped: return nil
        }
    }
    
    private static func transform(from state: AppState) -> Content.ViewState {
        Content.ViewState(
            titleView: state.appTitle,
            toggleA: Content.ContentItem(title: state.titleLocationServices, value: state.isLocationEnabled),
            toggleB: Content.ContentItem(title: state.titleSLCServices, value: false),
            button1: Content.ContentItem(title: state.titleGetLocation, value: "", action: .button1Tapped),
            textFieldA: Content.ContentItem(
                title: state.titleLocation,
                value: "Lat : " + state.location.coordinate.latitude.description + "; Lon : " + state.location.coordinate.longitude.description
            ),
            textFieldB: Content.ContentItem(title: state.titleAuthorizationStatus, value: state.isAuthorized.description)
        )
    }
}

// MARK: - VIEW PRODUCERS
extension ViewProducer where Context == Void, ProducedView == Content {
    static func content<S: StoreType>(store: S) -> ViewProducer
    where S.ActionType == AppAction, S.StateType == AppState {
        ViewProducer {
            Content(viewModel: .content(store: store))
        }
    }
}
