# Tutorial

[www.youtube.com/watch?v=iRaai1IBlB0](https://www.youtube.com/watch?v=iRaai1IBlB0)

[www.youtube.com/watch?v=rwel5eSm89g](https://www.youtube.com/watch?v=rwel5eSm89g)

# Description

AWS EC2 instance pre-installed with Docker

# Set up
1. Add a credentials file and place it in C:/Users/**username**/.aws
    ```
    # AWS credentials file used by AWS CLI, SDKs, and tools.
    # Created by AWS Toolkit for VS Code. https://aws.amazon.com/visualstudiocode/
    #
    # Each [section] in this file declares a named "profile", which can be selected
    # in tools like AWS Toolkit to choose which credentials you want to use.
    #
    # See also:
    #   https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html
    #   https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html

    [default]
    # This key identifies your AWS account.
    # Treat this secret key like a password. Never share it or store it in source
    # control. If your secret key is ever disclosed, immediately use IAM to delete
    # the key pair and create a new one.
    ```

2. Reference it in **providers.tf**
    ```
    provider "aws" {
        region = "us-east-2"
        shared_config_files      = ["~/.aws/conf"]
        shared_credentials_files = ["~/.aws/credentials"]
        profile                  = "default" # [default] profile name contained in ~/.aws/credentials
    }
    ```

3. Project Bootstrapping

    The `init.sh` script automates initial setup and configuration tasks on EC2 instances, ensuring consistent and efficient environment preparation following instance launch.