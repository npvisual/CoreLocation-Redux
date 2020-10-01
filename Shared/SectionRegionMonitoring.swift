//
//  SectionRegionMonitoring.swift
//  CoreLocation-Redux
//
//  Created by Nicolas Philippe on 9/30/20.
//

import SwiftUI
import SwiftRex
import CombineRex

struct SectionRegionMonitoring: View {

    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>

    var body: some View {
        Section(header: Text(viewModel.state.sectionRegionMonitoringTitle)) {
            Toggle(
                viewModel: viewModel,
                state: \.toggleRegionMonitoringServices.value,
                onToggle: { ViewAction.toggleRegionMonitoring($0) }) {
                Text(viewModel.state.toggleRegionMonitoringServices.title)
            }
            Text(viewModel.state.regionInformation.title +
                    viewModel.state.regionInformation.value)
                .truncationMode(.tail)
                .allowsTightening(true)
            Text("Using region with latitude: 51.50998, longitude: -0.1337")
                .font(.footnote)
            Button(
                viewModel.state.buttonRegionStateRequest.title.localizedCapitalized,
                action: {
                    viewModel.state.buttonRegionStateRequest.action.map { action in viewModel.dispatch(action) }
                }
            )
        }
    }
}

struct SectionRegionMonitoring_Previews: PreviewProvider {

    static let mockState = AppState.mock
    static let mockStore = ObservableViewModel<AppAction, AppState>.mock(
        state: mockState,
        action: { action, _, state in
            state = Reducer.app.reduce(action, state)
        }
    )
    static let mockViewModel = ObservableViewModel.regionSection(store: mockStore)

    static var previews: some View {
        SectionRegionMonitoring(viewModel: mockViewModel)
    }
}

extension SectionRegionMonitoring {
    enum ViewAction: Equatable {
        case toggleRegionMonitoring(Bool)
        case getRegionStateButtonTapped
    }
    
    struct ViewState: Equatable {
        let sectionRegionMonitoringTitle: String
        let toggleRegionMonitoringServices: ContentItem<Bool>
        let regionInformation: ContentItem<String>
        let buttonRegionStateRequest: ContentItem<String>

        static var empty: ViewState {
            .init(
                sectionRegionMonitoringTitle: "",
                toggleRegionMonitoringServices: SectionRegionMonitoring.ContentItem(title: "", value: false),
                regionInformation: SectionRegionMonitoring.ContentItem(title: "", value: ""),
                buttonRegionStateRequest: SectionRegionMonitoring.ContentItem(title: "", value: "")
            )
        }
    }
    
    struct ContentItem<T>: Equatable where T:Equatable {
        let title: String
        let value: T
        var action: ViewAction? = nil
    }

}
