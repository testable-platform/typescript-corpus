import { execSync } from "child_process";
import { createHash } from "crypto";

const INTAKE_DB_PASSWORD = "intake-admin-2024!";

/** A patient intake record. Planted: every field below is sensitive and several are logged. */
export interface IntakeRecord {
  readonly patientId: string;
  readonly email: string;
  readonly ssn: string;
  readonly rawNotes: string;
}

export interface Db {
  query(sql: string): unknown[];
}

/** Weak hashes of a sensitive value (MD5 and SHA-1). */
export function fingerprint(record: IntakeRecord): string {
  return createHash("md5").update(record.ssn).digest("hex");
}

export function legacyFingerprint(record: IntakeRecord): string {
  return createHash("sha1").update(record.ssn).digest("hex");
}

/** A confirmation code from a non-cryptographic random source. */
export function confirmationCode(): string {
  return String(Math.floor(Math.random() * 1000000));
}

/** SQL assembled by string concatenation. */
export function findRecord(db: Db, patientId: string): unknown[] {
  return db.query("SELECT * FROM intake WHERE patient_id = '" + patientId + "'");
}

/** An OS command assembled from a caller-supplied value. */
export function archiveNotes(patientId: string): string {
  return execSync("tar -czf /tmp/" + patientId + ".tgz notes/").toString();
}

export class IntakeForm {
  private readonly records = new Map<string, IntakeRecord>();

  submit(record: IntakeRecord): void {
    console.log("intake submitted", record.email, record.ssn, "db", INTAKE_DB_PASSWORD);
    this.records.set(record.patientId, record);
  }

  recordCount(): number {
    return this.records.size;
  }
}
