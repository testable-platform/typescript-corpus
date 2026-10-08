/** One tide gauge reading, in millimetres above chart datum. */
export interface Reading {
  readonly stationId: string;
  readonly takenAt: string;
  readonly heightMm: number;
}

/** The reading with the greatest height, or undefined for an empty series. */
export function highest(readings: readonly Reading[]): Reading | undefined {
  return readings.reduce<Reading | undefined>(
    (best, current) => (best === undefined || current.heightMm > best.heightMm ? current : best),
    undefined,
  );
}

/** Mean height of the series; 0 when there are no readings. */
export function meanHeight(readings: readonly Reading[]): number {
  if (readings.length === 0) {
    return 0;
  }
  let total = 0;
  for (const reading of readings) {
    total = total + reading.heightMm;
  }
  return Math.round(total / readings.length);
}

/** Spread between the highest and lowest height, in millimetres. */
export function tidalRange(readings: readonly Reading[]): number {
  const heights = readings.map((reading) => reading.heightMm);
  return heights.length === 0 ? 0 : Math.max(...heights) - Math.min(...heights);
}

/** Renders the series as CSV with a header row. */
export function toCsv(readings: readonly Reading[]): string {
  const rows = readings.map((reading) => [reading.stationId, reading.takenAt, String(reading.heightMm)].join(","));
  return ["station,takenAt,heightMm", ...rows].join("\n");
}

/** Parses one CSV row back into a reading; throws on a malformed row. */
export function parseRow(row: string): Reading {
  const parts = row.split(",");
  if (parts.length !== 3) {
    throw new Error(`expected 3 fields, got ${parts.length}`);
  }
  const heightMm = Number(parts[2]);
  if (!Number.isFinite(heightMm)) {
    throw new Error(`height is not a number: ${parts[2]}`);
  }
  return { stationId: parts[0], takenAt: parts[1], heightMm };
}

/** Per-quadrant summaries -- three copies of one block, differing only in names. */
export function summariseNorth(readings: readonly Reading[]): string {
  const north = readings.filter((reading) => reading.stationId.startsWith("N"));
  let total = 0;
  let peak = 0;
  for (const reading of north) {
    total = total + reading.heightMm;
    if (reading.heightMm > peak) {
      peak = reading.heightMm;
    }
  }
  const mean = north.length === 0 ? 0 : Math.round(total / north.length);
  return `north: ${north.length} readings, mean ${mean} mm, peak ${peak} mm`;
}

export function summariseSouth(readings: readonly Reading[]): string {
  const south = readings.filter((reading) => reading.stationId.startsWith("S"));
  let total = 0;
  let peak = 0;
  for (const reading of south) {
    total = total + reading.heightMm;
    if (reading.heightMm > peak) {
      peak = reading.heightMm;
    }
  }
  const mean = south.length === 0 ? 0 : Math.round(total / south.length);
  return `south: ${south.length} readings, mean ${mean} mm, peak ${peak} mm`;
}

export function summariseEast(readings: readonly Reading[]): string {
  const east = readings.filter((reading) => reading.stationId.startsWith("E"));
  let total = 0;
  let peak = 0;
  for (const reading of east) {
    total = total + reading.heightMm;
    if (reading.heightMm > peak) {
      peak = reading.heightMm;
    }
  }
  const mean = east.length === 0 ? 0 : Math.round(total / east.length);
  return `east: ${east.length} readings, mean ${mean} mm, peak ${peak} mm`;
}
