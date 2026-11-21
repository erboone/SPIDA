from glob import glob
from pathlib import Path
from configparser import ConfigParser
import subprocess as sub
import os
import sys
import json

PANEL_TO_NAME = {
    "D2M2006": "CTX",
    "D2P2238": "BG",
    "D2P2484": "HIPPO",
    "D2P2618": "THM",
    "D2P2810": "MID",
    "D2P2750": "CERE"
}

if __name__ == "__main__":
    paths = glob("/mnt/merfish*/MERSCOPE/output/*Ren*/region_*")

    region_info = []
    for path in sorted([Path(p) for p in paths], reverse=True):
        panel = json.load(open(path.parent / "experiment.json", 'r'))["codebookName"].split('_')[-1].split('.')[0]
        if panel not in PANEL_TO_NAME.keys():
            continue
        panel_abv = PANEL_TO_NAME[panel]
        print(f"('{panel_abv}', '{path.parent.name}', '{path.name}')")
        region_info.append((panel_abv, path.parent.name, path.name, path.parent.parent.parent))

    script = sys.argv[1]
    print(f"Running: {script}")

    paths = [
        
    ]
    
    for panel, name, reg, root in region_info:
        if reg == 'region_0':
            continue
        
        f = open(r'.env', 'r')    # pass an appropriate path of the required file
        lines = f.readlines()
        lines[0] = f"PROCESSED_ROOT_PATH={root}\n"    # n is the line number you want to edit; subtract 1 as indexing of list starts from 0
        f.close()   # close the file and reopen in write mode to enable writing to file; you can also open in append mode and use "seek", but you will have some unwanted old data if the new data is shorter in length.

        f = open(r'.env', 'w')
        f.writelines(lines)
        print(lines)
        # do the remaining operations on the file
        f.close()
        print(f'MAKING ~/MERSCOPE/spatialdata/{name}/{reg}')
        os.makedirs(f'~/MERSCOPE/spatialdata/{name}/{reg}', exist_ok=True)

        print(name, reg)
        sub.run(
            f"{script} {panel} {name} {reg}"\
            .split(' ')
        )
        

