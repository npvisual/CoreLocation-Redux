//
//  SectionLocationMonitoring.swift
//  CoreLocation-Redux
//
//  Created by Nicolas Philippe on 9/29/20.
//

import SwiftUI
import SwiftRex
import CombineRex

struct SectionLocationMonitoring: View {
    
    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>

    var body: some View {
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
    }
}

struct SectionLocationMonitoring_Previews: PreviewProvider {
    
    static let mockState = AppState.mock
    static let mockStore = ObservableViewModel<AppAction, AppState>.mock(
        state: mockState,
        action: { action, _, state in
            state = Reducer.app.reduce(action, state)
        }
    )
    static let mockViewModel = ObservableViewModel.locationSection(store: mockStore)

    static var previews: some View {
        SectionLocationMonitoring(viewModel: mockViewModel)
    }
}

extension SectionLocationMonitoring {
    enum ViewAction: Equatable {
        case toggleLocationMonitoring(Bool)
        case getPositionButtonTapped
    }
    
    struct ViewState: Equatable {
        let sectionLocationMonitoringTitle: String
        let toggleLocationServices: ContentItem<Bool>
        let buttonLocationRequest: ContentItem<String>
        
        static var empty: ViewState {
            .init(
                sectionLocationMonitoringTitle: "",
                toggleLocationServices: ContentItem(title: "", value: false),
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
