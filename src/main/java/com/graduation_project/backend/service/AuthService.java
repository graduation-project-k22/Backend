package com.graduation_project.backend.service;

import com.graduation_project.backend.dto.auth.LoginRequest;
import com.graduation_project.backend.dto.auth.RegisterRequest;
import com.graduation_project.backend.dto.auth.TokenResponse;
import com.graduation_project.backend.dto.auth.UserResponse;
import com.graduation_project.backend.entity.User;

public interface AuthService {
    UserResponse register(RegisterRequest req);
    TokenResponse login(LoginRequest req);
    public TokenResponse refreshToken(String refreshToken);
}
