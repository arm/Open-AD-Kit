# Arm Open AD Kit (OADK) – RD1-AE Build and Deployment Scripts

This repository provides Yocto patches and supporting scripts to build and deploy **Open AD Kit (OADK) demos** on the **Arm RD1-AE Reference Design** platform.

**RD1-AE (Arm Reference Design-1 AE)** is a reference platform for automotive and autonomous systems development, enabling early software bring-up and validation in line with Arm’s Shift-Left strategy.  
Learn more: https://developer.arm.com/Tools%20and%20Software/Arm%20Reference%20Design-1%20AE

The **Open AD Kit (OADK)** demo is derived from the [Autoware Open AD Kit project](https://github.com/autowarefoundation/openadkit_demo) and provides a containerized reference environment for evaluating autonomous driving workloads on Arm architectures.

The patches and scripts in this repository have been validated by successfully building and running the OADK demo on the **Corellium Arm Virtual Platform for RD1-AE**.

For a visual introduction to the OADK blueprint, watch the following overview video:  
[**Open AD Kit Overview and Demo Walkthrough**](https://next.frame.io/share/bc592483-f2b3-4cb5-a46e-5d966755120f/view/7c1758fb-7054-4b74-9237-6af101c1952b)

## Repo Content

This repository includes the following Yocto patches, which customize the standard RD1-AE build to provide a ready-to-run environment for the Open AD Kit demo, including container support, scaled system resources, and Safety Island actuation integration:

- **0001-RD1-AE-Add-podman-compose-support.patch**  
  Patches the `podman-compose` recipe and adds `podman-compose` to the RD1-AE image to enable container orchestration for the OADK demo.

- **0002-RD1-AE-increase-CPU-count-memory-and-disk-size.patch**  
  Scales the platform to 16 CPUs, 16GB DRAM (DTS and kernel configuration), and requests 8GB free rootfs space to support OADK workloads.

- **0003-RD1-AE-additional-applications.patch**  
  Adds `git` and `nano` to the image for development and debugging convenience.

- **0004-Add-recipe-for-actuation-module-on-sicl2-R82AE.patch**  
  Adds a new build configuration for the Actuation Module and patches the application for the SI-CL2 Cortex®-R82AE Safety Island platform.

- **0005-Add-recipe-for-deploying-the-actuation-demo-dockerfiles.patch**  
  Adds a Yocto recipe to deploy the Actuation demo Dockerfiles and required assets into the primary compute root filesystem.

This repository also includes the following firmware packaging script, which is required when running the OADK demo on the Corellium Arm Virtual Platform (RD1-AE):

- **package_corellium_RD1-AE_V1.1.1.sh** – Creates a Corellium-compatible firmware image by taking the build output, renaming the required artifacts, generating the necessary JSON metadata, and packaging everything into a `.tar.gz` archive.

> **Note:** This script is not required when running the OADK demo on an RD1-AE Fixed Virtual Platform (FVP).
