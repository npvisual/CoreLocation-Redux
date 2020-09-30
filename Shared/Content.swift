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
    let informationSectionProducer: ViewProducer<Void, SectionInformation>
    let slcSectionProducer: ViewProducer<Void, SectionSLCMonitoring>
    let capabilitiesSectionProducer: ViewProducer<Void, SectionDeviceCapabilities>
    
    var body: some View {
        VStack {
            Text(viewModel.state.titleView)
                .font(.title)
                .padding()
            Form {
                authzSectionProducer.view()
                locationSectionProducer.view()
                informationSectionProducer.view()
                slcSectionProducer.view()
                Section(header: Text(viewModel.state.sectionHeadingUpdatesTitle)) {
                    Toggle(
                        viewModel: viewModel,
                        state: \.toggleHeadingServices.value,
                        onToggle: { ViewAction.toggleHeadingServices($0) }) {
                        Text(viewModel.state.toggleHeadingServices.title)
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
    static let mockInformationSectionProducer = ViewProducer.informationSection(store: mockStore)
    static let mockSLCSectionProducer = ViewProducer.slcSection(store: mockStore)
    static let mockCapabilitiesSectionProducer = ViewProducer.capabilitiesSection(store: mockStore)
    
    static var previews: some View {
        Content(
            viewModel: mockViewModel,
            authzSectionProducer: mockAuthzSectionProducer,
            locationSectionProducer: mockLocationSectionProducer,
            informationSectionProducer: mockInformationSectionProducer,
            slcSectionProducer: mockSLCSectionProducer,
            capabilitiesSectionProducer: mockCapabilitiesSectionProducer
        )
    }
}

extension Content {
    enum ViewAction: Equatable {
        case toggleHeadingServices(Bool)
        case getPositionButtonTapped
    }
    
    struct ViewState: Equatable {
        let titleView: String
        let sectionLocationMonitoringTitle: String
        let sectionHeadingUpdatesTitle: String
        let sectionRegionMonitoringTitle: String
        let sectionBeaconRangingTitle: String
        let toggleLocationServices: ContentItem<Bool>
        let toggleHeadingServices: ContentItem<Bool>
        let buttonLocationRequest: ContentItem<String>
        
        static var empty: ViewState {
            .init(
                titleView: "",
                sectionLocationMonitoringTitle: "",
                sectionHeadingUpdatesTitle: "",
                sectionRegionMonitoringTitle: "",
                sectionBeaconRangingTitle: "",
                toggleLocationServices: ContentItem(title: "", value: false),
                toggleHeadingServices: ContentItem(title: "", value: false),
                buttonLocationRequest: ContentItem(title: "", value: "")
            )
        }
    }
    
    struct ContentItem<T>: Equatable where T:Equatable {
        let title: String
        let value: T
        var action: ViewAction? = nil
    }
}
