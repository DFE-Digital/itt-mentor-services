OkComputer.mount_at = "healthcheck"

OkComputer::Registry.register "database", OkComputer::ActiveRecordCheck.new
OkComputer::Registry.register "Commit SHA", OkComputer::AppVersionCheck.new
