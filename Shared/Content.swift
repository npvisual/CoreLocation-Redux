//
//  ContentView.swift
//  Shared
//
//  Created by Nicolas Philippe on 9/14/20.
//

import SwiftUI
import SwiftRex
import CombineRex
import CombineRextensions

struct Content: View {
    
    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>
    
    var body: some View {
        VStack {
            Text(viewModel.state.titleView)
                .font(.title)
                .padding()
            Form {
                Section(header: Text(viewModel.state.sectionAuthorizationTitle)) {
                    Text(viewModel.state.textAuthorization.title + viewModel.state.textAuthorization.value)
                    Text("Authorization accuracy : Unknown")
                    Button(
                        viewModel.state.buttonAuthorizationRequest.title.localizedCapitalized,
                        action: {
                            viewModel.state.buttonAuthorizationRequest.action.map { action in viewModel.dispatch(action) }
                        }
                    )
                }
                Section {
                    Text(viewModel.state.locationInformation.title + viewModel.state.locationInformation.value)
                }
                Section(header: Text(viewModel.state.sectionLocationMonitoringTitle)) {
                    Toggle(
                        viewModel: viewModel,
                        state: \.toggleLocationServices.value,
                        onToggle: { ViewAction.toggleA($0) }) {
                        Text(viewModel.state.toggleLocationServices.title)
                    }
                    Button(
                        viewModel.state.buttonLocationRequest.title.localizedCapitalized,
                        action: {
                            viewModel.state.buttonLocationRequest.action.map { action in viewModel.dispatch(action) }
                        }
                    )
                }
                Section(header: Text(viewModel.state.sectionSLCMonitoringTitle)) {
                    Toggle(
                        viewModel: viewModel,
                        state: \.toggleSCLServices.value,
                        onToggle: { ViewAction.toggleA($0) }) {
                        Text(viewModel.state.toggleSCLServices.title)
                    }
                }
                Section(header: Text(viewModel.state.sectionRegionMonitoringTitle)) {
                    Toggle(isOn: .constant(false)) {
                        Text("Region Monitoring")
                    }
                }
                Section(header: Text(viewModel.state.sectionBeaconRangingTitle)) {
                    Toggle(isOn: .constant(false)) {
                        Text("Beacon Ranging")
                    }
                }
            }
        }
    }
}

struct Content_Previews: PreviewProvider {
    
    static let mockState = AppState.mock
    static let mockStore = ObservableViewModel<AppAction, AppState>.mock(
        state: mockState,
        action: { action, _, state in
            state = Reducer.app.reduce(action, state)
        }
    )
    static let mockViewModel = ObservableViewModel.content(store: mockStore)
    
    static var previews: some View {
        Content(viewModel: mockViewModel)
    }
}

extension Content {
    enum ViewAction: Equatable {
        case toggleA(Bool)
        case button1Tapped
        case authorizationButtonTapped
    }
    
    struct ViewState: Equatable {
        let titleView: String
        let sectionAuthorizationTitle: String
        let sectionLocationMonitoringTitle: String
        let sectionSLCMonitoringTitle: String
        let sectionRegionMonitoringTitle: String
        let sectionBeaconRangingTitle: String
        let toggleLocationServices: ContentItem<Bool>
        let toggleSCLServices: ContentItem<Bool>
        let buttonAuthorizationRequest: ContentItem<String>
        let buttonLocationRequest: ContentItem<String>
        let locationInformation: ContentItem<String>
        let textAuthorization: ContentItem<String>
        
        
        static var empty: ViewState {
            .init(
                titleView: "",
                sectionAuthorizationTitle: "",
                sectionLocationMonitoringTitle: "",
                sectionSLCMonitoringTitle: "",
                sectionRegionMonitoringTitle: "",
                sectionBeaconRangingTitle: "",
                toggleLocationServices: Content.ContentItem(title: "", value: false),
                toggleSCLServices: Content.ContentItem(title: "", value: false),
                buttonAuthorizationRequest: Content.ContentItem(title: "", value: ""),
                buttonLocationRequest: Content.ContentItem(title: "", value: ""),
                locationInformation: Content.ContentItem(title: "", value: ""),
                textAuthorization: Content.ContentItem(title: "", value: "")
            )
        }
    }
    
    struct ContentItem<T>: Equatable where T:Equatable {
        let title: String
        let value: T
        var action: ViewAction? = nil
    }
}
