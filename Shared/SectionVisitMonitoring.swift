//
//  SectionVisitMonitoring.swift
//  CoreLocation-Redux
//
//  Created by Nicolas Philippe on 10/2/20.
//

import SwiftUI
import SwiftRex
import CombineRex

struct SectionVisitMonitoring: View {

    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>

    var body: some View {
        Section(header: Text(viewModel.state.sectionVisitEventUpdatesTitle)) {
            Toggle(
                viewModel: viewModel,
                state: \.toggleVisitEventsService.value,
                onToggle: { ViewAction.toggleVisitEventsService($0) }) {
                Text(viewModel.state.toggleVisitEventsService.title)
            }
            Text(viewModel.state.visitEventsInformation.title +
                    viewModel.state.visitEventsInformation.value)
                .truncationMode(.tail)
                .allowsTightening(true)
        }
    }
}

struct SectionVisitMonitoring_Previews: PreviewProvider {

    static let mockState = AppState.mock
    static let mockStore = ObservableViewModel<AppAction, AppState>.mock(
        state: mockState,
        action: { action, _, state in
            state = Reducer.app.reduce(action, state)
        }
    )
    static let mockViewModel = ObservableViewModel.visitEventsSection(store: mockStore)

    static var previews: some View {
        Form {
            SectionVisitMonitoring(viewModel: mockViewModel)
        }
    }
}

extension SectionVisitMonitoring {
    enum ViewAction: Equatable {
        case toggleVisitEventsService(Bool)
    }
    
    struct ViewState: Equatable {
        let sectionVisitEventUpdatesTitle: String
        let toggleVisitEventsService: ContentItem<Bool>
        let visitEventsInformation: ContentItem<String>
        
        static var empty: ViewState {
            .init(
                sectionVisitEventUpdatesTitle: "",
                toggleVisitEventsService: SectionVisitMonitoring.ContentItem(title: "", value: false),
                visitEventsInformation: SectionVisitMonitoring.ContentItem(title: "", value: "")
            )
        }
    }
    
    struct ContentItem<T>: Equatable where T:Equatable {
        let title: String
        let value: T
        var action: ViewAction? = nil
    }
}

