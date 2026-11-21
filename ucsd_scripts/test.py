# 
import os
from glob import glob
from pathlib import Path
from natsort import natsorted

if __name__ == "__main__":
    image_path = Path("/mnt/merfish14/MERSCOPE/output/202603271206_20260327M269BICANRen72_VMSC32010/region_UCI5224Q06MTC/images")
    image_ext = '.tif'
    nuc_stain_name = "DAPI"

    files = natsorted(
        [
            f
            for f in image_path.glob("*" + image_ext)
            if "_masks" not in f.name and "_flows" not in f.name
        ]
    )    
    
    nuc_files = []
    for f in files:
        if nuc_stain_name in f.name:
            nuc_files.append(f)

    if len(nuc_files) == 0:
        raise ValueError(
            f"No nuclear stain file found with name '{nuc_stain_name}' in {image_path}"
        )

