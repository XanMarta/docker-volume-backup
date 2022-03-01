#!/bin/bash

volumes=($(docker volume ls | tail -n +2 | awk '{print $2}'))
flags=""
for v in "${volumes[@]}"; do
    flags="${flags} -v $v:/data/$v"
done
docker run --rm ${flags} -v $(pwd):/backup alpine:3.15 tar czvf /backup/data.tar.gz /data