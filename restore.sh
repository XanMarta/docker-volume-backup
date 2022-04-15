#!/bin/bash

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
docker run --rm ${flags} -v $(pwd):/backup alpine:3.15 tar xzvf /backup/data.tar.gz -C /data --strip 1
