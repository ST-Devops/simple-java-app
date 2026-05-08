package com.example.serverless;

import com.amazonaws.services.lambda.runtime.Context;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

final class JsonLogger {
    private static final ObjectMapper MAPPER = new ObjectMapper();
    private final Context context;
    private final Config config;

    JsonLogger(Context context, Config config) {
        this.context = context;
        this.config = config;
    }

    void info(String message, Map<String, Object> fields) {
        log("INFO", message, fields);
    }

    void error(String message, Throwable throwable, Map<String, Object> fields) {
        Map<String, Object> enriched = new LinkedHashMap<>(fields);
        enriched.put("errorType", throwable.getClass().getSimpleName());
        enriched.put("errorMessage", throwable.getMessage());
        log("ERROR", message, enriched);
    }

    private void log(String level, String message, Map<String, Object> fields) {
        Map<String, Object> event = new LinkedHashMap<>();
        event.put("timestamp", Instant.now().toString());
        event.put("level", level);
        event.put("message", message);
        event.put("environment", config.environment());
        event.put("configuredLogLevel", config.logLevel());
        event.put("awsRequestId", context == null ? "local" : context.getAwsRequestId());
        event.putAll(fields);

        try {
            String line = MAPPER.writeValueAsString(event);
            if (context == null) {
                System.out.println(line);
            } else {
                context.getLogger().log(line + System.lineSeparator());
            }
        } catch (JsonProcessingException e) {
            System.out.println("{\"level\":\"ERROR\",\"message\":\"failed to serialize log\"}");
        }
    }
}
