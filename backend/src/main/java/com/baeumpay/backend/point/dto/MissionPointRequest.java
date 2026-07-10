package com.baeumpay.backend.point.dto;

import jakarta.validation.constraints.NotNull;

public record MissionPointRequest(

        @NotNull
        Long missionId,

        @NotNull
        MissionDifficulty difficulty

) {
}