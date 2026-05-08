package com.example.serverless;

final class NotFoundException extends RuntimeException {
    NotFoundException(String message) {
        super(message);
    }
}
