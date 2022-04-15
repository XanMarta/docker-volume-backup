#!/bin/bash

# Get volume list

while getopts l: flag; do
    case "${flag}" in
        l) filepath=${OPTARG};;
    esac
done

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
docker run --rm ${flags} -v $(pwd):/backup alpine:3.15 tar czvf /backup/data.tar.gz /data
