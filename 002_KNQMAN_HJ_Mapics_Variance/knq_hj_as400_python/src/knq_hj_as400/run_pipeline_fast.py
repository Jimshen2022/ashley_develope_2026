from __future__ import annotations

from knq_hj_as400 import pipeline as p
from knq_hj_as400.run_pipeline import main as run_main


p.REQUIRED_SHEETS = [sheet for sheet in p.REQUIRED_SHEETS if sheet != "DATA"]


if __name__ == "__main__":
    run_main()
