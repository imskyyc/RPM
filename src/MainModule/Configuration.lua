return {
    framework = { --// Framework behavior configuration
        debug = true, --// Determines if extra debug info will be printed to the console

        prevent_multiple_instances = true, --// Determines if RPM will fail to load if a different version of the framework is
                                           --// Already running

        error_handling = {
            output_to_console = true, --// Determines if errors will be output to the console

            mode = "rpm", --// Supports built in RPM error logging with panel, or sentry

            rpm_api_key = "", --// Your RPM Panel API Key
            sentry_dsn = "" --// Sentry DSN for sentry logging
        }
    }
}