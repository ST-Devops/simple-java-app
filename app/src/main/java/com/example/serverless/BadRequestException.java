package com.example.serverless;

final class BadRequestException extends RuntimeException {
    BadRequestException(String message) {
        super(message);
    }
}
