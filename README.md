# DistroKit Example

## Build and Run

- build docker image and prepare PTXdist project  
  `make`
- run image in bash-mode
  `make run`
- select PTXdist configuration  
  `ptxdist platform configs/platform-v7a/platformconfig`
- build image  
  `ptxdist image -q -j -n19`
- run image in qemu  
  `configs/platform-v7a/run`

## Further information

- [https://www.pengutronix.de/de/blog/2017-08-28-DistroKit_Intro.html](https://www.pengutronix.de/de/blog/2017-08-28-DistroKit_Intro.html)
