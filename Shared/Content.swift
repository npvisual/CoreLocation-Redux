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
                    Toggle(
                        viewModel: viewModel,
                        state: \.toggleAuthType.value,
                        onToggle: { ViewAction.toggleAuthType($0) }) {
                        Text(viewModel.state.toggleAuthType.title)
                    }
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
                    Text(viewModel.state.errorInformation.title + viewModel.state.errorInformation.value)
                        .truncationMode(.tail)
                        .allowsTightening(true)
                }
                Section(header: Text(viewModel.state.sectionLocationMonitoringTitle)) {
                    Toggle(
                        viewModel: viewModel,
                        state: \.toggleLocationServices.value,
                        onToggle: { ViewAction.toggleLocationMonitoring($0) }) {
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
                        onToggle: { ViewAction.toggleLocationMonitoring($0) }) {
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
                Section(header:
                            Text(viewModel.state.sectionDeviceCapabilitiesTitle)) {
                    Text(viewModel.state.textIsSLCCapable.title + viewModel.state.textIsSLCCapable.value.description)
                    Text(viewModel.state.textIsRegionMonitoringCapable.title + viewModel.state.textIsRegionMonitoringCapable.value.description)
                    Text(viewModel.state.textIsRangingCapable.title + viewModel.state.textIsRangingCapable.value.description)
                    Text(viewModel.state.textIsHeadingCapable.title + viewModel.state.textIsHeadingCapable.value.description)
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
        case toggleAuthType(Bool)
        case toggleLocationMonitoring(Bool)
        case getAuthorizationButtonTapped
        case getPositionButtonTapped
    }
    
    struct ViewState: Equatable {
        let titleView: String
        let sectionAuthorizationTitle: String
        let sectionLocationMonitoringTitle: String
        let sectionSLCMonitoringTitle: String
        let sectionRegionMonitoringTitle: String
        let sectionBeaconRangingTitle: String
        let sectionDeviceCapabilitiesTitle: String
        let toggleAuthType: ContentItem<Bool>
        let toggleLocationServices: ContentItem<Bool>
        let toggleSCLServices: ContentItem<Bool>
        let buttonAuthorizationRequest: ContentItem<String>
        let buttonLocationRequest: ContentItem<String>
        let locationInformation: ContentItem<String>
        let errorInformation: ContentItem<String>
        let textAuthorization: ContentItem<String>
        let textIsSLCCapable: ContentItem<Bool>
        let textIsRegionMonitoringCapable: ContentItem<Bool>
        let textIsRangingCapable: ContentItem<Bool>
        let textIsHeadingCapable: ContentItem<Bool>
        
        
        static var empty: ViewState {
            .init(
                titleView: "",
                sectionAuthorizationTitle: "",
                sectionLocationMonitoringTitle: "",
                sectionSLCMonitoringTitle: "",
                sectionRegionMonitoringTitle: "",
                sectionBeaconRangingTitle: "",
                sectionDeviceCapabilitiesTitle: "",
                toggleAuthType: Content.ContentItem(title: "", value: false),
                toggleLocationServices: Content.ContentItem(title: "", value: false),
                toggleSCLServices: Content.ContentItem(title: "", value: false),
                buttonAuthorizationRequest: Content.ContentItem(title: "", value: ""),
                buttonLocationRequest: Content.ContentItem(title: "", value: ""),
                locationInformation: Content.ContentItem(title: "", value: ""),
                errorInformation: Content.ContentItem(title: "", value: ""),
                textAuthorization: Content.ContentItem(title: "", value: ""),
                textIsSLCCapable: Content.ContentItem(title: "", value: false),
                textIsRegionMonitoringCapable: Content.ContentItem(title: "", value: false),
                textIsRangingCapable: Content.ContentItem(title: "", value: false),
                textIsHeadingCapable: Content.ContentItem(title: "", value: false)
            )
        }
    }
    
    struct ContentItem<T>: Equatable where T:Equatable {
        let title: String
        let value: T
        var action: ViewAction? = nil
    }
}
