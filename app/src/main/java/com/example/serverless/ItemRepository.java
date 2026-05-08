package com.example.serverless;

import software.amazon.awssdk.core.client.config.ClientOverrideConfiguration;
import software.amazon.awssdk.core.retry.RetryMode;
import software.amazon.awssdk.core.retry.RetryPolicy;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.DeleteItemRequest;
import software.amazon.awssdk.services.dynamodb.model.GetItemRequest;
import software.amazon.awssdk.services.dynamodb.model.PutItemRequest;
import software.amazon.awssdk.services.dynamodb.model.QueryRequest;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

final class ItemRepository {
    private static final String PARTITION_KEY = "ITEM";

    private final DynamoDbClient dynamoDb;
    private final String tableName;

    ItemRepository(Config config) {
        this(DynamoDbClient.builder()
                .overrideConfiguration(ClientOverrideConfiguration.builder()
                        .apiCallAttemptTimeout(Duration.ofSeconds(3))
                        .apiCallTimeout(Duration.ofSeconds(8))
                        .retryPolicy(RetryPolicy.forRetryMode(RetryMode.STANDARD))
                        .build())
                .build(), config.tableName());
    }

    ItemRepository(DynamoDbClient dynamoDb, String tableName) {
        this.dynamoDb = dynamoDb;
        this.tableName = tableName;
    }

    Item create(ItemRequest request) {
        Instant now = Instant.now();
        Item item = new Item(UUID.randomUUID().toString(), request.name(), request.description(), defaultStatus(request.status()), now, now);
        put(item);
        return item;
    }

    List<Item> list() {
        QueryRequest request = QueryRequest.builder()
                .tableName(tableName)
                .keyConditionExpression("pk = :pk")
                .expressionAttributeValues(Map.of(":pk", string(PARTITION_KEY)))
                .limit(100)
                .build();

        return dynamoDb.query(request).items().stream().map(this::fromItem).toList();
    }

    Optional<Item> get(String id) {
        Map<String, AttributeValue> item = dynamoDb.getItem(GetItemRequest.builder()
                .tableName(tableName)
                .key(key(id))
                .consistentRead(true)
                .build()).item();

        return item == null || item.isEmpty() ? Optional.empty() : Optional.of(fromItem(item));
    }

    Item update(String id, ItemRequest request) {
        Item existing = get(id).orElseThrow(() -> new NotFoundException("item not found"));
        Item updated = new Item(
                existing.id(),
                request.name(),
                request.description(),
                defaultStatus(request.status()),
                existing.createdAt(),
                Instant.now()
        );
        put(updated);
        return updated;
    }

    void delete(String id) {
        get(id).orElseThrow(() -> new NotFoundException("item not found"));
        dynamoDb.deleteItem(DeleteItemRequest.builder()
                .tableName(tableName)
                .key(key(id))
                .build());
    }

    private void put(Item item) {
        dynamoDb.putItem(PutItemRequest.builder()
                .tableName(tableName)
                .item(toItem(item))
                .build());
    }

    private Map<String, AttributeValue> key(String id) {
        return Map.of("pk", string(PARTITION_KEY), "sk", string(id));
    }

    private Map<String, AttributeValue> toItem(Item item) {
        return Map.of(
                "pk", string(PARTITION_KEY),
                "sk", string(item.id()),
                "id", string(item.id()),
                "name", string(item.name()),
                "description", string(item.description() == null ? "" : item.description()),
                "status", string(item.status()),
                "createdAt", string(item.createdAt().toString()),
                "updatedAt", string(item.updatedAt().toString())
        );
    }

    private Item fromItem(Map<String, AttributeValue> item) {
        return new Item(
                item.get("id").s(),
                item.get("name").s(),
                item.get("description").s(),
                item.get("status").s(),
                Instant.parse(item.get("createdAt").s()),
                Instant.parse(item.get("updatedAt").s())
        );
    }

    private static AttributeValue string(String value) {
        return AttributeValue.builder().s(value).build();
    }

    private static String defaultStatus(String status) {
        return status == null || status.isBlank() ? "ACTIVE" : status;
    }
}
