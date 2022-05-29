#!/bin/bash

# -t <runtime_type>: (optional) Type of runtime (eg: -t podman, -t docker)


# Read arguments

while getopts ":t:" flag; do
    case "${flag}" in
        t) runtime=${OPTARG};;
    esac
done

# Get volume list

echo "Reading docker volume list ..."
if [ ! -f data.tar.gz ]; then
    echo "Error: Cannot find data.tar.gz file"
    exit 1
fi

volumes=($(tar --exclude="*/*/*" -tf data.tar.gz | tail -n +2 | tr "/" " " | awk '{print $2}'))

echo "---------- Volume list ----------"
printf '\t%s\n' "${volumes[@]}"
echo "---------------------------------"
read -p "Press Enter to continue ..."

# Restore

flags=""
for v in "${volumes[@]}"; do
    flags="${flags} -v $v:/data/$v"
done

if [[ $runtime == "podman" ]]; then
    podman run --rm ${flags} -v $(pwd):/backup alpine:3.15 tar xzvf /backup/data.tar.gz -C /data --strip 1
else
    docker run --rm ${flags} -v $(pwd):/backup alpine:3.15 tar xzvf /backup/data.tar.gz -C /data --strip 1
fi
