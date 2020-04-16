# Compile instructions for zippy vision

1. Check that docker file base comes from nvidia/cuda
2. Have nvidia-docker and make sure you can compile locally
3. make sure that in Makefile `GPU` is 1 if you want gpu compilation (0 otherwise) and `LIBSO` is 1 to output .so file
3. run `docker build -t darknet .` and `docker run -ti -v $(pwd):/app/ --gpus 1 darknet /bin/bash` after that
4. go to app (`cd app`)
5. run `make clean` to delete files from previous compilations
6. run `make` to compile 


# Running darknet on cloud GPU (AWS)

## Setup
1. Ask Kristaps to launch a GPU instance

* If there are changes made in darknet docker (new libs or something)
  1. Make sure you have AWS credentials in `~/.aws/credentials`
  2. build docker container with `docker build -t darknet .`
  3. push new container to AWS ECR with 
    ```bash
      aws ecr get-login --no-include-email --region eu-central-1 | bash && \
      docker tag darknet:latest 885186778177.dkr.ecr.eu-central-1.amazonaws.com/zv-darknet:latest && \
      docker push 885186778177.dkr.ecr.eu-central-1.amazonaws.com/zv-darknet:latest 
    ``` 
  4. go into the instance with `ssh ec2-user@[ec2 instance public ip]`
  5. pull latest darknet docker image 
    ```bash
      aws ecr get-login --no-include-email --region eu-central-1 | bash && \
      docker pull 885186778177.dkr.ecr.eu-central-1.amazonaws.com/zv-darknet:latest && \
      docker tag 885186778177.dkr.ecr.eu-central-1.amazonaws.com/zv-darknet:latest darknet
    ```
  6. run `run_darknet` while in instance

## passing/receiving files through docker

  * All files that you need to access inside the container put in instance under `~/zv_data`
  * All files that you make/modify in docker and need to download/access from instance save in `/app/zv_data` while in docker


## Quick changing makefile or other files in docker

So you don't have to create a new container for every minor change in darknet files, you can modify them real-time while in docker container

1. Download nano while in docker container `apt-get install nano`
2. Modify files in docker with nano. (e.g. `nano Makefile` to turn on/off GPU for compilation)
3. Save nano file with `CTRL+X`, and `Y` afterwards