# s6-openrc-compat

A compatibility layer for running Alpine Configuration Framework (ACF) or other OpenRC-dependent tools within an s6-overlay supervised container.

This module provides stubs for `rc-service`, `rc-update`, and `rc-status` that map OpenRC commands to `s6-svc` and `s6-svstat` commands.

## Features

- **rc-service stub**: Supports `start`, `stop`, `restart`, and `status`. Handles `crond` specifically even if not supervised by s6.
- **rc-status stub**: Provides a bird's-eye view of all s6 services in OpenRC format.
- **rc-update stub**: Simulates runlevel management for package compatibility.
- **s6-dumpenv**: Exports s6 container environment variables for use by cron jobs.
- **Initialization script**: Automatically creates `/etc/init.d` wrappers for all s6 services.
- **crond template**: A ready-to-use s6 service definition for running `crond` in the foreground.

## Installation

```bash
make
sudo make install
```

### Configuration

Customize installation paths in `config.mk` or via `make` variables:

```bash
make PREFIX=/usr BINDIR=/usr/bin install
```

## Usage

### 1. Initialize OpenRC compatibility
Run this during container start-up (e.g., in `cont-init.d`):
```bash
/usr/local/bin/init-openrc-compat.sh
```

### 2. Use with Cron
To allow cron jobs to access container environment variables (like those from Docker or Home Assistant):

1. Run `s6-dumpenv` during initialization.
2. Source `/etc/environment.s6` in your cron scripts:
   ```bash
   #!/bin/sh
   . /etc/environment.s6
   # now you can use $MY_VARIABLE
   ```

3. Use the provided `templates/crond` to ensure `crond` is supervised by s6.

## ACF Compatibility
This module is specifically designed to prevent "popen failed" errors in ACF Lua modules by providing valid responses to service status queries.
