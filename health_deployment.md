# Health Deployment Requirements

Temporary implementation checklist for the Protectorate Health feature.

These requirements will be incorporated into `install.sh` after Health
development is complete.

## Runtime Dependencies

- [ ] `python3` — required by the Health receiver.
- [ ] `curl` — required by the Health publisher.
- [ ] `jq` — required by the Registry subsystem.

## Runtime Components

- [ ] `protectorate-health-collect`
- [ ] `protectorate-health-publish`
- [ ] `protectorate-health-receive`
- [ ] Provision `/var/cache/protectorate/health/reports` for received node reports.

## Configuration

- [ ] Health publication endpoint.
- [ ] Health receiver listen port.

## systemd

- [ ] Install and enable Health collector service/timer.
- [ ] Install and enable Health publisher service/timer.
- [ ] Install and enable Health receiver service.

## Final Deployment Pass

- [ ] Update `install.sh` with all Health deployment requirements.
- [ ] Remove this temporary checklist after deployment integration is complete.
- [ ] Add Python syntax highlighting to the deployed Protectorate `nanorc`.
