"use strict";
// usage: node trace_driver.cjs <tool install dir> <source root> <run dir>
// Emits TraceGraph events (function_call / return / error, parent-linked) for a real call path through the
// order service: OrderService.price -> validateOrder -> effectiveRate -> applyTax. One order is invalid on purpose.
const path = require("path");
const [installDir, srcRoot, runDir] = process.argv.slice(2);
const nm = path.resolve(installDir, "node_modules");
const core = require(path.join(nm, "@tracegraph/trace-core"));
const js = require(path.join(nm, "@tracegraph/trace-js"));

process.env.TRACEGRAPH_ENABLED = "1";
process.env.TRACEGRAPH_RUN_DIR = path.resolve(runDir);
process.env.TRACEGRAPH_TRACE_ID = core.createTraceId();
process.env.TRACEGRAPH_RUN_ID = core.createRunId();
process.env.TRACEGRAPH_SESSION_ID = core.createSessionId();

require("ts-node/register");
const svc = require(path.resolve(srcRoot, "services/order-service"));
const rules = require(path.resolve(srcRoot, "services/pricing-rules"));
const models = require(path.resolve(srcRoot, "models/order-record"));
const tax = require(path.resolve(srcRoot, "models/tax-table"));

// wrap what the call path crosses (module exports and the class methods)
rules.effectiveRate = js.traceFunction("pricing-rules.effectiveRate", rules.effectiveRate);
tax.applyTax = js.traceFunction("tax-table.applyTax", tax.applyTax);
models.validateOrder = js.traceFunction("order-record.validateOrder", models.validateOrder);
svc.OrderService.prototype.price = js.traceFunction("OrderService.price", svc.OrderService.prototype.price);
svc.OrderService.prototype.priceAll = js.traceFunction("OrderService.priceAll", svc.OrderService.prototype.priceAll);

const order = (id, o) => Object.assign({ id, channel: "retail", tier: "standard",
  lines: [{ sku: "SKU-A", quantity: 2, unitPrice: 50 }], placedAt: "2026-01-01T00:00:00.000Z" }, o || {});
const result = new svc.OrderService().priceAll([
  order("ORD-1"),
  order("ORD-2", { tier: "gold", channel: "wholesale" }),
  order("ORD-3", { lines: [] }),              // invalid: the error path is traced too
]);
console.log("[tracegraph] priced:", result.priced.length, "| rejected:", result.failures.length);

const fs = require("fs");
const file = path.join(path.resolve(runDir), process.env.TRACEGRAPH_TRACE_ID + ".events.jsonl.tmp");
const events = fs.existsSync(file) ? fs.readFileSync(file, "utf8").trim().split("\n").filter(Boolean).map((l) => JSON.parse(l)) : [];
const by = {};
events.forEach((e) => { by[e.type] = (by[e.type] || 0) + 1; });
console.log("[tracegraph] events:", events.length, JSON.stringify(by));
if (events.length === 0) { console.error("[tracegraph] FAIL: no events were written"); process.exit(1); }
