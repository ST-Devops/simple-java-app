package com.example.serverless;

import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import java.util.Map;

final class ApiResponses {
    private static final ObjectMapper MAPPER = new ObjectMapper().registerModule(new JavaTimeModule());
    private static final Map<String, String> JSON_HEADERS = Map.of(
            "Content-Type", "application/json",
            "Cache-Control", "no-store"
    );

    private ApiResponses() {
    }

    static APIGatewayProxyResponseEvent json(int statusCode, Object body) {
        return new APIGatewayProxyResponseEvent()
                .withStatusCode(statusCode)
                .withHeaders(JSON_HEADERS)
                .withBody(toJson(body));
    }

    static APIGatewayProxyResponseEvent empty(int statusCode) {
        return new APIGatewayProxyResponseEvent()
                .withStatusCode(statusCode)
                .withHeaders(JSON_HEADERS)
                .withBody("");
    }

    private static String toJson(Object body) {
        try {
            return MAPPER.writeValueAsString(body);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Failed to serialize response", e);
        }
    }
}
