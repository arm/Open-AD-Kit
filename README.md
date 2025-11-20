# Arm Open AD Kit (OADK) Build and Deployment Scripts

This repository provides scripts to help you **build and deploy the Arm Open AD Kit (OADK) demo** on **Arm-based virtual platforms** that support **Arm’s Shift-Left Strategy**.

The **Arm Open AD Kit (OADK)** demo application is derived from the [Autoware Open AD Kit project](https://github.com/autowarefoundation/openadkit_demo) and ported to execute on various Arm and other platforms.  
It provides a reference environment for evaluating autonomous driving workloads using containerized components on Arm architectures.

For a visual introduction to the OADK blueprint, watch the following overview video:  
[**Open AD Kit Overview and Demo Walkthrough**](https://next.frame.io/share/bc592483-f2b3-4cb5-a46e-5d966755120f/view/7c1758fb-7054-4b74-9237-6af101c1952b)

## Contents

This repository includes the following build assets:
- **Yocto patch** – customizes the Linux image for the OADK Planning-Control container by enabling Podman Compose, increasing CPU and memory support, and improving build configuration.
- **Firmware packaging script** – creates a Corellium-compatible firmware image for use when deploying the OADK demo on Arm Virtual Platforms.
