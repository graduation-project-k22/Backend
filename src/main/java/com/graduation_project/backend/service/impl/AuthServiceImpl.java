package com.graduation_project.backend.service.impl;

import com.graduation_project.backend.configs.JwtUtil;
import com.graduation_project.backend.dto.auth.LoginRequest;
import com.graduation_project.backend.dto.auth.RegisterRequest;
import com.graduation_project.backend.dto.auth.TokenResponse;
import com.graduation_project.backend.dto.auth.UserResponse;
import com.graduation_project.backend.entity.User;
import com.graduation_project.backend.repository.UserRepository;
import com.graduation_project.backend.service.AuthService;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;

@Service
public class AuthServiceImpl implements AuthService {
    private final UserRepository userRepo;
    private final PasswordEncoder encoder;
    private final JwtUtil jwtUtil;

    public AuthServiceImpl(UserRepository userRepo, PasswordEncoder encoder, JwtUtil jwtUtil) {
        this.userRepo = userRepo;
        this.encoder = encoder;
        this.jwtUtil = jwtUtil;
    }

    public UserResponse register(RegisterRequest req) {
        if (userRepo.findByUsername(req.getUsername()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Username already exists");
        }
        if (userRepo.findByEmail(req.getEmail()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email already exists");
        }
        User user = User.builder()
                .username(req.getUsername())
                .email(req.getEmail())
                .phone(req.getPhone())
                .password(encoder.encode(req.getPassword()))
                .role("USER")
                .status("ACTIVE")
                .build();
        user = userRepo.save(user);
        UserResponse userResponse = UserResponse.fromEntity(user);
        return userResponse;
    }

    public TokenResponse login(LoginRequest req) {
        User user = userRepo.findByUsername(req.getUsername())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid username or password"));

        if (!encoder.matches(req.getPassword(), user.getPassword())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid username or password");
        }

        String accessToken = jwtUtil.generateAccessToken(user.getUsername(), user.getRole());
        String refreshToken = jwtUtil.generateRefreshToken(user.getUsername(), user.getRole());

        user.setLastLogin(Instant.now());
        userRepo.save(user);

        return new TokenResponse(accessToken, refreshToken);
    }

    public TokenResponse refreshToken(String refreshToken) {
        try {
            Claims claims = jwtUtil.parseToken(refreshToken);
            String username = claims.getSubject();
            String role = claims.get("role", String.class);

            String newAccess = jwtUtil.generateAccessToken(username, role);
            String newRefresh = jwtUtil.generateRefreshToken(username, role);

            return new TokenResponse(newAccess, newRefresh);
        } catch (ExpiredJwtException ex) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Refresh token expired");
        } catch (Exception ex) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid refresh token");
        }
    }
}
