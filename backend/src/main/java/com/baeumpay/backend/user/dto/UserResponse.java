package com.baeumpay.backend.user.dto;

import com.baeumpay.backend.user.entity.User;
import com.baeumpay.backend.user.entity.UserType;

import java.time.LocalDateTime;

public record UserResponse(
        Long userId,
        String name,
        String phone,
        Integer birthYear,
        UserType userType,
        LocalDateTime createdAt
) {
    public static UserResponse from(User user) {
        return new UserResponse(
                user.getUserId(),
                user.getName(),
                user.getPhone(),
                user.getBirthYear(),
                user.getUserType(),
                user.getCreatedAt()
        );
    }
}
