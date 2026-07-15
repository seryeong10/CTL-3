package com.baeumpay.backend.user.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long userId;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(length = 20, unique = true)
    private String phone;

    private Integer birthYear;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private UserType userType;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    public User(String name, String phone, Integer birthYear, UserType userType) {
        this.name = name;
        this.phone = phone;
        this.birthYear = birthYear;
        this.userType = userType;
        this.createdAt = LocalDateTime.now();
    }
}
