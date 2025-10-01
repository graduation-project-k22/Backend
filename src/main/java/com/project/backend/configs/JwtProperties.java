package com.project.backend.configs;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "jwt")
public class JwtProperties {
    private String secret;
    private long accessExp;
    private long refreshExp;

    public String getSecret() {
        return secret;
    }

    public void setSecret(String secret) {
        this.secret = secret;
    }

    public long getAccessExp() {
        return accessExp;
    }

    public void setAccessExp(long accessExp) {
        this.accessExp = accessExp;
    }

    public long getRefreshExp() {
        return refreshExp;
    }

    public void setRefreshExp(long refreshExp) {
        this.refreshExp = refreshExp;
    }
}
