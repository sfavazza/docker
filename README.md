# Docker Repository #

This repository collects all the sources used to build the docker images used to run certain jobs.
The main rule to keep a fast pace when building an image is to keep only the strictly necessary files in the
current folder.

## Repository Structure ##

Under `dockerfiles` folder are stored all the folders which in turn contain the docker file describing a specific
image and the necessary sources needed with them (if not a script to recover them from Internet).

## Docker How-To ##

The following sections collect some nice tricks to efficiently take care of the images in docker.

### Build Images ###

The simplest is to create the image based on the docker file found in the building folder (the one from which
the context is taken and sent to the docker daemon):

``` shell
sudo docker build -t <name-image>:<tag> <context-source>
```

Where the `<context-source>` is the folder from which the docker daemon will get its context, normally is set to
the current folder `.` (dot).

### Running Images ###

When running an image it is always advisable to mount the folder the job should be performed on in the image. In
this way the created docker container can perform its job and the sources/results will all co-exist in the
mounted volume:

``` shell
sudo docker run --rm -ti -v "$(pwd)":/home/developer/work <docker-image>
```

The `--rm` will remove the container once closed, the `-ti` are two independent flags to allocate a pseudo-tty
and to keep the container open and interactive when run.

Mounting a volume also allow the container to share resources with the host machine. For instance the X11 socket
to show programs GUIs. In the example below, two volumes are mounted, one to let the container work on the
current directory and one to make a 1-to-1 mapping of the host X11 socket into the container socket (`ro` read
only to prevent the image from corrupting the host socket):

``` shell
sudo docker run --rm -ti -v "$(pwd)":/home/developer \
       -v /tmp/.X11-unix:/tmp/.X11-unix:ro -e DISPLAY=$DISPLAY \
       <docker-image>
```

### Deleting Images ###

When using the same name:tag combinations to try out different partial images, the local registry will be
cluttered with orphan `<none>` image steps. To clear out them use the following

``` shell
sudo docker rmi -f $(sudo docker images -f "dangling=true" -q)
```

The `-f` option force the removal, it might be required (and often suggest by the tool itself).
