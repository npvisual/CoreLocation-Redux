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

enum AppAction {
    case toggleLocationServices(Bool)
}

struct AppState: Equatable {
    
    // Static content
    let appTitle = "Core Location with Redux !"
    let appUsage = "Use the toggle switches to turn on/off some of the Core Location services."
    let titleLocationServices = "Location Services"
    let titleSLCServices = "SLC Monitoring"
    let titleRegionMonitoring = "Region Monitoring"
    let titleBeaconRanging = "Beacon Ranging"
    
    // Application logic
    let isLocationEnabled: Bool
    let isLocationCapable: Bool
    let isGPSCapable: Bool
    let isSignificantLocationChangeEnabled: Bool = false
    let isRegionMonitoringEnabled: Bool = false
    
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
            }
        },
        outputActionMap: { action in
            switch action {
            case .startMonitoring: return AppAction.toggleLocationServices(true)
            case .stopMonitoring: return AppAction.toggleLocationServices(false)
            default: return AppAction.toggleLocationServices(false)
            }
        },
        stateMap: { _ in
            LocationState.notAuthorized
        }
    )

// MARK: - REDUCERS
extension Reducer where ActionType == AppAction, StateType == AppState {
    static let app = Reducer { action, state in
        switch action {
        case let .toggleLocationServices(value):
            return AppState(
                isLocationEnabled: value,
                isLocationCapable: state.isLocationCapable,
                isGPSCapable: state.isGPSCapable
            )
        }
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
        case .button1Tapped: return nil
        case .button2Tapped: return nil
        }
    }
    
    private static func transform(from state: AppState) -> Content.ViewState {
        Content.ViewState(
            titleView: state.appTitle,
            toggleA: Content.ContentItem(title: state.titleLocationServices, value: state.isLocationEnabled),
            toggleB: Content.ContentItem(title: state.titleSLCServices, value: false),
            textFieldA: Content.ContentItem(title: "Position : ", value: "Lat: xxx, Lon: xxx"),
            textFieldB: Content.ContentItem(title: "Authorization Status : ", value: "Unknown")
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
