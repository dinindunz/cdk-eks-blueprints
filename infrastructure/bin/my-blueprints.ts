import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import * as blueprints from '@aws-quickstart/eks-blueprints';
import {InstanceType} from 'aws-cdk-lib/aws-ec2';
import * as eks from 'aws-cdk-lib/aws-eks';
import { version } from 'yargs';
import { UpdatePolicy } from 'aws-cdk-lib/aws-autoscaling';
import { DatadogAddOn } from '@datadog/datadog-eks-blueprints-addon';

const app = new cdk.App();
const vars = app.node.tryGetContext('act');
const env = {account: vars['aws-account-id'], region: vars['aws-region']};

const addOns: Array<blueprints.ClusterAddOn> = [
    new blueprints.addons.ArgoCDAddOn,
    new blueprints.addons.CalicoAddOn,
    new blueprints.addons.MetricsServerAddOn,
    new blueprints.addons.ClusterAutoScalerAddOn,
    new blueprints.addons.ContainerInsightsAddOn,
    new blueprints.addons.AwsLoadBalancerControllerAddOn(),
    new blueprints.addons.VpcCniAddOn(),
    new blueprints.addons.CoreDnsAddOn(),
    new blueprints.addons.KubeProxyAddOn(),
    new blueprints.addons.XrayAddOn(),
    new DatadogAddOn({
        apiKeyExistingSecret: 'datadog'
    })
];

const props: blueprints.AsgClusterProviderProps = {
    minSize: 1,
    maxSize: 10,
    desiredSize: 2,
    instanceType: new InstanceType('t3.large'),
    machineImageType: eks.MachineImageType.AMAZON_LINUX_2,
    updatePolicy: UpdatePolicy.rollingUpdate(),
    version: eks.KubernetesVersion.V1_21,
    id: 'worker_nodes'
}

const clusterProvider = new blueprints.AsgClusterProvider(props);

blueprints.EksBlueprint.builder()
    .account(env.account)
    .region(env.region)
    .clusterProvider(clusterProvider)
    .addOns(...addOns)
    .build(app, 'eks-blueprint');