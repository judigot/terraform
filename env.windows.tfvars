instance_type = "m7i.xlarge"      # Power User: 4 vCPUs, 16 GB RAM, Intel Xeon (i7-class) — approx. $0.336/hr → ₱12,240/mo

/*
Change Quotas:
    https://us-east-2.console.aws.amazon.com/servicequotas/home/services/ec2/quotas

    Set quota to 200

    "Running On-Demand G and VT instances"
        g4dn.medium
        g4dn.xlarge
        g5.12xlarge
        g5.48xlarge

    "Running On-Demand P instances"
        p4d.24xlarge
        p5.48xlarge

Instances for AI 🤖:
    g4dn.xlarge

GPU-Enabled Instances:

    instance_type = "g4dn.medium"     # Entry GPU Node: 2 vCPUs, 8 GB RAM, 1×NVIDIA T4 GPU (16 GB) — ~$0.252/hr → ₱9,000/mo
    instance_type = "g4dn.xlarge"     # ⭐ Lenovo Legion Equivalent ⭐ - GPU-Powered Power User: 4 vCPUs, 16 GB RAM, 1×NVIDIA T4 GPU (16 GB) — ~$0.526/hr → ₱19,000/mo
    instance_type = "g5.12xlarge"     # VFX Rendering: 48 vCPUs, 192 GB RAM, 4×NVIDIA A10G GPUs (24 GB each) — $5.672/hr → ₱412,000/mo
    instance_type = "g5.48xlarge"     # Studio Node: 192 vCPUs, 768 GB RAM, 8×NVIDIA A10G GPUs (24 GB each) — ~$22.688/hr → ₱1.30 M/mo
    instance_type = "p4d.24xlarge"    # Neural Renderer: 96 vCPUs, 1.1 TB RAM, 8×NVIDIA A100 GPUs (40 GB each) — ~$32.77/hr → ₱1.87 M/mo
    instance_type = "p5.48xlarge"     # Hollywood-Grade: 192 vCPUs, 1.9 TB RAM, 8×NVIDIA A100 GPUs (80 GB each) — ~$65/hr → ₱3.71 M/mo

Non-GPU Instances:

    instance_type = "c5ad.large"      # Budget Compute Node: 2 vCPUs, 4 GB RAM — ~$0.086/hr → ₱3,100/mo
    instance_type = "m7i.xlarge"      # Power User: 4 vCPUs, 16 GB RAM, Intel Xeon (i7-class) — ~$0.336/hr → ₱12,240/mo
    instance_type = "m7i.2xlarge"     # Advanced User: 8 vCPUs, 32 GB RAM — ~$0.672/hr → ₱24,480/mo
    instance_type = "c7i.2xlarge"     # High Performance: 8 vCPUs, 16 GB RAM — ~$0.709/hr → ₱25,800/mo
    instance_type = "r7i.xlarge"      # Memory Optimized: 4 vCPUs, 32 GB RAM — ~$0.504/hr → ₱18,360/mo
    instance_type = "m7i.4xlarge"     # Power Developer: 16 vCPUs, 64 GB RAM — ~$1.344/hr → ₱49,000/mo
    instance_type = "c7i.4xlarge"     # Compute Heavy: 16 vCPUs, 32 GB RAM — ~$1.418/hr → ₱51,700/mo
    instance_type = "r7i.4xlarge"     # Data Cruncher: 16 vCPUs, 128 GB RAM — ~$1.008/hr → ₱36,800/mo
    instance_type = "m7i.8xlarge"     # Elite Workstation: 32 vCPUs, 128 GB RAM — ~$2.688/hr → ₱98,000/mo
*/

disk_size     = "75" # 10GB
volume_type   = "gp3"

db_name = "app_db"
db_username = "root"
db_password = "password"