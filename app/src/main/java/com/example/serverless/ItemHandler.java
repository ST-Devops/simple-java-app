package com.example.serverless;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.Map;

public final class ItemHandler implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
    private static final ObjectMapper MAPPER = new ObjectMapper();

    private final Config config;
    private final ItemRepository repository;

    public ItemHandler() {
        this.config = Config.fromEnv(System.getenv());
        this.repository = new ItemRepository(config);
    }

    ItemHandler(Config config, ItemRepository repository) {
        this.config = config;
        this.repository = repository;
    }

    @Override
    public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent request, Context context) {
        JsonLogger logger = new JsonLogger(context, config);
        String method = request.getHttpMethod();
        String path = request.getPath();

        try {
            logger.info("request received", Map.of("method", method, "path", path));
            APIGatewayProxyResponseEvent response = route(request);
            logger.info("request completed", Map.of("method", method, "path", path, "statusCode", response.getStatusCode()));
            return response;
        } catch (BadRequestException e) {
            logger.info("bad request", Map.of("method", method, "path", path, "reason", e.getMessage()));
            return ApiResponses.json(400, Map.of("message", e.getMessage()));
        } catch (NotFoundException e) {
            return ApiResponses.json(404, Map.of("message", e.getMessage()));
        } catch (Exception e) {
            logger.error("unhandled error", e, Map.of("method", method, "path", path));
            return ApiResponses.json(500, Map.of("message", "internal server error"));
        }
    }

    private APIGatewayProxyResponseEvent route(APIGatewayProxyRequestEvent request) throws Exception {
        String method = request.getHttpMethod();
        String id = pathId(request);

        if ("GET".equals(method) && id == null) {
            return ApiResponses.json(200, Map.of("items", repository.list()));
        }
        if ("POST".equals(method) && id == null) {
            ItemRequest body = parseBody(request);
            return ApiResponses.json(201, repository.create(body));
        }
        if ("GET".equals(method) && id != null) {
            Item item = repository.get(id).orElseThrow(() -> new NotFoundException("item not found"));
            return ApiResponses.json(200, item);
        }
        if ("PUT".equals(method) && id != null) {
            ItemRequest body = parseBody(request);
            return ApiResponses.json(200, repository.update(id, body));
        }
        if ("DELETE".equals(method) && id != null) {
            repository.delete(id);
            return ApiResponses.empty(204);
        }

        return ApiResponses.json(405, Map.of("message", "method not allowed"));
    }

    private ItemRequest parseBody(APIGatewayProxyRequestEvent request) throws Exception {
        if (request.getBody() == null || request.getBody().isBlank()) {
            throw new BadRequestException("request body is required");
        }
        ItemRequest body = MAPPER.readValue(request.getBody(), ItemRequest.class);
        body.validate();
        return body;
    }

    private String pathId(APIGatewayProxyRequestEvent request) {
        Map<String, String> parameters = request.getPathParameters();
        if (parameters == null) {
            return null;
        }
        String id = parameters.get("id");
        if (id != null && id.isBlank()) {
            throw new BadRequestException("id cannot be blank");
        }
        return id;
    }
}
