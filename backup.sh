#!/bin/bash

# -t <runtime_type>: Type of runtime (eg: -t podman, -t docker)
# -l <list_file_path>: Use a list of files instead of all volumes (eg: -l list.txt)
# -f <output_file_path>: Set output file path (eg: -n backup.tar.gz)
# -y: Skip verification


# Read arguments

while getopts "l:f:t:y" flag; do
    case "${flag}" in
        l) filelist=${OPTARG};;
        f) output=${OPTARG};;
        t) runtime=${OPTARG};;
        y) skip=true;;
    esac
done

# Get volume list

if [[ ! -z $filelist ]]; then
    if [[ -f $filelist ]]; then
        echo "Info: Backing up volume list from file"
        readarray -t volumes < $filelist
    else
        echo "Error: File invalid"
        exit 1
    fi
else
    echo "Info: Backing up all available volumes"
    if [[ $runtime == "podman" ]]; then
        volumes=($(podman volume ls | tail -n +2 | awk '{print $2}'))
    else
        volumes=($(docker volume ls | tail -n +2 | awk '{print $2}'))
    fi
fi

echo "---------- Volume list ----------"
printf '\t%s\n' "${volumes[@]}"
echo "---------------------------------"
if [[ $skip != "true" ]]; then
    read -p "Press Enter to continue ... " -rsn1 op
    echo
    if [[ $op == "q" ]]; then
        echo "Exited"
        exit
    fi
fi

# Backup

flags=""
for v in "${volumes[@]}"; do
    flags="${flags} -v $v:/data/$v"
done

if [[ $runtime == "podman" ]]; then
    podman run --rm ${flags} -v $(pwd):/backup alpine:3.15 tar czvf /backup/data.tar.gz /data
else
    docker run --rm ${flags} -v $(pwd):/backup alpine:3.15 tar czvf /backup/data.tar.gz /data
fi

if [[ ! -z $output ]]; then
    mv data.tar.gz $output
fi
