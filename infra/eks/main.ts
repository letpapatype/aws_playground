import * as cdk from '@aws-cdk-lib/core';
import * as ec2 from '@aws-cdk-lib/aws-ec2';
import * as eks from '@aws-cdk-lib/aws-eks';
import * as efs from '@aws-cdk-lib/aws-efs';

class EksClusterStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Define the VPC
    const vpc = new ec2.Vpc(this, 'VPC', {
      cidr: '192.168.0.0/16',
      maxAzs: 2,
      subnetConfiguration: [
        {
          cidrMask: 18,
          name: 'PublicSubnet',
          subnetType: ec2.SubnetType.PUBLIC,
        },
        {
          cidrMask: 18,
          name: 'PrivateSubnet',
          subnetType: ec2.SubnetType.PRIVATE_WITH_NAT,
        },
      ],
    });

    // create a security group for the EFS mount targets with ingreee to port 2049  
    const efsSecurityGroup = new ec2.SecurityGroup(this, 'EfsSecurityGroup', {
      vpc: vpc,
    });

    efsSecurityGroup.addIngressRule(ec2.Peer.ipv4(vpc.vpcCidrBlock), ec2.Port.tcp(2049), 'allow NFS traffic from within the VPC');

    // Create an EFS file system in the VPC along with mount targets in the private subnets
    const fileSystem = new efs.FileSystem(this, 'FileSystem', {
      vpc: vpc,
      securityGroup: efsSecurityGroup,
      lifecyclePolicy: efs.LifecyclePolicy.AFTER_14_DAYS,
    });

    const mountTargets = vpc.privateSubnets.map((subnet, idx) => {
      return new efs.CfnMountTarget(this, `MountTarget-${idx}`, {
        fileSystemId: fileSystem.fileSystemId,
        subnetId: subnet.subnetId,
        securityGroups: [efsSecurityGroup.securityGroupId],
      });
    });

    // create an access point for the EFS file system with the root dir path set to --root-directory "Path=/jenkins,CreationInfo={OwnerUid=1000,OwnerGid=1000,Permissions=777}"
    const accessPoint = new efs.AccessPoint(this, 'AccessPoint', {
      fileSystem: fileSystem,
    }




    // Create an EKS cluster
    const cluster = new eks.Cluster(this, 'eks-ci-cd', {
      clusterName: 'eks-ci-cd',
      version: eks.KubernetesVersion.V1_21,
      vpc: vpc,
      vpcSubnets: [{ subnetType: ec2.SubnetType.PRIVATE_WITH_NAT }],
      defaultCapacity: 0, // we want to manage capacity ourselves
    });

    // Define node group on-demand
    cluster.addNodegroupCapacity('ng-on-demand', {
      nodegroupName: 'ng-on-demand',
      instanceType: new ec2.InstanceType('t3.large'),
      minSize: 1,
      desiredCapacity: 1,
      maxSize: 1,
      labels: { 'instance-type': 'on-demand' },
      subnets: { subnetType: ec2.SubnetType.PRIVATE_WITH_NAT },
    });

    // Define node group spot
    cluster.addNodegroupCapacity('ng-spot', {
      nodegroupName: 'ng-spot',
      instanceTypes: [
        new ec2.InstanceType('m5.large'),
        new ec2.InstanceType('m4.large'),
        new ec2.InstanceType('t3.large'),
        new ec2.InstanceType('m5d.large'),
        new ec2.InstanceType('m5ad.large'),
        new ec2.InstanceType('t3a.large'),
      ],
      minSize: 0,
      desiredCapacity: 0,
      maxSize: 10,
      labels: { 'instance-type': 'spot' },
      subnets: { subnetType: ec2.SubnetType.PRIVATE_WITH_NAT },
    });

    // Output the cluster name
    new cdk.CfnOutput(this, 'ClusterName', {
      value: cluster.clusterName,
    });
  }
}

const app = new cdk.App();
new EksClusterStack(app, 'EksClusterStack');