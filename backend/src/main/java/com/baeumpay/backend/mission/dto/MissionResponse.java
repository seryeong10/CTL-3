package com.baeumpay.backend.mission.dto;

import com.baeumpay.backend.mission.entity.Mission;
import com.baeumpay.backend.mission.entity.MissionDifficulty;

import java.time.LocalDateTime;

public record MissionResponse(
        Long missionId,
        String title,
        String description,
        String category,
        MissionDifficulty difficulty,
        Long rewardPoint,
        boolean active,
        LocalDateTime createdAt
) {
    public static MissionResponse from(Mission mission) {
        return new MissionResponse(
                mission.getMissionId(),
                mission.getTitle(),
                mission.getDescription(),
                mission.getCategory(),
                mission.getDifficulty(),
                mission.getRewardPoint(),
                mission.isActive(),
                mission.getCreatedAt()
        );
    }
}
