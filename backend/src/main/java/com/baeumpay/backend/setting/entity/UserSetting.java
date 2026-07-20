package com.baeumpay.backend.setting.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_setting")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserSetting {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long settingId;

    @Column(nullable = false, unique = true)
    private Long userId;

    @Column(nullable = false)
    private Boolean notificationEnabled;

    @Column(nullable = false)
    private Boolean largeTextEnabled;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    public UserSetting(Long userId) {
        this.userId = userId;
        this.notificationEnabled = true;
        this.largeTextEnabled = false;
        this.updatedAt = LocalDateTime.now();
    }

    public void update(
            Boolean notificationEnabled,
            Boolean largeTextEnabled
    ) {

        this.notificationEnabled = notificationEnabled;
        this.largeTextEnabled = largeTextEnabled;
        this.updatedAt = LocalDateTime.now();
    }
}