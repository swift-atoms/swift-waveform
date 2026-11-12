# swift-waveform

Use this package when you need the height of a periodic wave at a point of its cycle: a tone for a sound, a wobble for a motion, a test signal. Start from `Waveform`, one of `.sine`, `.triangle`, `.sawtooth` and `.square`, and ask for `value(at:)` with a phase counted in cycles. The answer is a formula in the phase, so samples can be computed alone, out of order and in parallel, and always agree. A frequency and a running phase are the caller's: at `frequency` cycles per unit of time the phase at `time` is `frequency × time`. The scalar supplies `sin` through `Trigonometry.Circular`; this package conforms no type.

## Laws

- Phase is counted in cycles. `Waveform.cycle(of:)` is the part of a phase within its cycle, from 0 up to but not at 1; for a negative phase it counts from the cycle's start, so the part of -0.25 is 0.75.
- Every value lies within -1 and 1.
- A whole number of cycles later the value is the same, exactly, as far as the sum of the phase and the whole number is exact.
- `.sine` is sin(2π × phase). It is computed from the first quarter of the cycle, so it is exactly 0 at each half cycle, exactly 1 at a quarter and exactly -1 at three quarters.
- `.triangle` goes straight from 0 up to 1 at a quarter, down through 0 at a half to -1 at three quarters, and back up to 0.
- `.sawtooth` goes straight from 0 up towards 1 over the first half, drops to -1 at the half cycle, and rises back to 0.
- `.square` is 1 over the first half of the cycle, the start included, and -1 over the second half.
- Every shape starts its cycle at 0 going up, except the square, which has no 0 and starts at 1.
- Half a cycle later the sine, the triangle and the square have the opposite value.
- A phase that is not finite gives a value that is not a number.
- The shapes are the ideal ones. The triangle, the sawtooth and the square have corners or jumps, so sampled at a steady rate they contain frequencies above half that rate, which fold back as aliases. This package does not limit their band.
- The triangle, the sawtooth and the square use only arithmetic that is exact or correctly rounded, so they are the same on every platform. The sine is as repeatable as the scalar's `sin`.
