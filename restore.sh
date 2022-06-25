#!/bin/bash

# -t <runtime_type>: (optional) Type of runtime (eg: -t podman, -t docker)
# -f <input_file_path>: Read from specific file path (eg: -f backup.tar.gz)
# -y: (optional) Skip verification


# Read arguments

while getopts "t:f:y" flag; do
    case "${flag}" in
        t) runtime=${OPTARG};;
        f) input=${OPTARG};;
        y) skip=true;;
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
if [[ $skip != "true" ]]; then
    read -p "Press Enter to continue ... " -rsn1 op
    echo
    if [[ $op == "q" ]]; then
        echo "Exited"
        exit
    fi
fi

# Restore

flags=""
for v in "${volumes[@]}"; do
    flags="${flags} -v $v:/data/$v"
done

if [[ ! -z $input ]]; then
    mv $input data.tar.gz
fi

if [[ $runtime == "podman" ]]; then
    podman run --rm ${flags} -v $(pwd):/backup alpine:3.15 tar xzvf /backup/data.tar.gz -C /data --strip 1
else
    docker run --rm ${flags} -v $(pwd):/backup alpine:3.15 tar xzvf /backup/data.tar.gz -C /data --strip 1
fi

if [[ ! -z $input ]]; then
    mv data.tar.gz $input
fi
