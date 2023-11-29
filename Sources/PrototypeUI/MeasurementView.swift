import SwiftUI

public struct MeasurementView<UnitType: Unit>: View {
    private let model: Measurement<UnitType>
    private let formatter: MeasurementFormatter = .init()
    
    public init(model: Measurement<UnitType>) {
        self.model = model
    }
    
    public var body: some View {
        Text(formatter.string(from: model))
    }
}
