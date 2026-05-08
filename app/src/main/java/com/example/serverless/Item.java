package com.example.serverless;

import java.time.Instant;

public record Item(
        String id,
        String name,
        String description,
        String status,
        Instant createdAt,
        Instant updatedAt
) {
}
