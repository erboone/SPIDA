#!/bin/bash

PANEL=$1
EXPERIMENT=$2
REGION=$3

CONFIG=" --config .env"

DATA_BASE="/mnt/merfish14/MERSCOPE"
OUTPUT="${DATA_BASE}/output/${EXPERIMENT}/${REGION}"
DATA="${DATA_BASE}/data/${EXPERIMENT}"
ANALYSIS="${DATA_BASE}/analysis/${EXPERIMENT}/${REGION}"

TEST_BASE="/home/erboone/SPIDA/seg_tests"
TEST_OUTPUT="${TEST_BASE}/output/${EXPERIMENT}/${REGION}"
TEST_DATA="${TEST_BASE}/data/${EXPERIMENT}/"
TEST_ANALYSIS="${TEST_BASE}/analysis/${EXPERIMENT}/${REGION}"

PREFIX="TEST_PREFIX"

SEGMENTED=""

# date
# echo "`date` -- Ingest"
# pixi run -e preprocessing spida-S  \
#     --config .env ingest-region  \
#     ${EXPERIMENT}  \
#     ${REGION} \

### CELLPOSE ### CELLPOSE ### CELLPOSE ### CELLPOSE ### CELLPOSE ### CELLPOSE ###

# echo "`date` -- Running Segmentation (cellpose)"
# echo -e "\n\tRunning Cellpose SAM on Region ${REGION} of Experiment ${EXPERIMENT}\n"
# # Running Cellpose
# pixi run --frozen -e cellpose \
#     python -m spida.S.cli ${CONFIG} \
#     run-segmentation-region \
#     cellpose \
#     ${EXPERIMENT} \
#     ${REGION} \
#     --input_dir ${OUTPUT}/images \
#     --output_dir ${TEST_BASE}/cellpose_cell \
#     --scale=6 \
#     --image_ext=.tif \
#     --nuc_stain_name=DAPI \
#     --cyto_stain_name=PolyT \
#     --flow_threshold=0 \
#     --cellprob_threshold=-2 \
#     --tile_norm_blocksize=2960 \

# pixi run -e preprocessing spida-P ${CONFIG} transcript-qc ${EXPERIMENT} ${REGION} --hex_size 30 --min_transcripts 100
# pixi run -e preprocessing spida-P ${CONFIG} cluster-hexes ${EXPERIMENT} ${REGION} --hex_size 30 --min_transcripts 100 --leiden_resolution 0.7


# echo "`date` -- Loading Decon images (cellpose)"
# # Loading in deconvoluted images
# pixi run --frozen -e preprocessing \
#     python -m spida.S.cli ${CONFIG} \
#     load-decon-images \
#     ${EXPERIMENT} \
#     ${REGION} \
#     ${DATA_BASE} \
#     --plot

echo "`date` -- Loading Segmentation (cellpose)"
# Loading in the segmentation into the zarr store
pixi run --frozen -e preprocessing \
    python -m spida.S.cli ${CONFIG} \
    load-segmentation-region  \
    ${EXPERIMENT} \
    ${REGION} \
    ${TEST_BASE}/cellpose_cell \
    --type vpt \
    --prefix_name cellpose_cell \
    --transcript-qc \


