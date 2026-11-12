/// The shape of one cycle of a periodic wave, as a function of phase.
///
/// Phase is counted in cycles: phase 0 and phase 1 are the same point of the wave.
/// Every shape stays within -1 and 1 and starts its cycle at zero, going up.
public enum Waveform: Hashable, Sendable, CaseIterable {
    /// sin(2π × phase).
    case sine
    /// Up from 0 to 1 over the first quarter, down to -1 over the middle half, back up to 0.
    case triangle
    /// Up from 0 to 1 over the first half, then from -1 back up to 0.
    case sawtooth
    /// 1 over the first half of the cycle, -1 over the second.
    case square
}

extension Waveform {
    /// The part of `phase` within its cycle, from 0 up to but not at 1.
    @inlinable
    public static func cycle<Scalar: BinaryFloatingPoint>(of phase: Scalar) -> Scalar {
        let part = phase - phase.rounded(.down)
        return part < 1 ? part : 0
    }

    /// The wave's value at `phase`, in cycles. A phase that is not finite gives a value that is not a number.
    @inlinable
    public func value<Scalar: BinaryFloatingPoint & Trigonometry.Circular>(at phase: Scalar) -> Scalar {
        guard phase.isFinite else { return .nan }
        let part = Self.cycle(of: phase)
        switch self {
        case .sine:
            let quarter: Scalar = 0.25
            let half: Scalar = 0.5
            let folded = part < half ? part : part - half
            let reach = folded <= quarter ? folded : half - folded
            let height = Scalar.sin(2 * Scalar.pi * reach)
            return part < half ? height : -height

        case .triangle:
            if part < 0.25 { return 4 * part }
            if part < 0.75 { return 2 - 4 * part }
            return 4 * part - 4

        case .sawtooth:
            return part < 0.5 ? 2 * part : 2 * part - 2

        case .square:
            return part < 0.5 ? 1 : -1
        }
    }
}
