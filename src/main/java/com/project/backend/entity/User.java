package com.project.backend.entity;

import com.project.backend.enums.ERole;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
import java.time.Instant;
import java.util.Date;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Data
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

    private ERole role;   // user / admin / moderator
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
        private ERole role;
        private String status;

        public UserBuilder username(String username) {
            this.username = username;
            return this;
        }

        public UserBuilder email(String email) {
            this.email = email;
            return this;
        }

        public UserBuilder password(String password) {
            this.password = password;
            return this;
        }

        public UserBuilder phone(String phone) {
            this.phone = phone;
            return this;
        }

        public UserBuilder salt(String salt) {
            this.salt = salt;
            return this;
        }

        public UserBuilder ggId(String ggId) {
            this.ggId = ggId;
            return this;
        }

        public UserBuilder fbId(String fbId) {
            this.fbId = fbId;
            return this;
        }

        public UserBuilder streak(Integer streak) {
            this.streak = streak;
            return this;
        }

        public UserBuilder createdAt(Date createdAt) {
            this.createdAt = createdAt;
            return this;
        }

        public UserBuilder updatedAt(Date updatedAt) {
            this.updatedAt = updatedAt;
            return this;
        }

        public UserBuilder lastLogin(Instant lastLogin) {
            this.lastLogin = lastLogin;
            return this;
        }

        public UserBuilder role(ERole role) {
            this.role = role;
            return this;
        }

        public UserBuilder status(String status) {
            this.status = status;
            return this;
        }

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
}

