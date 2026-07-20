package com.baeumpay.backend.user.dto;

import com.baeumpay.backend.user.entity.UserType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record UserCreateRequest(
        @NotBlank @Size(max = 50)
        String name,

        @Size(max = 20)
        String phone,

        Integer birthYear,

        @NotNull
        UserType userType
) {
}
