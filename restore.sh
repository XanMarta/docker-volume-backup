#!/bin/bash

volumes=($(tar --exclude="*/*/*" -tf data.tar | tail -n +2 | tr "/" " " | awk '{print $2}'))
flags=""
for v in "${volumes[@]}"; do
    flags="${flags} -v $v:/data/$v"
done
docker run --rm ${flags} -v $(pwd):/backup alpine:3.15 tar xzvf /backup/data.tar.gz -C /data --strip 1