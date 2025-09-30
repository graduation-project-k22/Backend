package com.graduation_project.backend.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.Date;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;  // PK

    @Column(unique = true, nullable = false)
    private String username;

    @Column(unique = true)
    private String email;

    private String password;
    private String phone;
    private String salt;

    private String ggId;
    private String fbId;

    private Integer streak = 0;

    @Column(name = "created_at", length = 255)
    @Temporal(TemporalType.TIMESTAMP)
    @CreationTimestamp
    private Date createdAt;

    @Column(name = "updated_at", length = 255)
    @Temporal(TemporalType.TIMESTAMP)
    @UpdateTimestamp
    private Date updatedAt;
    private Instant lastLogin;

    private String role;   // user / admin / moderator
    private String status; // active / inactive / banned

    public static UserBuilder builder() {
        return new UserBuilder();
    }

    public static class UserBuilder {
        private String username;
        private String email;
        private String password;
        private String phone;
        private String salt;
        private String ggId;
        private String fbId;
        private Integer streak = 0;
        private Date createdAt;
        private Date updatedAt;
        private Instant lastLogin;
        private String role;
        private String status;

        public UserBuilder username(String username) { this.username = username; return this; }
        public UserBuilder email(String email) { this.email = email; return this; }
        public UserBuilder password(String password) { this.password = password; return this; }
        public UserBuilder phone(String phone) { this.phone = phone; return this; }
        public UserBuilder salt(String salt) { this.salt = salt; return this; }
        public UserBuilder ggId(String ggId) { this.ggId = ggId; return this; }
        public UserBuilder fbId(String fbId) { this.fbId = fbId; return this; }
        public UserBuilder streak(Integer streak) { this.streak = streak; return this; }
        public UserBuilder createdAt(Date createdAt) { this.createdAt = createdAt; return this; }
        public UserBuilder updatedAt(Date updatedAt) { this.updatedAt = updatedAt; return this; }
        public UserBuilder lastLogin(Instant lastLogin) { this.lastLogin = lastLogin; return this; }
        public UserBuilder role(String role) { this.role = role; return this; }
        public UserBuilder status(String status) { this.status = status; return this; }

        public User build() {
            User user = new User();
            user.setUsername(username);
            user.setEmail(email);
            user.setPassword(password);
            user.setPhone(phone);
            user.setSalt(salt);
            user.setGgId(ggId);
            user.setFbId(fbId);
            user.setStreak(streak);
            user.setCreatedAt(createdAt);
            user.setUpdatedAt(updatedAt);
            user.setLastLogin(lastLogin);
            user.setRole(role);
            user.setStatus(status);
            return user;
        }
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getSalt() {
        return salt;
    }

    public void setSalt(String salt) {
        this.salt = salt;
    }

    public String getGgId() {
        return ggId;
    }

    public void setGgId(String ggId) {
        this.ggId = ggId;
    }

    public String getFbId() {
        return fbId;
    }

    public void setFbId(String fbId) {
        this.fbId = fbId;
    }

    public Integer getStreak() {
        return streak;
    }

    public void setStreak(Integer streak) {
        this.streak = streak;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Instant getLastLogin() {
        return lastLogin;
    }

    public void setLastLogin(Instant lastLogin) {
        this.lastLogin = lastLogin;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}

