package com.project.backend.service;

import com.project.backend.dto.auth.LoginRequest;
import com.project.backend.dto.auth.RegisterRequest;
import com.project.backend.dto.auth.TokenResponse;
import com.project.backend.dto.auth.UserResponse;

public interface AuthService {
    UserResponse register(RegisterRequest req);

    TokenResponse login(LoginRequest req);

    public TokenResponse refreshToken(String refreshToken);
}
