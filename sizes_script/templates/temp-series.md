---
title: SERIESNAMEUC size series
description: Information on and specifications of the SERIESNAMEUC-series sizes
author: GITHUBALIAS
ms.service: virtual-machines
ms.subservice: sizes
ms.topic: conceptual
ms.date: ${todayDate}
ms.author: MSFTALIAS
ms.reviewer: mattmcinnes
---

# SERIESNAMEUC sizes series

[!INCLUDE [SERIESNAMELC-summary](./includes/SERIESNAMELC-summary.md)]

## Sizes in series

### [Basics](#tab/sizebasic)

vCPUs and Memory for each size

TABLECPUMEMORY

#### VM Basics resources
- [What are vCPUs](https://learn.microsoft.com/azure/virtual-machines/managed-disks-overview)
- [Check vCPU quotas](https://learn.microsoft.com/azure/virtual-machines/quotas)
- [Introduction to Azure compute units (ACUs)](https://learn.microsoft.com/azure/virtual-machines/acu)

### [Local Storage](#tab/sizestoragelocal)

Local (temp) storage info for each size

TABLELOCALSTORAGE

> [!NOTE]
> No local storage present in this series. For similar sizes with local storage, see the [Dpdsv6-series](./dpdsv6-series.md).
>
> For frequently asked questions, see [Azure VM sizes with no local temp disk](../../azure-vms-no-temp-disk.yml).

### [Remote Storage](#tab/sizestorageremote)

Remote (uncached) storage info for each size

TABLESTORAGE

#### Storage resources
- [Introduction to Azure managed disks](https://learn.microsoft.com/en-us/azure/virtual-machines/managed-disks-overview)
- [Azure managed disk types](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types)
- [Share an Azure managed disk](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-shared)

#### Table definitions
- <sup>1</sup>These sizes support [bursting](../../disk-bursting.md) to temporarily increase disk performance. Burst speeds can be maintained for up to 30 minutes at a time.
- <sup>2</sup>Special Storage refers to either [Ultra Disk](../../../virtual-machines/disks-enable-ultra-ssd.md) or [Premium SSD v2](../../../virtual-machines/disks-deploy-premium-v2.md) storage.
- Storage capacity is shown in units of GiB or 1024^3 bytes. When you compare disks measured in GB (1000^3 bytes) to disks measured in GiB (1024^3) remember that capacity numbers given in GiB may appear smaller. For example, 1023 GiB = 1098.4 GB.
- Disk throughput is measured in input/output operations per second (IOPS) and MBps where MBps = 10^6 bytes/sec.
- Data disks can operate in cached or uncached modes. For cached data disk operation, the host cache mode is set to ReadOnly or ReadWrite. For uncached data disk operation, the host cache mode is set to None.
- To learn how to get the best storage performance for your VMs, see [Virtual machine and disk performance](../../../virtual-machines/disks-performance.md).


### [Network](#tab/sizenetwork)

Network interface info for each size

TABLENETWORK

#### Networking resources
- [Virtual networks and virtual machines in Azure](https://learn.microsoft.com/azure/virtual-network/network-overview)
- [Virtual machine network bandwidth](https://learn.microsoft.com/azure/virtual-network/virtual-machine-network-throughput)

#### Table definitions
- Expected network bandwidth is the maximum aggregated bandwidth allocated per VM type across all NICs, for all destinations. For more information, see [Virtual machine network bandwidth](https://learn.microsoft.com/azure/virtual-network/virtual-machine-network-throughput)
- Upper limits aren't guaranteed. Limits offer guidance for selecting the right VM type for the intended application. Actual network performance will depend on several factors including network congestion, application loads, and network settings. For information on optimizing network throughput, see [Optimize network throughput for Azure virtual machines](https://learn.microsoft.com/azure/virtual-network/virtual-network-optimize-network-bandwidth). 
-  To achieve the expected network performance on Linux or Windows, you may need to select a specific version or optimize your VM. For more information, see [Bandwidth/Throughput testing (NTTTCP)](https://learn.microsoft.com/azure/virtual-network/virtual-network-bandwidth-testing).

### [Accelerators](#tab/sizeaccelerators)

Accelerator (GPUs, FPGAs, etc.) info for each size

TABLEACCELERATORS

---

## Feature support

### Supported special features
- Live Migration: Supported

### Feature limitations
- Premium Storage: Not Supported
- Premium Storage caching: Not Supported
- VM Generation Support: Generation 1
- Accelerated Networking: Supported
- Ephemeral OS Disks: Not Supported
- Nested Virtualization: Not Supported

## Next Steps
- Learn more about how [Azure compute units (ACU)](https://learn.microsoft.com/azure/virtual-machines/acu) can help you compare compute performance across Azure SKUs.
- Check out [Azure Dedicated Hosts](https://learn.microsoft.com/azure/virtual-machines/dedicated-hosts) for physical servers able to host one or more virtual machines assigned to one Azure subscription.
- Learn how to [Monitor Azure virtual machines](https://learn.microsoft.comazure/virtual-machines/monitor-vm)