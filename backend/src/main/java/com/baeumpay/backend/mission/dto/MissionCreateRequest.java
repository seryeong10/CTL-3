package com.baeumpay.backend.mission.dto;

import com.baeumpay.backend.mission.entity.MissionDifficulty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record MissionCreateRequest(
        @NotBlank @Size(max = 100)
        String title,

        String description,

        @Size(max = 50)
        String category,

        @NotNull
        MissionDifficulty difficulty,

        Long rewardPoint
) {
}
