//
//  SectionAuthorization.swift
//  CoreLocation-Redux
//
//  Created by Nicolas Philippe on 9/25/20.
//

import SwiftUI
import SwiftRex
import CombineRex

struct SectionAuthorization: View {
    
    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>
    
    var body: some View {
        Section(header: Text(viewModel.state.sectionAuthorizationTitle)) {
            Text(viewModel.state.textAuthorization.title + viewModel.state.textAuthorization.value)
            Toggle(
                viewModel: viewModel,
                state: \.toggleAuthType.value,
                onToggle: { ViewAction.toggleAuthType($0) }) {
                Text(viewModel.state.toggleAuthType.title)
            }
            Text(viewModel.state.textAccuracy.title + viewModel.state.textAccuracy.value)
            Button(
                viewModel.state.buttonAuthorizationRequest.title.localizedCapitalized,
                action: {
                    viewModel.state.buttonAuthorizationRequest.action.map { action in viewModel.dispatch(action) }
                }
            )
        }
    }
}


struct SectionAuthorization_Previews: PreviewProvider {
    
    static let mockState = AppState.mock
    static let mockStore = ObservableViewModel<AppAction, AppState>.mock(
        state: mockState,
        action: { action, _, state in
            state = Reducer.app.reduce(action, state)
        }
    )
    static let mockViewModel = ObservableViewModel.authzSection(store: mockStore)
    
    static var previews: some View {
        SectionAuthorization(viewModel: mockViewModel)
    }
}


extension SectionAuthorization {
    enum ViewAction: Equatable {
        case toggleAuthType(Bool)
        case getAuthorizationButtonTapped
    }
    
    struct ViewState: Equatable {
        let sectionAuthorizationTitle: String
        let toggleAuthType: ContentItem<Bool>
        let buttonAuthorizationRequest: ContentItem<String>
        let textAuthorization: ContentItem<String>
        let textAccuracy: ContentItem<String>
        
        static var empty: ViewState {
            .init(
                sectionAuthorizationTitle: "",
                toggleAuthType: ContentItem(title: "", value: false),
                buttonAuthorizationRequest: ContentItem(title: "", value: ""),
                textAuthorization: ContentItem(title: "", value: ""),
                textAccuracy: ContentItem(title: "", value: "")
            )
        }
    }
    
    struct ContentItem<T>: Equatable where T:Equatable {
        let title: String
        let value: T
        var action: ViewAction? = nil
    }
}
