# What is lacg/Axway Devtools?

This is a container that offers the Policy Studio, Configuration Studio and the Package Deploy Tools for Axway API Gateway in Linux x86-64 version.

As there are versions for Win32 and Linux, but no macOS versions, these containers brings a way to close these gaps and allows to run on a Mac these tools in a more easier way.

These containers coupled with, XQuartz, Docker and some scripts to be run from your Mac (you can find on the container /home/axway/ directory) makes it possible and easier to run these tools on a Mac.

## Getting Started

To run one of these tools, just copy the scripts policystudio, configurationstudio, esexplorer and dr from /home/axway to any location on your host Mac and make it runnable (chmod +x).

### Prerequisities

In order to run this container you'll need docker installed, XQuartz and have the scripts on your host machine. If one of the image is not on your host machine, it will take some time to download and run.

### Usage

#### For Policy Studio

Type policystudio and the tag version, like:

```shell
./policystudio 7.5.3
./policystudio 7.5.3.13
./policystudio 7.7.20.03
```

#### For Configuration Studio

Type configurationstudio and the tag version, like:

```shell
./configurationstudio 7.5.3
./configurationstudio 7.5.3.13
./configurationstudio 7.7.20.03
```

#### For ES Explorer

Type esexplorer and the tag version, like:

```shell
./esexplorer 7.5.3
./esexplorer 7.5.3.13
./esexplorer 7.7.20.03
```

## Built With

* centos:latest

## Author

* [Luiz Garcia](https://github.com/u/lacg)