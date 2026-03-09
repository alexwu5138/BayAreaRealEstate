#!/usr/bin/env python3
import argparse
import logging
from pathlib import Path
import re

COUNTIES = [
    "Alameda",
    "Contra Costa",
    "Marin",
    "Napa",
    "San Francisco",
    "San Mateo",
    "Santa Clara",
    "Solano",
    "Sonoma",
]

ZIP_TO_COUNTY = {
    "94002": "San Mateo",
    "94010": "San Mateo",
    "94020": "San Mateo",
    "94022": "Santa Clara",
    "94024": "Santa Clara",
    "94025": "San Mateo",
    "94027": "San Mateo",
    "94028": "San Mateo",
    "94035": "Santa Clara",
    "94039": "Santa Clara",
    "94040": "Santa Clara",
    "94041": "Santa Clara",
    "94043": "Santa Clara",
    "94061": "San Mateo",
    "94062": "San Mateo",
    "94065": "San Mateo",
    "94070": "San Mateo",
    "94085": "Santa Clara",
    "94086": "Santa Clara",
    "94087": "Santa Clara",
    "94089": "Santa Clara",
    "94301": "Santa Clara",
    "94303": "San Mateo",
    "94304": "Santa Clara",
    "94305": "Santa Clara",
    "94306": "Santa Clara",
    "94401": "San Mateo",
    "94402": "San Mateo",
    "94403": "San Mateo",
    "94404": "San Mateo",
    "94536": "Alameda",
    "94538": "Alameda",
    "94539": "Alameda",
    "94541": "Alameda",
    "94542": "Alameda",
    "94544": "Alameda",
    "94545": "Alameda",
    "94555": "Alameda",
    "95002": "Santa Clara",
    "95008": "Santa Clara",
    "95014": "Santa Clara",
    "95032": "Santa Clara",
    "95035": "Santa Clara",
    "95037": "Santa Clara",
    "95050": "Santa Clara",
    "95051": "Santa Clara",
    "95054": "Santa Clara",
    "95070": "Santa Clara",
    "95110": "Santa Clara",
    "95111": "Santa Clara",
    "95112": "Santa Clara",
    "95116": "Santa Clara",
    "95117": "Santa Clara",
    "95118": "Santa Clara",
    "95119": "Santa Clara",
    "95120": "Santa Clara",
    "95121": "Santa Clara",
    "95122": "Santa Clara",
    "95123": "Santa Clara",
    "95124": "Santa Clara",
    "95125": "Santa Clara",
    "95126": "Santa Clara",
    "95127": "Santa Clara",
    "95128": "Santa Clara",
    "95129": "Santa Clara",
    "95130": "Santa Clara",
    "95131": "Santa Clara",
    "95132": "Santa Clara",
    "95133": "Santa Clara",
    "95134": "Santa Clara",
    "95135": "Santa Clara",
    "95136": "Santa Clara",
    "95138": "Santa Clara",
    "95139": "Santa Clara",
    "95140": "Santa Clara",
    "95148": "Santa Clara",
    "94517": "Contra Costa",
    "94563": "Contra Costa",
    "95030": "Santa Clara",
}

ZIP_PATTERN = re.compile(r"(\d{5})")


def ensure_county_folders(base_dir: Path) -> None:
    for county in COUNTIES:
        (base_dir / county).mkdir(parents=True, exist_ok=True)


def organize_reports(base_dir: Path, dry_run: bool) -> list[tuple[Path, Path]]:
    moves: list[tuple[Path, Path]] = []
    for path in base_dir.iterdir():
        if not path.is_file() or path.name.lower() == "readme.md":
            continue
        match = ZIP_PATTERN.search(path.name)
        if not match:
            logging.warning("Skipping %s: no ZIP code found.", path.name)
            continue
        zipcode = match.group(1)
        county = ZIP_TO_COUNTY.get(zipcode)
        if not county:
            logging.warning("Skipping %s: ZIP %s not mapped.", path.name, zipcode)
            continue
        destination = base_dir / county / path.name
        moves.append((path, destination))
        if dry_run:
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        path.rename(destination)
    return moves


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Organize area reports into Bay Area county folders."
    )
    parser.add_argument(
        "--base-dir",
        type=Path,
        default=Path("2_markets/3_1_area_reports"),
        help="Directory containing area reports",
    )
    parser.add_argument("--dry-run", action="store_true", help="Preview moves")
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
    base_dir = args.base_dir
    if not base_dir.is_absolute():
        base_dir = Path(__file__).resolve().parent / base_dir

    if not base_dir.exists():
        raise SystemExit(f"Base directory not found: {base_dir}")

    ensure_county_folders(base_dir)
    moves = organize_reports(base_dir, args.dry_run)
    logging.info("Prepared %d move(s).", len(moves))
    if args.dry_run:
        for source, destination in moves:
            logging.info("%s -> %s", source, destination)


if __name__ == "__main__":
    main()
