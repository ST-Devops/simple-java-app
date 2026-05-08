package com.example.serverless;

public record ItemRequest(String name, String description, String status) {
    void validate() {
        if (name == null || name.isBlank() || name.length() > 120) {
            throw new BadRequestException("name is required and must be 1-120 characters");
        }
        if (description != null && description.length() > 500) {
            throw new BadRequestException("description must be 500 characters or fewer");
        }
        if (status != null && !status.equals("ACTIVE") && !status.equals("ARCHIVED")) {
            throw new BadRequestException("status must be ACTIVE or ARCHIVED");
        }
    }
}
