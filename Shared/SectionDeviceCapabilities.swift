//
//  SectionDeviceCapabilities.swift
//  CoreLocation-Redux
//
//  Created by Nicolas Philippe on 9/29/20.
//

import SwiftUI
import SwiftRex
import CombineRex

struct SectionDeviceCapabilities: View {
    
    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>

    var body: some View {
        Section(header:
            Text(viewModel.state.sectionDeviceCapabilitiesTitle)) {
            Text(viewModel.state.textIsSLCCapable.title + viewModel.state.textIsSLCCapable.value.description)
            Text(viewModel.state.textIsRegionMonitoringCapable.title + viewModel.state.textIsRegionMonitoringCapable.value.description)
            Text(viewModel.state.textIsRangingCapable.title + viewModel.state.textIsRangingCapable.value.description)
            Text(viewModel.state.textIsHeadingCapable.title + viewModel.state.textIsHeadingCapable.value.description)
        }
    }
}

struct SectionDeviceCapabilities_Previews: PreviewProvider {
    
    static let mockState = AppState.mock
    static let mockStore = ObservableViewModel<AppAction, AppState>.mock(
        state: mockState,
        action: { action, _, state in
            state = Reducer.app.reduce(action, state)
        }
    )
    static let mockViewModel = ObservableViewModel.capabilitiesSection(store: mockStore)

    static var previews: some View {
        Form {
            SectionDeviceCapabilities(viewModel: mockViewModel)
        }
    }
}


extension SectionDeviceCapabilities {
    enum ViewAction: Equatable { }
    
    struct ViewState: Equatable {
        let sectionDeviceCapabilitiesTitle: String
        let textIsSLCCapable: ContentItem<Bool>
        let textIsRegionMonitoringCapable: ContentItem<Bool>
        let textIsRangingCapable: ContentItem<Bool>
        let textIsHeadingCapable: ContentItem<Bool>
        
        static var empty: ViewState {
            .init(
                sectionDeviceCapabilitiesTitle: "",
                textIsSLCCapable: SectionDeviceCapabilities.ContentItem(title: "", value: false),
                textIsRegionMonitoringCapable: SectionDeviceCapabilities.ContentItem(title: "", value: false),
                textIsRangingCapable: SectionDeviceCapabilities.ContentItem(title: "", value: false),
                textIsHeadingCapable: SectionDeviceCapabilities.ContentItem(title: "", value: false)
            )
        }
    }
    
    struct ContentItem<T>: Equatable where T:Equatable {
        let title: String
        let value: T
        var action: ViewAction? = nil
    }
}
