/** Net pressure change across a run of samples. Planted: `spare` is never read; `delta` is read on a path that never assigned it. */
export function pressureTrend(samples: number[]): number {
  const first = samples[0];
  const last = samples[samples.length - 1];
  const spare = samples.length;
  let delta!: number;
  if (first > 0) {
    delta = last - first;
  }
  return delta;
}

/** Mean of the samples. Planted: `scratch` is assigned twice and never read. */
export function averagePressure(samples: number[]): number {
  let total = 0;
  let index = 0;
  let scratch = 0;
  scratch = 1;
  while (index < samples.length) {
    total = total + samples[index];
    index = index + 1;
  }
  return samples.length === 0 ? 0 : total / samples.length;
}

/** Names a trend. Planted: `label` is read although the last `else` path never assigns it. */
export function classify(trend: number): string {
  let label!: string;
  if (trend > 10) {
    label = "rising";
  } else if (trend < -10) {
    label = "falling";
  }
  return label;
}
