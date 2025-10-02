package com.project.backend.dto.auth;

import com.project.backend.entity.User;
import java.time.Instant;
import java.util.Date;
import lombok.Data;

@Data
public class UserResponse {
    private Long id;
    private String username;
    private String email;
    private String phone;
    private Integer streak;
    private Date createdAt;
    private Date updatedAt;
    private Instant lastLogin;
    private String role;
    private String status;

    public static UserResponse fromEntity(User user) {
        UserResponse userResponse = new UserResponse();
        userResponse.setId(user.getId());
        userResponse.setUsername(user.getUsername());
        userResponse.setEmail(user.getEmail());
        userResponse.setPhone(user.getPhone());
        userResponse.setStreak(user.getStreak());
        userResponse.setCreatedAt(user.getCreatedAt());
        userResponse.setUpdatedAt(user.getUpdatedAt());
        userResponse.setLastLogin(user.getLastLogin());
        userResponse.setRole(user.getRole().toString());
        userResponse.setStatus(user.getStatus());
        return userResponse;
    }
}
