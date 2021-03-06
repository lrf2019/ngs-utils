#!/bin/bash

set -e
set -u


function showHelp() {
    #
    # Display commandline help on STDOUT.
    #
    cat <<EOH
===============================================================================================================
Usage:
        $(basename $0) OPTIONS
        
Options:    
        --h  Show this help.

        Required:
        -p  projectName (For new runs, use the sequencing run name.)
        -d  sequencingStartDate (YYMMDD)
        -r  run (run number contains 4 numbers: 0123)
        -f  flowcell (example: NextSeq, AHLJ5YAFXX or MiSeq, 000000000-BPJ2D_projectName)
        -q  sequencer (NextSeq:NB501043/NB501093 or MiSeq:M01785/M01997)
        -l  lane (number of lanes used, 1 for MiSeq, 4 for NextSeq)
        
        -i  informationFile (default:None. Comma separated txt file, 1st column barcode, 2nd colum externalSampleID. NO HEADER!)
            if no informationFile is provided, -n sampleNumber is required
        -n  sampleNumber (Number of samples in the pool, only necessary if no informationFile is provided)
        
        Optional:
        -w  workDir (default is this directory)
        -b  barcodeType (default: RPI. AGI,LEX, NEB enz.)
        -c  capturingKit (default:None, name of capturingKit (e.g. Agilent\/ONCO_v3)
        -k  prepKit (default:Exceptional Prep kit. Important for RNA: lexogen, TruSeq, RiboZero)
        -g  species (default:homo_sapiens|GRCh37, if other species, supply like 'homo_sapiens|GRCh37')
        -s  sampleType (DNA/RNA, default:RNA)
        -t  seqType (default:PE. otherwise specify SR)

        
Output will be written in workDir with the name: {projectName}.csv
===============================================================================================================
EOH
    trap - EXIT
    exit 0
}
sequencingStartdate=
while getopts "w:s:k:t:g:q:l:m:p:c:d:r:f:b:n:i:h" opt;
do

    case $opt in h)showHelp;; 
                 w)workDir="${OPTARG}";; 
                 s)sampleType="${OPTARG}";; 
                 k)prepKit="${OPTARG}";; 
                 t)seqType="${OPTARG}";; 
                 g)species="${OPTARG}";; 
                 q)sequencer="${OPTARG}";; 
                 l)lane="${OPTARG}";; 
                 p)projectName="${OPTARG}";; 
                 c)capturingKit="${OPTARG}";; 
                 d)sequencingStartDate="${OPTARG}";; 
                 r)run="${OPTARG}";; 
                 f)flowcell="${OPTARG}";; 
                 b)barcodeType="${OPTARG}";; 
                 n)sampleNumber="${OPTARG}";;
                 i)informationFile="${OPTARG}";;
    esac
done



if [[ -z "${sampleType:-}" ]]; then
    sampleType="RNA"
fi

if [[ -z "${capturingKit:-}" ]]; then
    capturingKit="None"
fi

if [[ -z "${projectName:-}" ]]; then
    echo -e '\nERROR: Must specify a projectName\n'
    showHelp
    exit 1
fi

if [[ -z "${sequencingStartDate:-}" ]]; then
    echo -e '\n ERROR: must specify sequencingStartDate YYMMDD'
    showHelp
    exit 1
fi

if [[ -z "${seqType:-}" ]]; then
    seqType="PE"
fi

if [[ -z "${prepKit:-}" ]]; then
    prepKit="'Exceptional Prep kit'"
fi

if [[ -z "${workDir:-}" ]]; then
    workDir=$(pwd)
fi

if [[ -z "${species:-}" ]]; then
    species="homo_sapiens|GRCh37"
fi

if [[ -z "${sequencer:-}" ]]; then
    echo -e '\n ERROR: must specify sequencer used'
    showHelp
    exit 1
fi

if [[ -z "${run:-}" ]]; then
    echo -e '\n ERROR: must specify run number, like 0123'
    showHelp
    exit 1
fi

if [[ -z "${lane:-}" ]]; then
    echo -e '\n ERROR: must specify numbers of lanes used'
    showHelp
    exit 1
