---
title: SERIESNAMEUC series specs include
description: Include file containing specifications of SERIESNAMEUC-series VM sizes.
author: GITHUBALIAS
ms.topic: include
ms.service: virtual-machines
ms.subservice: sizes
ms.date: TODAYDATE
ms.author: MSFTALIAS
ms.reviewer: mattmcinnes
ms.custom: include file
---
| Part | Quantity <br><sup>Count Units | Specs <br><sup>SKU ID, Performance Units, etc.  |
|---|---|---|
| Processor      | VCORESQTY vCPUs       | PROCESSORSKU                                                 |
| Memory         | MEMORYGB GiB          | MEMORYDATA                                                   |
| Local Storage  | TEMPDISKQTY Disks     | TEMPDISKSIZE GiB <br>TEMPDISKIOPS IOPS <br>TEMPDISKSPEED MBps|
| Remote Storage | DATADISKSQTY Disks    | DATADISKIOPS IOPS <br>DATADISKSPEED MBps                     |
| Network        | NICSQTY NICs          | NETBANDWIDTH Mbps                                            |
| Accelerators   | ACCELQTY              | ACCELDATA                                                    |