# Docker Repository #

This repository collects all the sources used to build the docker images used to run certain jobs.
The main rule to keep a fast pace when building an image is to keep only the strictly necessary files in the
current folder.

## Repository Structure ##

Under `dockerfiles` folder are stored all the sub-folders named after the image they generate. Each of these
sub-folders contains the self-comprehensive build context imported by docker during a build task.

To ease a post-configuration of an image is possible to create ad-hoc configuration files from the
`conf_template` folder (e.g. ssh host configurations).

## Install Docker ##

On Debian is available a dedicated *.deb package. Follow the instructions at [this
page](https://docs.docker.com/engine/install/debian/).

Docker by default stores all the generated artifacts (images/containers/volumes/networks) into the default
folder `/var/lib/docker/`. If the space required is bigger than what available on the mentioned folder, one
trick consist in mounting a folder created on a more spacious file-system and bind it to the docker destination
folder.

This can be achieved by adding the following line to the `/etc/fstab` file:

``` shell
<large_space_folder> /var/lib/docker/ none defaults,bind 0 0
```

## Uninstall Docker ##

To uninstall a docker installation execute the following command:

``` shell
# old versions
sudo apt remove docker docker-engine docker.io containerd runc
# new versions
sudo apt remove docker-ce docker-ce-cli containerd.io
```

It is not a problem if `apt` reports that some of them are not installed at all (it is referred to older
versions).

Moreover to completely remove all images/containers/volumes/networks, remove the `/var/lib/docker/` folder
(original docker content destination folder):

``` shell
sudo rm -rf /var/lib/docker
```

## Docker How-To ##

The following sections collect some nice tricks to efficiently take care of the images in docker. In order to
let your user to use docker without the use of sudo, add your user to the `docker` group:

``` shell
sudo usermod -a -G docker <your_login>
```

Remember to logout and login again in your user account for this setting to take effect.

### Build Images ###

Before building an image be sure to execute the initialization script that copies the common scripts in the
**scripts** sub-folders of each target-image. Hence the usual command to build the image itself:

``` shell
./init-build.sh
sudo docker build -t <name-image>:<tag> <context-source>
```

Where the `<context-source>` is the folder from which the docker daemon will get its context,
i.e. `./dockerfiles/<target-context>`.

The initialization script copies the scripts only in those targets that require them. To add a new environment
to the list modify the _init-build.sh_ script.

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

In Windows properly set the `DISPLAY` variable will suffice (no X11 volume mapping required). Configure the
VcXsrv Windows X Server software. Make sure the OS variable is set to the internal gateway address such that the
X11 server can listen to the docker container requests.

Follow this guide to have more info and ensure the container can access the user X Window process:
https://www.cbtechinc.com/desktop-docker-1-linux-graphical-containers/

### Cleaning Up ###

There are few commands to free up some space when getting the error `no space left on device`.

#### Delete All At Once ####

This will delete all containers that were stopped as well as all volumes and networks and that are not used by
any container. It will also remove all dangling images:

``` shell
docker system prune
```

#### Deleting Dandling Images Only ####

When using the same name:tag combinations to try out different partial images, the local registry will be
cluttered with orphan `<none>` image steps. To clear out them use the following

``` shell
docker rmi -f $(docker images -f "dangling=true" -q)
```

The `-f` option force the removal, it might be required (and often suggest by the tool itself).


todo:

- reinstall docker on your drive to have access to a way larger volume
