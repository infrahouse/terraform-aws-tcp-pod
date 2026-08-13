# Troubleshooting

Common issues when deploying and operating the tcp-pod module.

## `terraform apply` Times Out Waiting for Capacity

**Symptom:**

```
Error: waiting for Auto Scaling Group capacity satisfied: timeout while waiting for state
```

Terraform waits until `asg_min_elb_capacity` instances are healthy
(`wait_for_capacity_timeout`, 20 minutes by default). The wait fails when instances never
become healthy.

**Diagnosis:**

1. Check the target group health in the AWS console (EC2 → Target Groups → Targets)
   or via CLI:

    ```bash
    aws elbv2 describe-target-health --target-group-arn <target_group_arn>
    ```

2. If targets are `unhealthy`, the service isn't listening on the target group port.
   SSH to an instance and check:

    ```bash
    sudo ss -tlnp | grep <port>
    sudo cloud-init status --long
    less /var/log/cloud-init-output.log
    ```

**Common causes:**

- The userdata fails or doesn't start the service — check `/var/log/cloud-init-output.log`.
- The service listens on a different port than `target_group_port`
  (which defaults to `nlb_listener_port`).
- The health check port/protocol doesn't match what the service exposes.
- `health_check_grace_period` (15 min by default) is shorter than the time your
  service needs to come up.

## NLB Has the Wrong Scheme (Internal vs Internet-Facing)

The module infers the scheme from `map_public_ip_on_launch` of the **first** subnet in
`var.subnets`:

- Internet-facing NLB: pass public subnets (with `map_public_ip_on_launch = true`).
- Internal NLB: pass private subnets.

If the scheme is wrong, you passed the wrong subnets. Note that changing subnets
recreates the load balancer.

## Cannot Connect Through the NLB

**Checklist:**

1. **DNS**: `dig <service>.<zone>` should return the NLB's IP addresses. Alias records are
   created in the zone `zone_id`; with a split DNS account make sure `aws.dns` points at
   the right one.
2. **Scheme**: an internal NLB is only reachable from inside the VPC (or peered networks).
3. **Security groups**: the NLB security group allows `nlb_listener_port` from
   `0.0.0.0/0`; backends only accept traffic from the NLB security group. If you replaced
   or added groups via `extra_security_groups_backend`, verify the rules.
4. **Health**: an NLB only forwards to healthy targets. See the timeout section above.
5. **Client IP preservation**: NLB target groups with `instance` type preserve the client
   source address. If the service's own firewall (iptables, ufw) filters by source IP,
   allow the expected client ranges.

## SSH to Backend Instances Fails

- From inside the VPC, port 22 is always allowed by the backend security group.
- From outside, set `ssh_cidr_block` to your operator CIDR range — but note the NLB only
  forwards `nlb_listener_port`; SSH access to arbitrary instances needs a jumphost or
  direct network path (VPN, peering).
- If you didn't pass `key_pair_name`, the module generated a fallback key pair. The
  private key is in the Terraform state (`tls_private_key.rsa`). Prefer passing your
  own key pair.

## Instances Are Constantly Replaced

**Possible causes:**

- **Tag-triggered instance refresh**: the ASG rolls instances whenever propagated tags
  change. Provider-level `default_tags` feed into ASG tags too, so account-wide tag
  changes can roll every pod. This is by design — it keeps instances in sync.
- **`max_instance_lifetime_days`**: instances older than 30 days (default) are replaced.
  Raise the value or set it to `0` to disable.
- **Failing ELB health checks** with `health_check_type = "ELB"`: a flapping service
  causes replacement loops. Check the service logs and health check settings.

## `Error: "name_prefix" cannot be longer than 6 characters`

The NLB name prefix is derived from the first 6 characters of `service_name`. If you set
`nlb_name_prefix` yourself, keep it at 6 characters or fewer (the module truncates
`service_name`-derived prefixes automatically).

## Deletion Protection Blocks `terraform destroy`

If `enable_deletion_protection = true`, disable it first:

```hcl
  enable_deletion_protection = false
```

Apply, then destroy.

## Spot Capacity Not Available

With `on_demand_base_capacity` set, the ASG requests spot instances above the base. If a
spot pool dries up, the ASG may fail to reach the desired capacity. Consider more
instance-type-diverse subnets/AZs, or raise `on_demand_base_capacity`.

## Provider Version Conflicts

The module supports AWS provider `>= 5.11, < 7.0`. If your root module pins an
incompatible version, `terraform init` fails with a constraint error. Align the root
module's `required_providers` with the supported range.

## Getting Help

- [Open an issue](https://github.com/infrahouse/terraform-aws-tcp-pod/issues)
- [Contact InfraHouse](https://infrahouse.com/contact)
