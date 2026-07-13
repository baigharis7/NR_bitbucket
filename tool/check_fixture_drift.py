#!/usr/bin/env python3
"""Drift check: frozen test fixture vs live production reference data.

Compares the foods frozen in test/fixtures/nutrients_real_subset.json against
the live s3://nutrients-pro/nutrients.json. The fixture is the oracle for the
protein regression tests (test/bloc/protein_oracle_real_data_test.dart); if
the live data changes, updating the fixture must be an explicit, reviewed
decision — re-validate expected values with the domain expert first.

NOT part of `flutter test` (needs network + AWS credentials). Run manually
pre-release or after any reference-data update:

    python3 tool/check_fixture_drift.py

Requires AWS CLI with the read-only profile `nutrenaissance`.
Exit code: 0 = no drift, 1 = drift found, 2 = execution error.
"""

import json
import subprocess
import sys
import tempfile
from pathlib import Path

FIXTURE = Path(__file__).resolve().parent.parent / "test" / "fixtures" / "nutrients_real_subset.json"
S3_URI = "s3://nutrients-pro/nutrients.json"
AWS_PROFILE = "nutrenaissance"


def main() -> int:
    fixture = json.loads(FIXTURE.read_text())
    frozen = {f["id"]: f for f in fixture["foods"]}
    print(f"Fixture: {len(frozen)} foods, source snapshot "
          f"{fixture['_provenance']['source_last_modified']}")

    with tempfile.NamedTemporaryFile(suffix=".json") as tmp:
        result = subprocess.run(
            ["aws", "s3", "cp", S3_URI, tmp.name, "--profile", AWS_PROFILE],
            capture_output=True, text=True,
        )
        if result.returncode != 0:
            print(f"ERROR downloading {S3_URI}:\n{result.stderr}", file=sys.stderr)
            return 2
        live = {f["id"]: f for f in json.load(open(tmp.name))["nutrientList"]
                if f["id"] in frozen}

    drift = False
    for food_id, frozen_food in frozen.items():
        live_food = live.get(food_id)
        name = frozen_food.get("name_es", food_id).strip()
        if live_food is None:
            print(f"❌ {name} (id {food_id}): DESAPARECIDO del dato vivo")
            drift = True
            continue
        for key in set(frozen_food) | set(live_food):
            if frozen_food.get(key) != live_food.get(key):
                if key == "params":
                    p_frozen, p_live = frozen_food["params"], live_food["params"]
                    for pk in sorted(set(p_frozen) | set(p_live)):
                        if p_frozen.get(pk) != p_live.get(pk):
                            print(f"❌ {name} (id {food_id}): params.{pk} "
                                  f"congelado={p_frozen.get(pk)!r} vivo={p_live.get(pk)!r}")
                            drift = True
                else:
                    print(f"❌ {name} (id {food_id}): {key} "
                          f"congelado={frozen_food.get(key)!r} vivo={live_food.get(key)!r}")
                    drift = True

    if drift:
        print("\nDRIFT DETECTADO: el dato vivo ya no coincide con el fixture congelado.")
        print("NO regenerar en caliente: re-validar los valores esperados con la "
              "experta y actualizar fixture + tests en un PR revisado (spec B1).")
        return 1

    print("✅ Sin drift: el dato vivo coincide 1:1 con el fixture congelado.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
