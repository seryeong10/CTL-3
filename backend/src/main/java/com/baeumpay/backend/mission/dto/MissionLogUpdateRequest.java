package com.baeumpay.backend.mission.dto;

import com.baeumpay.backend.mission.entity.MissionLogStatus;
import jakarta.validation.constraints.NotNull;

public record MissionLogUpdateRequest(
        @NotNull
        MissionLogStatus status,

        Integer score
) {
}
