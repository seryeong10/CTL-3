package com.baeumpay.backend.guardian.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record GuardianLinkCreateRequest(
        @NotNull Long seniorUserId,

        @Size(max = 50)
        String relation
) {}
