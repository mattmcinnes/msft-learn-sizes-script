# Microsoft Learn Sizes Script
A script to create, modify, or retire Azure virtual machine sizes using the new "sizes restructure project" format

## Current features
- Create new size series
  - Size Series file
    - Tabs for hardware components on a per-size basis
  - Summary include file
  - Specs include file
    - Lists previously hidden specs such as CPU architecture, memory bandwidth, etc.
    - OEM and model "database" to prevent innacurate or non-existent hardware being listed
    - Contains a single table with min-max specs per-size (dynamically adjusted)
    - Support for emerging hardware types (NPUs, DPUs, FPGAs, etc.)
    - Support for emerging hardware OEMs (Intel GPUs, Microsoft CPUs, RISC-V, etc.)
- Template CSV files
  - Culls empty files (no Accelerators file for a size without accelerators)
- Demo mode (for non-content devs to evaluate the script)
-   Includes dummy "sizes folder" for those without local git clones
- Safety checks
  - Ensures -pr repo is selected
  - Duplicate Github PR check (remote/local)
  - Instructs users who to contact if they try and run an unsupported operation (multi-CPU sizes, SR-IOV) 
  - Conflicting accelerator check (a size wouldn't have both Nvidia and AMD GPUs...)

## Planned features
- Automatic TOC entry
- Automatic Size Family article entry
- Update size series
  - Read data of restructured sizes from repo and convert to workable CSVs
  - Add features or specs to a series
- Retire size series
  - Move to migrated folder
  - Create migration guide with standard format
  - Recommend new sizes (dynamic, can be re-run in the future)
- Compatibility with "The great divide" project
- SR-IOV flags for accelerators (what % of the accelerator do you have access to)
- Notation of software stack compatibility (CUDA, ROCM, AVX512, etc.)
 
## Potential features
- Docs build preview integration
- Auto batch runs (to keep docs perpetually up to date)
- Support for Linux (currently calls Windows programs such as notepad and excel)
