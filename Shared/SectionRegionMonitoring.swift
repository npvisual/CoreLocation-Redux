//
//  SectionRegionMonitoring.swift
//  CoreLocation-Redux
//
//  Created by Nicolas Philippe on 9/30/20.
//

import SwiftUI
import SwiftRex
import CombineRex
import CombineRextensions

struct SectionRegionMonitoring: View {

    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>

    static let pickerConfig = [
        PickerOption<Int>(tag: 0, value: "Cirular Region"),
        PickerOption<Int>(tag: 1, value: "Beacon Region")
    ]

    var body: some View {
        Section(header: Text(viewModel.state.sectionRegionMonitoringTitle)) {
            Picker(
                localizedString: viewModel.state.pickerRegionType.title,
                viewModel: viewModel,
                selectionKeyPath: \.pickerRegionType.value,
                action: { tag in .pickRegionType(tag) },
                options: SectionRegionMonitoring.pickerConfig
            )
            .pickerStyle(SegmentedPickerStyle())
            Toggle(
                viewModel: viewModel,
                state: \.toggleRegionMonitoringServices.value,
                onToggle: { ViewAction.toggleRegionMonitoring($0, viewModel.state.pickerRegionType.value.tag) }) {
                Text(viewModel.state.toggleRegionMonitoringServices.title)
            }
            Text(viewModel.state.regionInformation.title +
                    viewModel.state.regionInformation.value)
                .truncationMode(.tail)
                .allowsTightening(true)
            Text(viewModel.state.disclaimerInfo.value)
                .font(.caption2)
                .allowsTightening(true)
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
        Form {
            SectionRegionMonitoring(viewModel: mockViewModel)
        }
    }
}

extension SectionRegionMonitoring {
    enum ViewAction: Equatable {
        case pickRegionType(Int)
        case toggleRegionMonitoring(Bool, Int)
        case getRegionStateButtonTapped
    }
    
    struct ViewState: Equatable {
        let sectionRegionMonitoringTitle: String
        let pickerRegionType: ContentItem<PickerOption<Int>>
        let toggleRegionMonitoringServices: ContentItem<Bool>
        let regionInformation: ContentItem<String>
        let disclaimerInfo: ContentItem<String>
        let buttonRegionStateRequest: ContentItem<String>

        static var empty: ViewState {
            .init(
                sectionRegionMonitoringTitle: "",
                pickerRegionType: SectionRegionMonitoring.ContentItem(title: "", value: SectionRegionMonitoring.pickerConfig.first!),
                toggleRegionMonitoringServices: SectionRegionMonitoring.ContentItem(title: "", value: false),
                regionInformation: SectionRegionMonitoring.ContentItem(title: "", value: ""),
                disclaimerInfo: SectionRegionMonitoring.ContentItem(title: "", value: ""),
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
