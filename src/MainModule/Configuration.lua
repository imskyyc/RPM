return {
    framework = { --// Framework behavior configuration
        debug = false, --// Determines if extra debug info will be printed to the console

        error_handling = {
            output_to_console = true, --// Determines if errors will be output to the console

            mode = "rpm", --// Supports built in RPM error logging with panel, or sentry

            rpm_api_key = "", --// Your RPM Panel API Key
            sentry_dsn = "" --// Sentry DSN for sentry logging
        }
    }
}