# How to auto deploy with Bitbucket Pipelines and AWS CodeDeploy?

### **Step by step guide on how to auto deploy your app:** 
**Prerequisites:** 
- BitBucket Repository
- AWS Account
- Putty

### **STEP 1. Create New IAM User**
Login to your AWS account. Visit https://console.aws.amazon.com/iam/

Users > Add User > enter username > check box both Access type > choose “Custom Password” radio > Uncheck “Require password reset” > Click Next: Permissions> Attach existing policies directly >
search for “s3” and select AmazonS3FullAccess

---
![Alt text](readme_images/1.png? "Optional Title")
---

Attach Existing Policies- search for “codedeploy” and select AmazonEC2RoleforAWSCodeDeploy, AWSCodeDeployDeployerAccess, AWSCodeDeployFullAccess, AWSCodeDeployRole

---
![Alt text](readme_images/2.png? "Optional Title")
---

Next: Review > Create user-**IMPORTANT NOTE:** 
**1. Download CSV**
**2. Note Down Access Key ID**
**3. Note Down Secret access key**

---
![Alt text](readme_images/5.png? "Optional Title")
---

### STEP 2. Create Role for CodeDeploy Application
Its is service role for Code Deploy. This service role you assign to the code deploy application that you will create in the later steps.

Login to your AWS account. Visit https://console.aws.amazon.com/iam/

Roles > Create Role > click AWS service > 

---
![Alt text](readme_images/6.png? "Optional Title")
---

Below Select CodeDeploy > 

---
![Alt text](readme_images/7.png? "Optional Title")
---

Next: permissions > Next Review > enter Role name (e.g CodeDeployServiceRole) > enter description (not compulsory) > Create role.


### STEP 3. Create Role for EC2 instance
This is the role which is assigned to EC2 instance which you will create later steps.

Login to your AWS account. Visit https://console.aws.amazon.com/iam/

**Step A. Create Policy for this Role.**
Policies > Create Policy > Select Create Your Own Policy > Policy Name: “CodeDeploy-EC2-Permissions” > Description: “policy for role which is assigned to EC2 instance” > Policy Document: Paste the following in the input box.

> {“Version”: “2012–10–17”,“Statement”: [{“Action”: [“s3:Get*”,“s3:List*”],“Effect”: “Allow”,“Resource”: “*”}]}

---
![Alt text](readme_images/8.png? "Optional Title")
---

Validate Policy > Create Policy.

**Step B: Create Role**
Roles > Create Role > AWS service > EC2 > Select your use case > Click EC2 > Next: Permissions > search for “ec2” and select the “CodeDeploy-EC2-Permissions” which you created in Step A > 

---
![Alt text](readme_images/9.png? "Optional Title")
---

Next: Review > Name: “CodeDeploy-EC2-Instance-Profile” > Role Description: “CodeDeploy-EC2-Instance-Profile” > Create Role


### STEP 4. Create EC2 Instance.
Login to your AWS Account.
Services > EC2 > Launch Instance > Amazon Linux AMI (or choose as per your need) > Choose an instance type > Next: Configure Instance Details > IAM role > from drop down select the role that you created in Step 3 Step B (CodeDeploy-EC2-Instance-Profile) > 

---
![Alt text](readme_images/10.png? "Optional Title")
---

Next: Add Storage > Next: Add Tags > Add Tag > (Important step!! note down name & key you assign) Input Key: Name, Value: staging-auto-deploy (or anything you prefer) > 

---
![Alt text](readme_images/11.jpeg? "Optional Title")
---

Next: Configure Security Group > select existing security group or create new > Review and Launch > Launch > Select existing key pair or create new > Launch Instances > View Instances > Note down IPv4 Public IP


### STEP 5. Install CodeDeploy Agent on EC2 instance
Open Putty on your local machine > Enter the Public IP that you got in Step 4 > Port 22 > In Connection > SSH > Auth > Private key file for authentication> browse> link the key pair file for your instance in step 4 > open > login as: enter your username
> Now install CodeDeploy agent as per your instance type

> Linux Server: http://docs.aws.amazon.com/codedeploy/latest/userguide/codedeploy-agent-operations-install-linux.html

> Ubuntu Server: http://docs.aws.amazon.com/codedeploy/latest/userguide/codedeploy-agent-operations-install-ubuntu.html

> Windows Server: http://docs.aws.amazon.com/codedeploy/latest/userguide/codedeploy-agent-operations-install-windows.html

> Verify that agent is running.

---
![Alt text](readme_images/12.png? "Optional Title")
---

### STEP 6. Add CodeDeploy Addon on BitBucket
Login to your BitBucket Account
Integrations > Search AWS CodeDeploy > Add AWS CodeDeploy

---
![Alt text](readme_images/13.png? "Optional Title")
---

### STEP 7. Create CodeDeploy Application on AWS
Login to your AWS Account.
Services > search CodeDeploy > select CodeDeploy > If this is your first time select “get started now” or Create Application > Custom deployment > skip walkthrough > enter details >
Application Name: staging-deployment (Important: note it down)
Deployment group name: staging-deployment (Important: note it down)
Select “In-place deployment”
Environment configuration > Amazon EC2 isntance > Key: Name, Value: staging-auto-deploy (these are the key, value which you created when you created instance in Step 4) > 

