package com.baeumpay.backend.toucherror.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record TouchErrorLogCreateRequest(
        @NotNull Long missionId,
        @NotNull Long stepId,

        @Size(max = 100)
        String wrongAction
) {}
