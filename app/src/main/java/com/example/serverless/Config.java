package com.example.serverless;

import java.util.Map;

final class Config {
    private final String tableName;
    private final String environment;
    private final String logLevel;

    private Config(String tableName, String environment, String logLevel) {
        this.tableName = tableName;
        this.environment = environment;
        this.logLevel = logLevel;
    }

    static Config fromEnv(Map<String, String> env) {
        return new Config(required(env, "TABLE_NAME"), env.getOrDefault("ENVIRONMENT", "local"), env.getOrDefault("LOG_LEVEL", "INFO"));
    }

    String tableName() {
        return tableName;
    }

    String environment() {
        return environment;
    }

    String logLevel() {
        return logLevel;
    }

    private static String required(Map<String, String> env, String name) {
        String value = env.get(name);
        if (value == null || value.isBlank()) {
            throw new IllegalStateException("Missing required environment variable: " + name);
        }
        return value;
    }
}
