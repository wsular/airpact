# USFS Bluesky containers

## 18 August 2022
- Build new singularity image file (sif) from latest Bluesky Docker container
  - From Joel Dubowy - This container allows the user to "configure fuelbeds to leave fires in the "fires" list instead of moving them to the "failed_fires" list when fuelbed look-up fails.  This way, you'll be able to do a single run with both US and Canada fires, producing fires_locations.csv containing all fires, with fuelbed info for US fires."

### Build singularity image file from Docker
- [PNW AirFire Docker images](https://hub.docker.com/r/pnwairfire/bluesky/tags)
  - We want the latest image that was built earilier today
    - [v4.3.56](https://hub.docker.com/layers/bluesky/pnwairfire/bluesky/v4.3.56/images/sha256-404f3adbc0b83aadc953cce52593e7ccffe6224373b0aa4b54fd8e3105769439?context=explore)

- Commands to build the singularity image file.
  ```
  # Create the sif
  singularity pull docker://pnwairfire/bluesky:v4.3.56
  # Move the sif to working directory
  sudo mv bluesky_v4.3.56.sig /work/.
  ```

### Test the new Bluesky sif

    ```
    singularity exec \
   -B /work/bluesky_v4.3.56.sif \
    bsp -n \
        -J load.sources='[{"name": "firespider","format": "JSON","type": "API","endpoint": "https://airfire-data-exports.s3-us-west-2.amazonaws.com/fire-spider/v3/fireinfosystem-dropouts-persisted/{today-1:%Y-%m-%d}.json"}]' \
        -B skip_failed_fires=true \
        -B fuelbeds.skip_failures=true \
        -o $AIREMISFIRE/output.json \
        -C extrafiles.dest_dir=$AIREMISFIRE \
        -J extrafiles.sets='["firescsvs"]' \
    load fuelbeds extrafiles
    ```