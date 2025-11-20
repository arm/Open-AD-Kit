#
# SPDX-FileCopyrightText: <text>Copyright 2025 Arm Limited and/or its
# affiliates <open-source-office@arm.com></text>
#
# SPDX-License-Identifier: MIT

#! /bin/bash


# Initialize variables
type=""
distro=""
output=""
input=""
version="1.1.1"
firmware_name=""
verbose=false

# Function to display help
show_help() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -t <type>      Type of the package (accepted values: baremetal, virtualization, systemready-glibc)"
  echo "  -d <distro>    Distribution (required if type is systemready-glibc)"
  echo "  -f <firmware>  Firmware name"
  echo "  -o <output>    Output path (optional)"
  echo "  -i <input>     Input path (optional)"
  echo "  -v,            Verbose"
  echo "  -h,            Display this help message"
}

# Parse command-line arguments
while getopts ":t:d:o:i:f:vh" opt; do
  case $opt in
    t)
      type=$OPTARG
      if [[ "$type" != "baremetal" && "$type" != "virtualization" && "$type" != "systemready-glibc" ]]; then
        echo "Invalid type: $type"
        echo " "
        show_help
        exit 1
      fi
      ;;
    d)
      distro=$OPTARG
      if [[ "$distro" != "fedora" && "$distro" != "opensuse" && "$distro" != "debian" ]]; then
        echo "Invalid distro: $distro"
        echo " "
        show_help
        exit 1
      fi
      ;;
    o)
      output=$OPTARG
      ;;
    i)
      input=$OPTARG
      ;;
   v)
      verbose=true
      ;;
    f)
      firmware_name=$OPTARG
      ;;
    h)
      show_help
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      show_help
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      show_help
      exit 1
      ;;
  esac
done

# Shift off the options and optional --.
shift $((OPTIND-1))


# Check if the mandatory -t option is provided
if [[ -z "$type" ]]; then
  echo "Error: Option -t (type) is mandatory."
  show_help
  exit 1
fi


# Check if distro is provided when type is systemready-glibc
if [[ "$type" == "systemready-glibc" && -z "$distro" ]]; then
  echo "Option -d (distro) is required when type is systemready-glibc."
  show_help
  exit 1
fi



if [[ -z "$firmware_name" ]]; then
   package_name="${type}-${version}.coreimg"
else
  package_name=$firmware_name
fi

if [[ -z "$input" ]]; then
   input=build/tmp_${type}/deploy/images/fvp-rd-kronos
fi

if [[ -z "$output" ]]; then
   output=${input}
fi

# Use the variables
echo "Type: $type"
echo "Distro: $distro"
echo "Output: $output"
echo "Input: $input"
echo "Version: $version"
echo "Firmware Name: $package_name"


START_PATH=$(pwd)


if [[ "$verbose" == true ]]; then
  # option for cp
  OPT="-v" 
  # option for zip
  OPT_ZIP="-v"
else
  OPT="" 
  OPT_ZIP=""
fi


ZIP_CMD=" zip "

#First rename the files

cp ${OPT} ${input}/rse-flash-image.img                            ${output}/boot_flash
cp ${OPT} ${input}/ap-flash-image.img                             ${output}/ap_flash
if [ -f ${input}/efi-capsule-update-disk-image-fvp-rd-kronos.img ]; then
    # The file exists, so copy it
    cp ${OPT} ${input}/efi-capsule-update-disk-image-fvp-rd-kronos.img    ${output}/sdcard
elif [ -f ${input}/arm-systemready-linux-distros-${distro}*.iso ]; then
    # The file exists, so copy it
    cp ${OPT} ${input}/arm-systemready-linux-distros-${distro}*.iso    ${output}/sdcard
else  
    # The file does not exist
    truncate --size 4GiB ${output}/sdcard
fi

cp ${OPT} ${input}/rse-nvm-image.img                              ${output}/lcm_otp

if [ "${type}" = "baremetal" ] || [ "${type}" = "virtualization" ]; then
cp ${OPT} ${input}/${type}-image-fvp-rd-kronos.wic                ${output}/virtio_0
else
cp ${OPT}  ${input}/arm-systemready-linux-distros-${distro}*.wic  ${output}/virtio_0
fi

cp ${OPT} ${input}/encrypted_dm_provisioning_bundle.bin           ${output}/  
cp ${OPT} ${input}/encrypted_cm_provisioning_bundle_0.bin         ${output}/
cp ${OPT} ${input}/rse-rom-image.img                              ${output}/


# First, we need to pack the ROM and the CM/DM provisioning firmware bundles into a nested archive.
# These firmware components of the RD-1 AE are expected to be loaded into memory at specific addresses by a "debugger", or by the platform model.
# This nested archive contains scatter-gather instructions for how and where to load the relevant components.
# The resulting archive is just called `firmware`.

pushd ${output}


# AVH error :  Error checking file: Sorry, the firmware package you uploaded does not support the selected device.
cat << EOF > load.txt
name:rse-rom-image.img      load:0x11000000
name:encrypted_cm_provisioning_bundle_0.bin     load:0x31000000
name:encrypted_dm_provisioning_bundle.bin       load:0x31080000
EOF



${ZIP_CMD} ${OPT_ZIP} firmware.zip \
    load.txt \
    encrypted_cm_provisioning_bundle_0.bin \
    encrypted_dm_provisioning_bundle.bin \
    rse-rom-image.img


# Somehow it still produces firmware.zip , so remove the .zip
mv firmware.zip firmware  

# Generate the package header
INFO_FILE=Info.json

cat << EOF > ${INFO_FILE}
{
    "Build": "${type}",
    "Version": "${version}",
    "Type": "iot",
    "DeviceIdentifier": "kronos-nosys",
    "UniqueIdentifier": "${package_name}"
}
EOF

# Those binaries need to be extracted from a existing KronosV1.0 AVH firmware package.
cp ${OPT} ${START_PATH}/arm_cmn_0        arm_cmn_0
cp ${OPT} ${START_PATH}/arm_ni_710ae_10  arm_ni_710ae_10
cp ${OPT} ${START_PATH}/arm_ni_710ae_11  arm_ni_710ae_11
cp ${OPT} ${START_PATH}/arm_ni_710ae_12  arm_ni_710ae_12
cp ${OPT} ${START_PATH}/arm_ni_tower_0   arm_ni_tower_0
cp ${OPT} ${START_PATH}/arm_ni_tower_1   arm_ni_tower_1
cp ${OPT} ${START_PATH}/arm_ni_tower_2   arm_ni_tower_2
cp ${OPT} ${START_PATH}/arm_ni_tower_3   arm_ni_tower_3
cp ${OPT} ${START_PATH}/arm_ni_tower_4   arm_ni_tower_4
cp ${OPT} ${START_PATH}/arm_ni_tower_5   arm_ni_tower_5
cp ${OPT} ${START_PATH}/arm_ni_tower_6   arm_ni_tower_6


time ${ZIP_CMD} ${OPT_ZIP} ${START_PATH}/${package_name} \
    ${INFO_FILE} \
    firmware\
    ap_flash \
    boot_flash \
    virtio_0 \
    sdcard \
    lcm_otp \
    arm_cmn_0 \
    arm_ni_710ae_10 \
    arm_ni_710ae_11 \
    arm_ni_710ae_12 \
    arm_ni_tower_0 \
    arm_ni_tower_1 \
    arm_ni_tower_2 \
    arm_ni_tower_3 \
    arm_ni_tower_4 \
    arm_ni_tower_5 \
    arm_ni_tower_6 
    
popd     
