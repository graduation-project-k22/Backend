package com.project.backend.controller;

import com.project.backend.dto.auth.LoginRequest;
import com.project.backend.dto.auth.RefreshTokenRequest;
import com.project.backend.dto.auth.RegisterRequest;
import com.project.backend.dto.auth.TokenResponse;
import com.project.backend.dto.auth.UserResponse;
import com.project.backend.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication", description = "APIs for user registration, login and token refresh")
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @Operation(summary = "Register a new user",
        description = "Creates a new user account with the provided information")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Registration successful",
            content = @Content(mediaType = "application/json",
                schema = @Schema(implementation = UserResponse.class))),
        @ApiResponse(responseCode = "409", description = "Conflict - Username or email already exists",
            content = @Content)
    })
    @PostMapping("/register")
    public ResponseEntity<?> register(
        @io.swagger.v3.oas.annotations.parameters.RequestBody(
            description = "User registration details",
            required = true,
            content = @Content(mediaType = "application/json",
                schema = @Schema(implementation = RegisterRequest.class))
        )
        @Valid @RequestBody RegisterRequest req) {
        Map<String, Object> response = new HashMap<>();
        try {
            UserResponse user = authService.register(req);
            response.put("message", "Register success");
            response.put("data", user);
            return ResponseEntity.ok(response);
        } catch (ResponseStatusException e) {
            response.put("message", e.getReason());
            response.put("data", null);
            return ResponseEntity.status(e.getStatusCode()).body(response);
        }
    }

    @Operation(summary = "Login a user", description = "Authenticates a user and returns access & refresh tokens")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Login successful",
            content = @Content(mediaType = "application/json",
                schema = @Schema(implementation = TokenResponse.class))),
        @ApiResponse(responseCode = "401", description = "Invalid credentials",
            content = @Content)
    })
    @PostMapping("/login")
    public ResponseEntity<?> login(
        @io.swagger.v3.oas.annotations.parameters.RequestBody(
            description = "Login credentials",
            required = true,
            content = @Content(mediaType = "application/json",
                schema = @Schema(implementation = LoginRequest.class))
        )
        @Valid @RequestBody LoginRequest req) {
        Map<String, Object> response = new HashMap<>();
        try {
            TokenResponse data = authService.login(req);
            response.put("message", "Login success");
            response.put("data", data);
            return ResponseEntity.ok(response);
        } catch (ResponseStatusException e) {
            response.put("message", e.getReason());
            response.put("data", null);
            return ResponseEntity.status(e.getStatusCode()).body(response);
        }
    }

    @Operation(summary = "Refresh JWT token", description = "Refreshes access token using a valid refresh token")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Token refreshed successfully",
            content = @Content(mediaType = "application/json",
                schema = @Schema(implementation = TokenResponse.class))),
        @ApiResponse(responseCode = "401", description = "Invalid or expired refresh token",
            content = @Content)
    })
    @PostMapping("/refresh-token")
    public ResponseEntity<?> refreshToken(
        @io.swagger.v3.oas.annotations.parameters.RequestBody(
            description = "Refresh token request",
            required = true,
            content = @Content(mediaType = "application/json",
                schema = @Schema(implementation = RefreshTokenRequest.class))
        )
        @Valid @RequestBody RefreshTokenRequest request) {
        TokenResponse tokens = authService.refreshToken(request.getRefreshToken());
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Token refreshed successfully");
        response.put("data", tokens);
        return ResponseEntity.ok(response);
    }
}
