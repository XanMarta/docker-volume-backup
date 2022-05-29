#!/bin/bash

# -t <runtime_type>: (optional) Type of runtime (eg: -t podman, -t docker)
# -l <file_path>: (optional) Use list of files instead of all volumes (eg: -l list.txt)


# Read arguments

while getopts ":l:t:" flag; do
    case "${flag}" in
        l) filepath=${OPTARG};;
        t) runtime=${OPTARG};;
    esac
done

# Get volume list

if [[ ! -z $filepath ]]; then
    if [[ -f "$filepath" ]]; then
        echo "Info: Backing up volume list from file"
        readarray -t volumes < "$filepath"
    else
        echo "Error: File invalid"
        exit 1
    fi
else
    echo "Info: Backing up all available volumes"
    volumes=($(docker volume ls | tail -n +2 | awk '{print $2}'))
fi

echo "---------- Volume list ----------"
printf '\t%s\n' "${volumes[@]}"
echo "---------------------------------"
read -p "Press Enter to continue ..."

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

