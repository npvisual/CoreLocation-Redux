//
//  SectionBeaconRanging.swift
//  CoreLocation-Redux
//
//  Created by Nicolas Philippe on 10/1/20.
//

import SwiftUI
import SwiftRex
import CombineRex

struct SectionBeaconRanging: View {

    @ObservedObject var viewModel: ObservableViewModel<ViewAction, ViewState>

    var body: some View {
        Section(header: Text(viewModel.state.sectionBeaconRangingTitle)) {
            Toggle(
                viewModel: viewModel,
                state: \.toggleBeaconRangingServices.value,
                onToggle: { ViewAction.toggleBeaconRanging($0) }) {
                Text(viewModel.state.toggleBeaconRangingServices.title)
            }
            Text(viewModel.state.beaconInformation.title +
                    viewModel.state.beaconInformation.value)
                .truncationMode(.tail)
                .allowsTightening(true)
            Text("Using beacon with uuid: 212D2900-...-8BDF3CBAF105")
                .font(.footnote)
            Button(
                viewModel.state.buttonBeaconStateRequest.title.localizedCapitalized,
                action: {
                    viewModel.state.buttonBeaconStateRequest.action.map { action in viewModel.dispatch(action) }
                }
            )
        }
    }
}

struct SectionBeaconRanging_Previews: PreviewProvider {

    static let mockState = AppState.mock
    static let mockStore = ObservableViewModel<AppAction, AppState>.mock(
        state: mockState,
        action: { action, _, state in
            state = Reducer.app.reduce(action, state)
        }
    )
    static let mockViewModel = ObservableViewModel.beaconSection(store: mockStore)

    static var previews: some View {
        SectionBeaconRanging(viewModel: mockViewModel)
    }
}

extension SectionBeaconRanging {
    enum ViewAction: Equatable {
        case toggleBeaconRanging(Bool)
        case getBeaconStateButtonTapped
    }
    
    struct ViewState: Equatable {
        let sectionBeaconRangingTitle: String
        let toggleBeaconRangingServices: ContentItem<Bool>
        let beaconInformation: ContentItem<String>
        let buttonBeaconStateRequest: ContentItem<String>

        static var empty: ViewState {
            .init(
                sectionBeaconRangingTitle: "",
                toggleBeaconRangingServices: SectionBeaconRanging.ContentItem(title: "", value: false),
                beaconInformation: SectionBeaconRanging.ContentItem(title: "", value: ""),
                buttonBeaconStateRequest: SectionBeaconRanging.ContentItem(title: "", value: "")
            )
        }
    }
    
    struct ContentItem<T>: Equatable where T:Equatable {
        let title: String
        let value: T
        var action: ViewAction? = nil
    }
}
