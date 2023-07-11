# Device Edge Demos

This repo should be used in conjunction with the [Device Edge Workshops](https://github.com/redhat-manufacturing/device-edge-workshops) to demonstrate and educate people on Device Edge.

This repo is a WIP, do not expect anything to work.

## Getting Started - Bastion Host

To execute the various starting workflows requires a Bastion Host/Jump Box to run Ansible Navigator.

You can use any RHEL 8.x compatible system and run:

```bash
curl -sSL https://raw.githubusercontent.com/kenmoini/device-edge-demos/main/hack/setup-bastion.sh | bash -
```