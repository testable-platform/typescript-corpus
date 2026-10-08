#!/usr/bin/env python3
"""red-dragon data-flow driver.

usage: dataflow.py <red-dragon checkout> <output json> <file.ts> [<file.ts> ...]

TypeScript source -> tree-sitter frontend -> IR -> CFG -> reaching definitions -> def-use chains and the variable
dependency graph (interpreter.dataflow.analyze), per file. Writes one JSON document with the counts.
"""
import json
import sys

home, out, files = sys.argv[1], sys.argv[2], sys.argv[3:]
sys.path.insert(0, home)

from interpreter.cfg import build_cfg                      # noqa: E402
from interpreter.dataflow import analyze                   # noqa: E402
from interpreter.frontend import get_frontend              # noqa: E402
from interpreter.var_name import VarName                   # noqa: E402
try:
    from interpreter.language import Language              # noqa: E402
except ImportError:                                        # older layout
    from interpreter.constants import Language             # noqa: E402

def const_of(instructions):
    """register name -> the text after `const` for every `%n = const ...` instruction."""
    table = {}
    for ins in instructions:
        text = str(ins).split("#")[0].strip()
        if " = const " in text:
            reg, value = text.split(" = const ", 1)
            table[reg.strip()] = value.strip()
    return table


def decl_value(definition):
    """the register a `decl_var NAME %n` definition stores, or None for any other instruction."""
    parts = str(definition.instruction).split("#")[0].split()
    return parts[2] if len(parts) >= 3 and parts[0] == "decl_var" else None


rows = []
for path in files:
    try:
        with open(path, "rb") as fh:
            source = fh.read()
        frontend = get_frontend(Language.TYPESCRIPT)
        instructions = frontend.lower(source)
        cfg = build_cfg(instructions)
        result = analyze(cfg)
    except Exception as exc:  # the pinned red-dragon commit rejects some TypeScript constructs (e.g. `i += 1` in a for update)
        rows.append({"file": path, "error": "%s: %s" % (type(exc).__name__, exc)})
        print("[red-dragon] %s: not analysed -- %s: %s" % (path, type(exc).__name__, exc))
        continue
    consts = const_of(instructions)
    read = {link.definition for link in result.def_use_chains}
    # A named variable assigned but never read (a function's own name is not a variable store, so it is skipped).
    dead = sorted({
        str(d.variable) for d in result.definitions
        if isinstance(d.variable, VarName) and d not in read and not consts.get(decl_value(d) or "", "").startswith("func_")
    })
    # A read that an initialiser-less `let x;` can reach, i.e. some path never assigns x before the read.
    maybe_uninitialised = sorted({
        str(link.use.variable) for link in result.def_use_chains
        if isinstance(link.definition.variable, VarName) and consts.get(decl_value(link.definition) or "") == "None"
        and "load_var" in str(link.use.instruction)
    })
    row = {
        "file": path,
        "irInstructions": len(instructions),
        "basicBlocks": len(cfg.blocks),
        "definitions": len(result.definitions),
        "defUseChains": len(result.def_use_chains),
        "variablesInDependencyGraph": len(result.dependency_graph),
        "deadStores": dead,
        "maybeUninitialisedReads": maybe_uninitialised,
    }
    rows.append(row)
    print("[red-dragon] %s: %d IR, %d blocks, %d defs, %d def-use chains | dead stores: %s | maybe-uninitialised reads: %s" % (
        path, row["irInstructions"], row["basicBlocks"], row["definitions"], row["defUseChains"],
        ", ".join(dead) or "none", ", ".join(maybe_uninitialised) or "none"))

with open(out, "w", encoding="utf-8") as fh:
    json.dump({"files": rows}, fh, indent=2)
