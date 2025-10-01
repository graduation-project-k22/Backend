package com.project.backend.configs;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Base64;
import java.util.Date;
import org.springframework.stereotype.Component;

@Component
public class JwtUtil {
    private final Key key;
    private final long accessTokenExp;
    private final long refreshTokenExp;

    public JwtUtil(JwtProperties props) {
        String secret = props.getSecret();
        if (secret == null || secret.isBlank()) {
            throw new IllegalStateException(
                "JWT secret is not configured. Set JWT_SECRET env or configure jwt.secret in application.yml");
        }

        // Convert secret: try decode base64, otherwise use raw utf-8 bytes
        byte[] keyBytes;
        try {
            keyBytes = Base64.getDecoder().decode(secret);
            // if decode returns something small or fails, we'll still check below
        } catch (IllegalArgumentException ex) {
            keyBytes = secret.getBytes(StandardCharsets.UTF_8);
        }

        // Build Key (Keys.hmacShaKeyFor will validate key length and throw if too short)
        this.key = Keys.hmacShaKeyFor(keyBytes);

        this.accessTokenExp = props.getAccessExp();
        this.refreshTokenExp = props.getRefreshExp();
    }

    public String generateAccessToken(String username, String role) {
        return Jwts.builder()
            .setSubject(username)
            .claim("role", role)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + accessTokenExp))
            .signWith(key)
            .compact();
    }

    public String generateRefreshToken(String username, String role) {
        return Jwts.builder()
            .setSubject(username)
            .claim("role", role)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + refreshTokenExp))
            .signWith(key)
            .compact();
    }

    public String extractUsername(String token) {
        return Jwts.parserBuilder()
            .setSigningKey(key)
            .build()
            .parseClaimsJws(token)
            .getBody()
            .getSubject();
    }

    public Claims parseToken(String token) {
        return Jwts.parserBuilder()
            .setSigningKey(key)
            .build()
            .parseClaimsJws(token)
            .getBody();
    }
}
