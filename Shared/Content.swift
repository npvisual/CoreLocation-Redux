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
    let authzSectionProducer: ViewProducer<Void, SectionAuthorization>
    let locationSectionProducer: ViewProducer<Void, SectionLocationMonitoring>
    let capabilitiesSectionProducer: ViewProducer<Void, SectionDeviceCapabilities>
    
    var body: some View {
        VStack {
            Text(viewModel.state.titleView)
                .font(.title)
                .padding()
            Form {
                authzSectionProducer.view()
                Section {
                    Text(viewModel.state.locationInformation.title + viewModel.state.locationInformation.value)
                    Text(viewModel.state.errorInformation.title + viewModel.state.errorInformation.value)
                        .truncationMode(.tail)
                        .allowsTightening(true)
                }
                locationSectionProducer.view()
                Section(header: Text(viewModel.state.sectionSLCMonitoringTitle)) {
                    Toggle(
                        viewModel: viewModel,
                        state: \.toggleSCLServices.value,
                        onToggle: { ViewAction.toggleSLCMonitoring($0) }) {
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
                capabilitiesSectionProducer.view()
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
    static let mockAuthzSectionProducer = ViewProducer.authzSection(store: mockStore)
    static let mockLocationSectionProducer = ViewProducer.locationSection(store: mockStore)
    static let mockCapabilitiesSectionProducer = ViewProducer.capabilitiesSection(store: mockStore)
    
    static var previews: some View {
        Content(
            viewModel: mockViewModel,
            authzSectionProducer: mockAuthzSectionProducer,
            locationSectionProducer: mockLocationSectionProducer,
            capabilitiesSectionProducer: mockCapabilitiesSectionProducer
        )
    }
}

extension Content {
    enum ViewAction: Equatable {
        case toggleLocationMonitoring(Bool)
        case toggleSLCMonitoring(Bool)
        case getPositionButtonTapped
    }
    
    struct ViewState: Equatable {
        let titleView: String
        let sectionLocationMonitoringTitle: String
        let sectionSLCMonitoringTitle: String
        let sectionRegionMonitoringTitle: String
        let sectionBeaconRangingTitle: String
        let toggleLocationServices: ContentItem<Bool>
        let toggleSCLServices: ContentItem<Bool>
        let buttonLocationRequest: ContentItem<String>
        let locationInformation: ContentItem<String>
        let errorInformation: ContentItem<String>
        
        static var empty: ViewState {
            .init(
                titleView: "",
                sectionLocationMonitoringTitle: "",
                sectionSLCMonitoringTitle: "",
                sectionRegionMonitoringTitle: "",
                sectionBeaconRangingTitle: "",
                toggleLocationServices: ContentItem(title: "", value: false),
                toggleSCLServices: ContentItem(title: "", value: false),
                buttonLocationRequest: ContentItem(title: "", value: ""),
                locationInformation: ContentItem(title: "", value: ""),
                errorInformation: ContentItem(title: "", value: "")
            )
        }
    }
    
    struct ContentItem<T>: Equatable where T:Equatable {
        let title: String
        let value: T
        var action: ViewAction? = nil
    }
}
