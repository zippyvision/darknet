# Compile instructions for zippy vision

1. Check that docker file base comes from nvidia/cuda
2. Have nvidia-docker and make sure you can compile locally
3. make sure that in Makefile `GPU` is 1 if you want gpu compilation (0 otherwise) and `LIBSO` is 1 to output .so file
3. run `docker build -t darknet .` and `docker run -ti -v $(pwd):/app/ --gpus 1 darknet /bin/bash` after that
4. go to app (`cd app`)
5. run `make clean` to delete files from previous compilations
6. run `make` to compile 