---
![Alt text](readme_images/14.png? "Optional Title")
---

Deployment Configuration > CodeDeployDefault.OneAtTime > Service Role ARN: select the role that you created in step 2 (CodeDeployServiceRole) > 

---
![Alt text](readme_images/15.png? "Optional Title")
---

Create Application


### STEP 8. Create S3 volume
Login to your AWS account > Services > S3 > Create bucket > Bucket name: staging-deployment-bucket > Create


### STEP 9. CodeDeploy settings for Repository
Login to your repo > Settings > CodeDeploy Settings > Configure add-on > Follow the on screen instructions

**Step A**
Login to your AWS account > Services > IAM > Policy > Create Policy > Create Your Own Policy > (This policy is created for bitbucket code deploy add on, use this to create role for bitbucket codeDeploy addon)
Policy Name: BitBucketCodeDeployAddOnPolicy
Policy Document: paste following into input box
>{“Version”: “2012–10–17”,”Statement”: [{“Effect”: “Allow”,”Action”: [“s3:ListAllMyBuckets”,”s3:PutObject”],”Resource”: “arn:aws:s3:::*”},{“Effect”: “Allow”,”Action”: [“codedeploy:*”],”Resource”: “*”}]}

Create Policy

**Step B**
Login to your AWS account > Services > IAM > Roles > create role > another AWS account > 

---
![Alt text](readme_images/16.png? "Optional Title")
---

account ID: copy paste the AWS Account ID given on the bitbucket codeDeploy on screen instruction > check require external ID checkbox then: copy paste the External ID given on the bitbucket codeDeploy on screen instruction > 

---
![Alt text](readme_images/17.png? "Optional Title")
---
![Alt text](readme_images/18.png? "Optional Title")
---

next: Permissions > Attach permissions policies > search for policy that you created in step A > next: review
**Roll name**: "BitbucketCodeDeployAddon" > Create role
click on the role you just created and copy Role ARN and paste it into “Your Role ARN” on bitbucket code deploy settings page > click save & continue
On next page Application: select CodeDeploy Application that you created in step 7 > S3 Bucket: select S3 bucket that you created in step 8 > save


### STEP 10. Enable Bitbucket pipeline
Login to your BitBucket account Repo Settings > Pipelines > settings > Turn on Enable pipeline


**For Steps 11, 12, 13 & 14, required files are available for reference at Source of this repo: https://bitbucket.org/bhushanTPL/bitbucket-pipeline-and-aws-codedeploy**

### STEP 11. Create bitbucket-pipelines.yml
Copy bitbucket-pipelines.yml file.(make changes to this file as per your project requirement)
Add this file to root of your project.

**Docs**: https://confluence.atlassian.com/bitbucket/configure-bitbucket-pipelines-yml-792298910.html?_ga=2.162970750.315484667.1509451697-1615374000.1508921669#Configurebitbucket-pipelines.yml-ci_imageimage(optional)


### STEP 12. Create codedeploy_deploy.py
Copy codedeploy_deploy.py file.
Add this file to root of you your project.

**Docs & Source**: https://bitbucket.org/awslabs/aws-codedeploy-bitbucket-pipelines-python


### STEP 13. Create appspec.yml 
Go to Source of this repo: https://bitbucket.org/bhushanTPL/bitbucket-pipeline-and-aws-codedeploy
and copy ***appspec.yml*** file. (make changes to this file as per your project requirement)
Add it to root of your project.

**Docs**: http://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html


### STEP 14. Create scripts
Create scripts folder at root of your project 
> Create startApp.sh file in the scripts folder in root of your projects, which will run commands after your build is transferred to your EC2 instance.


### STEP 15. Add Environment variables
Login to your BitBucket account > your Repo Settings > Environment Variables
Add the following environment variables
>AWS_SECRET_ACCESS_KEY: Secret key for a user with the required permissions.

> AWS_ACCESS_KEY_ID: Access key for a user with the required permissions.

> AWS_DEFAULT_REGION: Region where the target AWS CodeDeploy application is.

> APPLICATION_NAME: Name of AWS CodeDeploy application.

> DEPLOYMENT_CONFIG: AWS CodeDeploy Deployment Configuration (CodeDeployDefault.OneAtATime|CodeDeployDefault.AllAtOnce|CodeDeployDefault.HalfAtATime|Custom).

> DEPLOYMENT_GROUP_NAME: Name of the Deployment group in the application.

> S3_BUCKET: Name of the S3 Bucket where source code to be deployed is stored.

**Docs & Ref**: https://bitbucket.org/awslabs/aws-codedeploy-bitbucket-pipelines-python

---
You have now configured all the required steps. Now when you commit and push your changes to your branch the auto deployment process starts. Note that in the following bitbucket-pipeline.yml configuration deployment process will start whenever you push your changes to “staging” branch.

---
![Alt text](readme_images/19.png? "Optional Title")
---

You can check progress of your pipeline by clicking on Pipelines in your repo.

---
![Alt text](readme_images/20.png? "Optional Title")
---

You can view deployment related logs. For more info visit : http://docs.aws.amazon.com/codedeploy/latest/userguide/deployments-view-logs.html

You can monitor deployments from AWS, Login to your AWS account, Services > CodeDeploy > Deployments.
