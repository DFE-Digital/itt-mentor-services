OkComputer.mount_at = "healthcheck"

OkComputer::Registry.register "database", OkComputer::ActiveRecordCheck.new
