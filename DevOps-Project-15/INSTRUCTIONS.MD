# Step-by-Step Instructions

Follow these steps to recreate the automated CI/CD pipeline for this project.

## Prerequisites
* An AWS Account
* A DockerHub Account
* A free API key from TMDB (The Movie Database)

## Phase 1: Source Control Setup
1. Open the **AWS IAM Console**, create a user, and attach the `AWSCodeCommitPowerUser` policy.
2. Generate SSH keys locally (`ssh-keygen`) and upload the public key to your IAM user's "Security credentials" tab.
3. Go to **AWS CodeCommit** and create a repository named `netflix-app-repo`.
4. Add the AWS SSH clone URL as a remote to your local project: `git remote add aws <SSH_URL>`.
5. Push your code: `git push -u aws main`.

## Phase 2: Build Automation (CI)
1. Store your secrets securely in **AWS Systems Manager (SSM) Parameter Store** as `SecureString`:
   * `/myapp/docker-credentials/username`
   * `/myapp/docker-credentials/password`
   * `/myapp/api/key`
2. Go to **AWS CodeBuild** and create a new project named `netflix-build`.
3. Select your CodeCommit repo as the source. Choose an **Ubuntu Standard** managed image and check the **Privileged** box (required to build Docker images).
4. Go to **IAM Roles**, find the newly created CodeBuild service role, and attach an inline policy allowing `ssm:GetParameters` so it can read your secrets.
5. Ensure your `buildspec.yml` logs into DockerHub during the `pre_build` phase to avoid rate limits.

## Phase 3: Server Provisioning
1. Go to **IAM** and create an EC2 service role with `AmazonS3FullAccess` and `AmazonEC2RoleforAWSCodeDeploy`.
2. Go to **EC2** and launch a new `t2.micro` Ubuntu instance.
3. Name it exactly `Netflix-Web-Server` (Tags are case-sensitive!).
4. Attach the IAM role you just created.
5. In the "User data" section, paste a bash script to automatically install **Docker** and the **CodeDeploy Agent** upon launch.
6. Edit the instance's **Security Group** to allow Custom TCP inbound traffic on port `8080`.

## Phase 4: Deployment Automation (CD)
1. Go to **IAM** and create a service role specifically for the **CodeDeploy** use-case.
2. Go to **AWS CodeDeploy** and create an Application named `netflix-app`.
3. Create a **Deployment Group** within that application.
4. Select "Amazon EC2 instances" and use the tag `Name: Netflix-Web-Server` to target your server.
5. Disable load balancing (for a single-server setup).

## Phase 5: Pipeline Orchestration
1. Go to **AWS CodePipeline** and create a new pipeline.
2. **Source Stage:** Select AWS CodeCommit and your repository branch.
3. **Build Stage:** Select AWS CodeBuild and your `netflix-build` project.
4. **Deploy Stage:** Select AWS CodeDeploy, your application, and your deployment group.
5. Save and run the pipeline. 

Once the deployment stage turns green, visit your EC2 instance's Public IPv4 address on port 8080 (e.g., `http://YOUR_IP:8080`) to view the live application!

---
**Cleanup Note:** Don't forget to terminate your EC2 instance, delete your S3 artifact buckets, and remove the CodePipeline to avoid unwanted AWS charges!