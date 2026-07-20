# DRAGEN v4.5.4 Docker Image

Production-oriented DRAGEN 4.5.4 container build for Oracle Linux 8.

## Resources

- [Illumina DRAGEN Bio-IT Platform](https://www.illumina.com/products/by-type/informatics-products/dragen-bio-it-platform.html)
- [Illumina DRAGEN Downloads & Support](https://support.illumina.com/sequencing/sequencing_software/dragen-bio-it-platform/downloads.html)


## Build

1. Download the DRAGEN runfile from Illumina (signed URL, login required).
2. Save it in the project root with a stable filename.

Expected default filename:
```bash
dragen-4.5.4-12.multi.el8.x86_64.run
```

Recommended download pattern (prevents querystring filenames):

```bash
wget -O dragen-4.5.4-12.multi.el8.x86_64.run "<signed-url>"
```

Build the image:
```bash
docker build -t oracle8-dragen:4.5.4 .
```

If your runfile name or target version differs, override them at build time using build arguments:
```bash
docker build \
    --build-arg DRAGEN_VERSION="4.5.4" \
    --build-arg RUNFILE="<your-file>.run" \
    -t oracle8-dragen:4.5.4 .
```

## Run

Start an interactive shell:
```bash
docker run --rm -it oracle8-dragen:4.5.4 /bin/bash
```
Run DRAGEN help:
```bash
docker run --rm oracle8-dragen:4.5.4 dragen --help
```

## Notes

- **Repository Dependencies:** During the package setup, the build process explicitly triggers Oracle's `ol8_codeready_builder` repository to automatically satisfy deep developer dependencies required by `R` (such as `openblas-devel`).
- **Installation Layout:** DRAGEN binaries are deployed straight to `/opt/dragen/4.5.4/`. The `PATH` environment variable is automatically configured so `dragen` executes natively anywhere.
- **RPM CPIO Extraction:** The monolithic installation script is bypassed via an explicit extract and `rpm2cpio` loop. This protects the pipeline from systemd/fstab runtime checks failing inside non-privileged Docker spaces.
- **Validation:** Because native execution scripts may output non-zero status codes during dry container runs, image integrity is strictly validated via explicit existence checks on `/opt/dragen/4.5.4/bin/dragen`.
- **Hardware Layer Expectations:** Running DRAGEN away from dedicated local FPGA acceleration components or unmapped device lines may yield driver missing warnings at runtime.