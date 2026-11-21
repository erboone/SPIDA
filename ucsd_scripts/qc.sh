#!/bin/bash

PANEL=$1
EXPERIMENT=$2
REGION=$3

CONFIG=".env"
# PANELS=["CTX" "BG" "HIPP" "TMH", "CERE"]


### OLD VERSION - from maize.ucsd.edu
# pixi run -e preprocessing spida-S --config ${BA_CONFIG} ingest-region ${EXP_NAME} ${REG_NAME} 
# pixi run -e preprocessing spida-P --config ${BA_CONFIG} transcript-qc ${EXP_NAME} ${REG_NAME} --hex_size 30 --min_transcripts 100
# pixi run -e preprocessing spida-P --config ${BA_CONFIG} cluster-hexes ${EXP_NAME} ${REG_NAME} --hex_size 30 --min_transcripts 100 --leiden_resolution 0.7
# pixi run -e preprocessing python -m spida.site --config ${BA_CONFIG} generate-load-qc-figs ${EXP_NAME} ${REG_NAME} --brain-region ${PANEL} --lab ucsd

# printf -v joined '%s,' "${data[@]}"
# mv /home/erboone/SPIDA/images/{${joined%,}}/* /mnt/pompomV2/qc_images/{${joined%,}}/


pixi run -e preprocessing \
    spida-S --config ${CONFIG} \
    ingest-region \
    ${EXPERIMENT} \
    ${REGION} 

pixi run -e preprocessing \
    spida-P --config ${CONFIG} \
    transcript-qc \
    ${EXPERIMENT} \
    ${REGION} \
    --hex_size 30 \
    --min_transcripts 100

pixi run -e preprocessing \
    spida-P --config ${CONFIG} \
    cluster-hexes \
    ${EXPERIMENT} \
    ${REGION} \
    --hex_size 30 \
    --min_transcripts 100 \
    --leiden_resolution 0.7

pixi run -e preprocessing \
    python -m spida.site --config ${CONFIG} \
    generate-load-qc-figs \
    ${EXPERIMENT} \
    ${REGION} \
    --brain-region ${PANEL} \
    --lab ucsd

# printf -v joined '%s,' "${data[@]}"
# mv /home/erboone/SPIDA/images/{${joined%,}}/* /mnt/pompomV2/qc_images/{${joined%,}}/