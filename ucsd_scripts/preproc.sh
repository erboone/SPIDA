
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

echo "CHKPT: `date` -- Ingest"
pixi run -e preprocessing spida-S  ingest-region \
    ${EXPERIMENT}  \
    ${REGION} \

pixi run -e preprocessing \
    spida-P ${CONFIG} \
    transcript-qc \
    ${EXPERIMENT} \
    ${REGION} \
    --hex_size 30 \
    --min_transcripts 100

pixi run -e preprocessing \
    spida-P ${CONFIG} \
    cluster-hexes \
    ${EXPERIMENT} \
    ${REGION} \
    --hex_size 30 \
    --min_transcripts 100 \
    --leiden_resolution 0.7

pixi run -e preprocessing \
    python -m spida.site ${CONFIG} \
    generate-load-qc-figs \
    ${EXPERIMENT} \
    ${REGION} \
    --brain-region ${PANEL} \
    --lab ucsd

export CONDA_OVERRIDE_CUDA=12.0
echo "CHKPT: `date` -- Running DAPI DECON"
pixi run --frozen -e preprocessing-gpu \
    python -m spida.S.cli ${CONFIG} \
    decon_image \
    -i ${OUTPUT}/images \
    --data_org_path ${DATA}/dataorganization.csv \
    -o ${TEST_ANALYSIS}/tile_images \
    --channels DAPI \
    --tile_size 2960 \
    --overlap 400 \
    --z_step 1.5 \
    --filter deconwolf \
    --filter_args tilesize 1500 \
    --gpu \
    --plot_thr


echo "CHKPT: `date` -- Running PolyT DECON"
pixi run --frozen -e preprocessing-gpu \
    python -m spida.S.cli ${CONFIG} \
    decon_image \
    -i ${OUTPUT}/images \
    --data_org_path ${DATA}/dataorganization.csv \
    -o ${TEST_ANALYSIS}/tile_images \
    --channels PolyT \
    --tile_size 2960 \
    --overlap 400 \
    --z_step 1.5 \
    --filter deconwolf \
    --filter_args tilesize 1500 \
    --gpu \
    --plot_thr


### CELLPOSE ### CELLPOSE ### CELLPOSE ### CELLPOSE ### CELLPOSE ### CELLPOSE ###

echo "CHKPT: `date` -- Running Segmentation (cellpose)"
echo -e "\n\tRunning Cellpose SAM on Region ${REGION} of Experiment ${EXPERIMENT}\n"
# Running Cellpose
pixi run --frozen -e cellpose \
    python -m spida.S.cli ${CONFIG} \
    run-segmentation-region \
    cellpose \
    ${EXPERIMENT} \
    ${REGION} \
    --input_dir ${OUTPUT}/images \
    --output_dir ${TEST_BASE}/cellpose_cell \
    --scale=6 \
    --image_ext=.tif \
    --nuc_stain_name=DAPI \
    --cyto_stain_name=PolyT \
    --flow_threshold=0 \
    --cellprob_threshold=-2 \
    --tile_norm_blocksize=2960 \

echo "CHKPT: `date` -- Loading Segmentation (cellpose)"
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



### PROSEG ### PROSEG ### PROSEG ### PROSEG ### PROSEG ### PROSEG ### PROSEG ###
echo "CHKPT: `date` -- Running Segmentation (proseg)"
pixi run --frozen -e preprocessing \
    python -m spida.S.cli ${CONFIG} \
    run-segmentation-region \
    proseg \
    ${EXPERIMENT} \
    ${REGION} \
    --input_dir ${TEST_BASE}/cellpose_cell/ \
    --output_dir ${TEST_BASE}/${PREFIX} \
    --voxel-layers=7 \
    --ncomponents=10 \
    --enforce-connectivity=True \
    --nuclear-reassignment-prob=0.05 \
    --cell-compactness=0.05 \
    --diffusion-probability=0.01 \
    --overwrite=True

echo "CHKPT: `date` -- Loading Segmentation (proseg)"
# LOAD PROSEG SEGMENTATION
pixi run --frozen -e preprocessing \
    python -m spida.S.cli ${CONFIG} \
    load-segmentation-region \
    ${EXPERIMENT} \
    ${REGION} \
    ${TEST_BASE}/${PREFIX} \
    --type proseg \
    --prefix_name ${PREFIX} \

echo "CHKPT: `date` -- Filter cells (proseg)"
# FILTERING 
pixi run --frozen -e preprocessing \
    python -m spida.P.cli ${CONFIG} \
    filter_cells_region \
    ${EXPERIMENT} \
    ${REGION} \
    ${PREFIX} \
    --seg_fam proseg \
    --cutoffs_path /home/erboone/SPIDA/cutoffs.json

echo "CHKPT: `date` -- Set up AnnData"
# SETUP ADATA 
pixi run --frozen -e preprocessing \
    python -m spida.P.cli ${CONFIG} \
    setup_adata_region \
    ${EXPERIMENT} \
    ${REGION} \
    ${PREFIX} \
    --suffix _filt \