instance_type = "m7i.xlarge"      # Power User: 4 vCPUs, 16 GB RAM, Intel Xeon (i7-class) — approx. $0.336/hr → ₱12,240/mo

# instance_type = "m7i.xlarge"      # Power User: 4 vCPUs, 16 GB RAM, Intel Xeon (i7-class) — approx. $0.336/hr → ₱12,240/mo
# instance_type = "m7i.2xlarge"     # Advanced User: 8 vCPUs, 32 GB RAM — approx. $0.672/hr → ₱24,480/mo
# instance_type = "c7i.2xlarge"     # High Performance: 8 vCPUs, 16 GB RAM — approx. $0.709/hr → ₱25,800/mo
# instance_type = "r7i.xlarge"      # Memory Optimized: 4 vCPUs, 32 GB RAM — approx. $0.504/hr → ₱18,360/mo
# instance_type = "m7i.4xlarge"     # Power Developer: 16 vCPUs, 64 GB RAM — approx. $1.344/hr → ₱49,000/mo
# instance_type = "c7i.4xlarge"     # Compute Heavy: 16 vCPUs, 32 GB RAM — approx. $1.418/hr → ₱51,700/mo
# instance_type = "r7i.4xlarge"     # Data Cruncher: 16 vCPUs, 128 GB RAM — approx. $1.008/hr → ₱36,800/mo
# instance_type = "m7i.8xlarge"     # Elite Workstation: 32 vCPUs, 128 GB RAM — approx. $2.688/hr → ₱98,000/mo
# instance_type = "g5.12xlarge"     # VFX Rendering: 48 vCPUs, 192 GB RAM, 4×A10G GPUs — $5.672/hr → ₱412,000/mo
# instance_type = "g5.48xlarge"     # Studio Node: 192 vCPUs, 768 GB RAM, 8×A10G — ~$22.688/hr → ₱1.30 M/mo
# instance_type = "p4d.24xlarge"    # Neural Renderer: 96 vCPUs, 1.1 TB RAM, 8×A100 GPUs — ~$32.77/hr → ₱1.87 M/mo
# instance_type = "p5.48xlarge"     # Hollywood-Grade: 192 vCPUs, 1.9 TB RAM, A100 80 GB GPUs — ~$65/hr → ₱3.71 M/mo

disk_size     = "75" # 10GB
volume_type   = "gp3"

db_name = "app_db"
db_username = "root"
db_password = "password"