fi

if [[ -z "${flowcell:-}" ]]; then
    echo -e '\n ERROR: must specify flowcell number'
    showHelp
    exit 1
fi

if [[ -z "${barcodeType:-}" ]]; then
    barcodeType="RPI"
fi

if [[ -z "${informationFile:-}" ]]; then
    informationFile="None"
    if [[ -z "${sampleNumber:-}" ]]; then
        echo -e '\n ERROR: must specify number of samples used'
        showHelp        
        exit 1
    fi
fi


printf "externalSampleID,barcode,project,capturingKit,sampleType,seqType,prepKit,species,Gender,arrayFile,lane,sequencingStartDate,sequencer,run,flowcell,barcodeType\n" > "${workDir}/${projectName}.csv"


if [ "${informationFile}" == "None" ]; then
    for ((l=1;l<="${lane}";l++))
    do
        for ((i=1;i<="${sampleNumber}";i++))
        do
        printf "${projectName}_sample${i}" >> "${workDir}/${projectName}.csv"  ##Dummy external sample ID
        printf ",DummyBarcode${i}" >> "${workDir}/${projectName}.csv" ## Dummy barcode
        printf ",${projectName}" >> "${workDir}/${projectName}.csv" ## project
        printf ",${capturingKit}" >> "${workDir}/${projectName}.csv" ## capturingKit
        printf ",${sampleType}" >> "${workDir}/${projectName}.csv" ## sampleType
        printf ",${seqType}" >> "${workDir}/${projectName}.csv" ## seqType
        printf ",${prepKit}" >> "${workDir}/${projectName}.csv" ## prepKit
        printf ",${species}" >> "${workDir}/${projectName}.csv" ## species
        printf "," >> "${workDir}/${projectName}.csv"  ## Gender
        printf "," >> "${workDir}/${projectName}.csv" ## arrayFile
        printf ",${l}" >> "${workDir}/${projectName}.csv" ##lane
        printf ",${sequencingStartDate}" >> "${workDir}/${projectName}.csv" ##sequencingstartdate
        printf ",${sequencer}" >> "${workDir}/${projectName}.csv" ##sequencer
        printf ",${run}" >> "${workDir}/${projectName}.csv" ##run
        printf ",${flowcell}" >> "${workDir}/${projectName}.csv" ## flowcell
        printf ",${barcodeType}\n" >> "${workDir}/${projectName}.csv"
        done
    done
        
else    
    for ((l=1;l<="${lane}";l++))
    do
        while read line
        do
        barcode=$(echo "${line}" | cut -d , -f1)
        externalSampleID=$(echo "${line}" | cut -d , -f2)
        printf "${externalSampleID}" >> "${workDir}/${projectName}.csv"  ##external sample ID
        printf ",${barcode}" >> "${workDir}/${projectName}.csv" ## barcode
        printf ",${projectName}" >> "${workDir}/${projectName}.csv" ## project
        printf ",${capturingKit}" >> "${workDir}/${projectName}.csv" ## capturingKit
        printf ",${sampleType}" >> "${workDir}/${projectName}.csv" ## sampleType
        printf ",${seqType}" >> "${workDir}/${projectName}.csv" ## seqType
        printf ",${prepKit}" >> "${workDir}/${projectName}.csv" ## prepKit
        printf ",${species}" >> "${workDir}/${projectName}.csv" ## species
        printf "," >> "${workDir}/${projectName}.csv"  ## Gender
        printf "," >> "${workDir}/${projectName}.csv" ## arrayFile
        printf ",${l}" >> "${workDir}/${projectName}.csv" ##lane
        printf ",${sequencingStartDate}" >> "${workDir}/${projectName}.csv" ##sequencingstartdate
        printf ",${sequencer}" >> "${workDir}/${projectName}.csv" ##sequencer
        printf ",${run}" >> "${workDir}/${projectName}.csv" ##run
        printf ",${flowcell}" >> "${workDir}/${projectName}.csv" ## flowcell
        printf ",${barcodeType}\n" >> "${workDir}/${projectName}.csv"
        done < "${informationFile}"
    done
fi


echo "Samplesheet is finished!"






