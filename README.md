# Microsoft Learn Sizes Script
A script to create, modify, or retire Azure virtual machine sizes using the new "sizes restructure project" format

Current latest version: Beta 1.7

## Current features
- Create new size series
  - Size Series file
    - Tabs for hardware components on a per-size basis
    - Dedicated 'Supported features' section
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
  - Prevents extraneous data entry by dynamically creating input files based on host specs
  - Instructs users who to contact if they try and run an unsupported operation (multi-CPU sizes, SR-IOV) 
  - Conflicting accelerator check (a size wouldn't have both Nvidia and AMD GPUs...)
  - Ensures -pr repo is selected
  - Duplicate Github PR check (remote/local)
- Compatibility with "The great divide" project
- Batch mode for multiple file edits
- Auto archival of input data for REST API team
- Clean-up mode to prevent clutter
- Supports series with multiple CPU models
- Microsoft and GitHub alias entry
- Script remote update capability

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
- SR-IOV flags for accelerators (what % of the accelerator do you have access to)
- Notation of software stack compatibility (CUDA, ROCM, AVX512, etc.)
- Pull data from REST API for preview
- Pull data from REST API for auto-population of data
- Split code into seperate module files (current file is nearly 2000 lines of code!)
 
## Potential features
- Docs build preview integration
- Auto batch runs (to keep docs perpetually up to date)
- Support for Linux (currently calls Windows programs such as Notepad and Excel)
- Official repo for CSV files (single source of truth, could be called by API in the future)
