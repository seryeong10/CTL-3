package com.baeumpay.backend.mission.dto;

import com.baeumpay.backend.mission.entity.MissionLogStatus;
import jakarta.validation.constraints.NotNull;

public record MissionLogCreateRequest(
        @NotNull
        Long missionId,

        MissionLogStatus status,

        Integer score
) {
}
