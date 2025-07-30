instance_type = "m7i.xlarge"      # Power User: 4 vCPUs, 16 GB RAM, Intel Xeon (i7-class) — approx. $0.336/hr → ₱12,240/mo

/*
Change Quotas:
    Instance pricing:
        https://aws.amazon.com/ec2/pricing/on-demand/
        https://instances.vantage.sh/
    https://us-east-2.console.aws.amazon.com/servicequotas/home/services/ec2/quotas

    Set quota to 200

Instances for Video 🎬: Hollywood-Grade Video Production & VFX Rendering:

    g4dn.medium     # Entry-Level Streaming & Transcoding: Great for testing, low-cost live stream pipelines, or preview rendering
    g4dn.xlarge     # Real-Time Video Encoding: Good for 1080p/4K encoding, cloud-based video editing, and game streaming setups
    g5.12xlarge     # VFX & Batch Rendering Node: Multi-GPU setup for rendering animations, visual effects, and 4K/8K editing
    g5.48xlarge     # Studio-Grade Render Farm Head: High-end render jobs, Unreal Engine builds, multi-stream 8K processing

Instances for AI 🤖: High-Performance Computing for Parallel Machine Learning Training:

    g4dn.xlarge     # Balanced Dev & Inference: Cost-effective entry point for ML model training, fine-tuning, and inference
    g5.12xlarge     # Mid-Scale AI Training: Multi-GPU A10G setup for larger models or batch inference
    p4d.24xlarge    # Large-Scale AI Training: 8×A100 GPUs, suitable for deep learning and large-scale parallel training
    p5.48xlarge     # Extreme AI Training: 8×H100 GPUs, optimal for LLMs, massive datasets, and top-tier AI workloads

GPU-Enabled Instances:

    instance_type = "g4dn.medium"     # Entry GPU Node: 2 vCPUs, 8 GB RAM, 1×NVIDIA T4 GPU (16 GB) — ₱14/hr → ₱10,300/mo
    instance_type = "g4dn.xlarge"     # ⭐ Lenovo Legion Equivalent ⭐ - GPU-Powered Power User: 4 vCPUs, 16 GB RAM, 1×NVIDIA T4 GPU (16 GB) — ₱30/hr → ₱21,800/mo
    instance_type = "g5.12xlarge"     # VFX Rendering: 48 vCPUs, 192 GB RAM, 4×NVIDIA A10G GPUs (24 GB each) — ₱323/hr → ₱235,800/mo
    instance_type = "g5.48xlarge"     # Studio Node: 192 vCPUs, 768 GB RAM, 8×NVIDIA A10G GPUs (24 GB each) — ₱1,293/hr → ₱942,000/mo
    instance_type = "p4d.24xlarge"    # Neural Renderer: 96 vCPUs, 1.1 TB RAM, 8×NVIDIA A100 GPUs (40 GB each) — ₱1,868/hr → ₱1.36 M/mo
    instance_type = "p5.48xlarge"     # Hollywood-Grade: 192 vCPUs, 1.9 TB RAM, 8×NVIDIA A100 GPUs (80 GB each) — ₱3,705/hr → ₱2.70 M/mo

Non-GPU Instances:

    instance_type = "t3.small"        # Budget: 2 vCPUs, 2 GB RAM, Intel/AMD x86 — ₱1.19/hr → ₱867/mo
    instance_type = "t3.medium"       # Best Balance: 2 vCPUs, 4 GB RAM, x86 — ₱2.37/hr → ₱1,730/mo
    instance_type = "c5ad.large"      # Budget Compute Node: 2 vCPUs, 4 GB RAM — ₱4.90/hr → ₱3,577/mo
    instance_type = "m7i.xlarge"      # Power User: 4 vCPUs, 16 GB RAM, Intel Xeon (i7-class) — ₱11.49/hr → ₱8,390/mo
    instance_type = "m7i.2xlarge"     # Advanced User: 8 vCPUs, 32 GB RAM — ₱38.30/hr → ₱27,960/mo
    instance_type = "c7i.2xlarge"     # High Performance: 8 vCPUs, 16 GB RAM — ₱40.11/hr → ₱29,280/mo
    instance_type = "r7i.xlarge"      # Memory Optimized: 4 vCPUs, 32 GB RAM — ₱28.73/hr → ₱20,970/mo
    instance_type = "m7i.4xlarge"     # Power Developer: 16 vCPUs, 64 GB RAM — ₱76.06/hr → ₱55,530/mo
    instance_type = "c7i.4xlarge"     # Compute Heavy: 16 vCPUs, 32 GB RAM — ₱80.83/hr → ₱58,010/mo
    instance_type = "r7i.4xlarge"     # Data Cruncher: 16 vCPUs, 128 GB RAM — ₱57.46/hr → ₱41,940/mo
    instance_type = "m7i.8xlarge"     # Elite Workstation: 32 vCPUs, 128 GB RAM — ₱152.13/hr → ₱110,980/mo

Instances for RDS 🛢: Amazon Relational Database Service (Production-Ready Only)

General Purpose (Balanced CPU/Memory):
    instance_type = "db.t3.small"     # Entry-Level Production DB: 2 vCPUs, 2 GB RAM — ₱2.37/hr → ₱1,730/mo
    instance_type = "db.t3.medium"    # Small Production DB: 2 vCPUs, 4 GB RAM — ₱4.75/hr → ₱3,470/mo
    instance_type = "db.m5.large"     # Balanced Production DB: 2 vCPUs, 8 GB RAM — ₱13.49/hr → ₱9,850/mo
    instance_type = "db.m5.xlarge"    # Mid-Sized Production DB: 4 vCPUs, 16 GB RAM — ₱26.98/hr → ₱19,700/mo
    instance_type = "db.m6g.large"    # Graviton2 Balanced DB: 2 vCPUs, 8 GB RAM (ARM) — ₱12.07/hr → ₱8,800/mo

Memory Optimized (High RAM Workloads):
    instance_type = "db.r5.large"     # Memory-Optimized DB: 2 vCPUs, 16 GB RAM — ₱18.24/hr → ₱13,320/mo
    instance_type = "db.r5.xlarge"    # Memory-Optimized DB: 4 vCPUs, 32 GB RAM — ₱36.48/hr → ₱26,640/mo
    instance_type = "db.r6g.large"    # Graviton2 Memory-Optimized DB: 2 vCPUs, 16 GB RAM (ARM) — ₱16.41/hr → ₱11,980/mo
    instance_type = "db.r6i.large"    # Intel Memory-Optimized DB: 2 vCPUs, 16 GB RAM — ₱17.67/hr → ₱12,900/mo

Extreme Memory (Enterprise/Heavy Analytics):
    instance_type = "db.x2g.large"    # Extreme Memory Graviton2 DB: 2 vCPUs, 32 GB RAM — ₱44.65/hr → ₱32,590/mo
    instance_type = "db.x2g.xlarge"   # Extreme Memory Graviton2 DB: 4 vCPUs, 64 GB RAM — ₱89.30/hr → ₱65,180/mo
    instance_type = "db.x2iedn.xlarge"# Extreme Memory Intel DB: 4 vCPUs, 128 GB RAM — ₱121.98/hr → ₱89,050/mo
*/

disk_size     = "75" # 10GB
volume_type   = "gp3"

db_name = "app_db"
db_username = "root"
db_password = "password"