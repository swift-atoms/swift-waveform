import Foundation
import Testing
public import Waveform

extension Double: @retroactive Trigonometry.Circular {
    public static func sin(_ x: Double) -> Double { Foundation.sin(x) }
    public static func cos(_ x: Double) -> Double { Foundation.cos(x) }
    public static func tan(_ x: Double) -> Double { Foundation.tan(x) }
    public static func asin(_ x: Double) -> Double { Foundation.asin(x) }
    public static func acos(_ x: Double) -> Double { Foundation.acos(x) }
    public static func atan(_ x: Double) -> Double { Foundation.atan(x) }
    public static func atan2(_ y: Double, _ x: Double) -> Double { Foundation.atan2(y, x) }
}

enum `Waveform Tests` {}

extension `Waveform Tests` {
    /// Phases in sixty-fourths of a cycle over three cycles either side of zero: every one is exact in binary.
    fileprivate static let phases: [Double] = (-192...192).map { Double($0) / 64 }
}

extension `Waveform Tests` {
    @Suite
    struct Shape {
        @Test
        func `Every shape starts its cycle at zero going up, except the square, which starts at one`() {
            #expect(Waveform.sine.value(at: 0.0) == 0)
            #expect(Waveform.triangle.value(at: 0.0) == 0)
            #expect(Waveform.sawtooth.value(at: 0.0) == 0)
            #expect(Waveform.square.value(at: 0.0) == 1)
            for shape in [Waveform.sine, .triangle, .sawtooth] {
                #expect(shape.value(at: 1.0 / 64) > 0)
            }
        }

        @Test
        func `Every shape stays within minus one and one`() {
            for shape in Waveform.allCases {
                for phase in `Waveform Tests`.phases {
                    let value: Double = shape.value(at: phase)
                    #expect(value >= -1 && value <= 1)
                }
            }
        }

        @Test
        func `The sine is the sine of a full turn per cycle`() {
            for phase in `Waveform Tests`.phases {
                let value: Double = Waveform.sine.value(at: phase)
                #expect(abs(value - Foundation.sin(2 * Double.pi * phase)) < 1e-12)
            }
            #expect(Waveform.sine.value(at: 0.25) == 1.0)
            #expect(Waveform.sine.value(at: 0.5) == 0.0)
            #expect(Waveform.sine.value(at: 0.75) == -1.0)
        }

        @Test
        func `The triangle peaks at a quarter, crosses zero at a half and bottoms at three quarters`() {
            #expect(Waveform.triangle.value(at: 0.125) == 0.5)
            #expect(Waveform.triangle.value(at: 0.25) == 1.0)
            #expect(Waveform.triangle.value(at: 0.5) == 0.0)
            #expect(Waveform.triangle.value(at: 0.75) == -1.0)
            #expect(Waveform.triangle.value(at: 0.875) == -0.5)
        }

        @Test
        func `The sawtooth rises throughout and drops from one to minus one at the half cycle`() {
            #expect(Waveform.sawtooth.value(at: 0.25) == 0.5)
            #expect(Waveform.sawtooth.value(at: 0.5) == -1.0)
            #expect(Waveform.sawtooth.value(at: 0.75) == -0.5)
            #expect(Waveform.sawtooth.value(at: 0.5.nextDown) > 0.999)
        }

        @Test
        func `The square is one over the first half of the cycle and minus one over the second`() {
            for phase in `Waveform Tests`.phases {
                let part = phase - phase.rounded(.down)
                #expect(Waveform.square.value(at: phase) == (part < 0.5 ? 1.0 : -1.0))
            }
        }
    }

    @Suite
    struct Period {
        @Test
        func `A whole number of cycles later the value is the same`() {
            for shape in Waveform.allCases {
                for phase in `Waveform Tests`.phases {
                    let here: Double = shape.value(at: phase)
                    #expect(shape.value(at: phase + 1) == here)
                    #expect(shape.value(at: phase - 5) == here)
                }
            }
        }

        @Test
        func `Half a cycle later the sine, the triangle and the square have the opposite value`() {
            for shape in [Waveform.sine, .triangle, .square] {
                for phase in `Waveform Tests`.phases {
                    let here: Double = shape.value(at: phase)
                    #expect(shape.value(at: phase + 0.5) == -here)
                }
            }
        }

        @Test
        func `The part of a phase within its cycle runs from zero up to but not at one`() {
            #expect(Waveform.cycle(of: 2.25) == 0.25)
            #expect(Waveform.cycle(of: -0.25) == 0.75)
            #expect(Waveform.cycle(of: 3.0) == 0.0)
            #expect(Waveform.cycle(of: -Double.leastNonzeroMagnitude) == 0.0)
        }

        @Test
        func `A phase that is not finite gives a value that is not a number`() {
            for shape in Waveform.allCases {
                #expect(shape.value(at: Double.infinity).isNaN)
                #expect(shape.value(at: Double.nan).isNaN)
            }
        }
    }
}
