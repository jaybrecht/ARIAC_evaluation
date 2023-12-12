#!/bin/bash

if [[ ! $1 ]] ; then
    echo "Team configuration argument not passed" 
    exit 1
fi

teamName=$(python3 get_team_name.py $1)

if [[ ! $teamName ]] ; then
    echo "Team name not found" 
    exit 1
fi

#enable local connections to docker
xhost +local:docker

if [[ "$2" == "nvidia" ]] ; then
    # Build the docker image
    docker run -t -d --name $teamName -e DISPLAY=$DISPLAY -e LOCAL_USER_ID=1000  --gpus=all --runtime=nvidia -e "NVIDIA_DRIVER_CAPABILITIES=all" --network=host --pid=host --privileged -v /tmp/.X11-unix:/tmp/.X11-unix:rw nistariac/ariac2024:dev
else
    # Build the docker image
    docker run -t -d --name $teamName -e DISPLAY=$DISPLAY -e LOCAL_USER_ID=1000  --network=host --pid=host --privileged -v /tmp/.X11-unix:/tmp/.X11-unix:rw nistariac/ariac2024:dev
fi

# Copy scripts directory and yaml file
docker cp ./scripts/ $teamName:/
docker cp ./competitor_build_scripts/ $teamName:/
docker cp ./trials/ $teamName:/
docker cp ./$1.yaml $teamName:/scripts

# Run build script
docker exec -it $teamName bash -c ". /scripts/build_environment.sh $1"
