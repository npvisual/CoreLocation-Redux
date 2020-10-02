//
//  SectionInformation.swift
//  CoreLocation-Redux
//
//  Created by Nicolas Philippe on 9/30/20.
//

import SwiftUI
import SwiftRex
import CombineRex

struct SectionInformation: View {

    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>

    var body: some View {
        Section {
            Text(viewModel.state.locationInformation.title + viewModel.state.locationInformation.value)
            Text(viewModel.state.errorInformation.title + viewModel.state.errorInformation.value)
                .truncationMode(.tail)
                .allowsTightening(true)
        }
    }
}

struct SectionInformation_Previews: PreviewProvider {
    
    static let mockState = AppState.mock
    static let mockStore = ObservableViewModel<AppAction, AppState>.mock(
        state: mockState,
        action: { action, _, state in
            state = Reducer.app.reduce(action, state)
        }
    )
    static let mockViewModel = ObservableViewModel.informationSection(store: mockStore)

    static var previews: some View {
        Form {
            SectionInformation(viewModel: mockViewModel)
        }
    }
}

extension SectionInformation {
    enum ViewAction: Equatable { }
    
    struct ViewState: Equatable {
        let locationInformation: ContentItem<String>
        let errorInformation: ContentItem<String>
        
        static var empty: ViewState {
            .init(
                locationInformation: SectionInformation.ContentItem(title: "", value: ""),
                errorInformation: SectionInformation.ContentItem(title: "", value: "")
            )
        }
    }
    
    struct ContentItem<T>: Equatable where T:Equatable {
        let title: String
        let value: T
        var action: ViewAction? = nil
    }
}
