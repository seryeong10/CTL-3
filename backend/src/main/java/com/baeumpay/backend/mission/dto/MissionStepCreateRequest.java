package com.baeumpay.backend.mission.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record MissionStepCreateRequest(
        @NotNull
        Integer stepOrder,

        @NotBlank
        String instructionText,

        @Size(max = 100)
        String correctAction,

        String voiceGuideText
) {
}
