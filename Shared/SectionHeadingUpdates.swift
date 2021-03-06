//
//  SectionHeadingUpdates.swift
//  CoreLocation-Redux
//
//  Created by Nicolas Philippe on 9/30/20.
//

import SwiftUI
import SwiftRex
import CombineRex

struct SectionHeadingUpdates: View {

    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>

    var body: some View {
        Section(header: Text(viewModel.state.sectionHeadingUpdatesTitle)) {
            Toggle(
                viewModel: viewModel,
                state: \.toggleHeadingServices.value,
                onToggle: { ViewAction.toggleHeadingServices($0) }) {
                Text(viewModel.state.toggleHeadingServices.title)
            }
            Text(viewModel.state.headingInformation.title +
                    viewModel.state.headingInformation.value)
                .truncationMode(.tail)
                .allowsTightening(true)
        }
    }
}

struct SectionHeadingUpdates_Previews: PreviewProvider {

    static let mockState = AppState.mock
    static let mockStore = ObservableViewModel<AppAction, AppState>.mock(
        state: mockState,
        action: { action, _, state in
            state = Reducer.app.reduce(action, state)
        }
    )
    static let mockViewModel = ObservableViewModel.headingSection(store: mockStore)

    static var previews: some View {
        Form {
            SectionHeadingUpdates(viewModel: mockViewModel)
        }
    }
}

extension SectionHeadingUpdates {
    enum ViewAction: Equatable {
        case toggleHeadingServices(Bool)
    }
    
    struct ViewState: Equatable {
        let sectionHeadingUpdatesTitle: String
        let toggleHeadingServices: ContentItem<Bool>
        let headingInformation: ContentItem<String>
        
        static var empty: ViewState {
            .init(
                sectionHeadingUpdatesTitle: "",
                toggleHeadingServices: SectionHeadingUpdates.ContentItem(title: "", value: false),
                headingInformation: SectionHeadingUpdates.ContentItem(title: "", value: "")
            )
        }
    }
    
    struct ContentItem<T>: Equatable where T:Equatable {
        let title: String
        let value: T
        var action: ViewAction? = nil
    }
}
