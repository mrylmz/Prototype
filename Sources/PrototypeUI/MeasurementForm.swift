import SwiftUI

public struct MeasurementForm<UnitType: Unit>: View {
    @Binding private var model: Measurement<UnitType>
    private let formatter: MeasurementFormatter = .init()
    
    public init(model: Binding<Measurement<UnitType>>) {
        _model = model
    }
    
    public var body: some View {
        TextField("", value: $model, formatter: formatter)
    }
}
