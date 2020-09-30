//
//  SectionSLCMonitoring.swift
//  CoreLocation-Redux
//
//  Created by Nicolas Philippe on 9/30/20.
//

import SwiftUI
import SwiftRex
import CombineRex

struct SectionSLCMonitoring: View {

    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>

    var body: some View {
        Section(header: Text(viewModel.state.sectionSLCMonitoringTitle)) {
            Toggle(
                viewModel: viewModel,
                state: \.toggleSCLServices.value,
                onToggle: { ViewAction.toggleSLCMonitoring($0) }) {
                Text(viewModel.state.toggleSCLServices.title)
            }
        }
    }
}

struct SectionSLCMonitoring_Previews: PreviewProvider {

    static let mockState = AppState.mock
    static let mockStore = ObservableViewModel<AppAction, AppState>.mock(
        state: mockState,
        action: { action, _, state in
            state = Reducer.app.reduce(action, state)
        }
    )
    static let mockViewModel = ObservableViewModel.slcSection(store: mockStore)

    static var previews: some View {
        SectionSLCMonitoring(viewModel: mockViewModel)
    }
}

extension SectionSLCMonitoring {
    enum ViewAction: Equatable {
        case toggleSLCMonitoring(Bool)
    }
    
    struct ViewState: Equatable {
        let sectionSLCMonitoringTitle: String
        let toggleSCLServices: ContentItem<Bool>
        
        static var empty: ViewState {
            .init(
                sectionSLCMonitoringTitle: "",
                toggleSCLServices: ContentItem(title: "", value: false)
            )
        }
    }
    
    struct ContentItem<T>: Equatable where T:Equatable {
        let title: String
        let value: T
        var action: ViewAction? = nil
    }
}
