package com.example.serverless;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;

class ItemRequestTest {
    @Test
    void acceptsValidRequest() {
        assertDoesNotThrow(() -> new ItemRequest("demo", "description", "ACTIVE").validate());
    }

    @Test
    void rejectsBlankName() {
        assertThrows(BadRequestException.class, () -> new ItemRequest(" ", "description", "ACTIVE").validate());
    }

    @Test
    void rejectsUnknownStatus() {
        assertThrows(BadRequestException.class, () -> new ItemRequest("demo", "description", "PENDING").validate());
    }
}
