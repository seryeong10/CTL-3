package com.baeumpay.backend.mission.dto;

import com.baeumpay.backend.mission.entity.Mission;
import com.baeumpay.backend.mission.entity.MissionStep;

import java.time.LocalDateTime;
import java.util.List;

public record MissionDetailResponse(
        Long missionId,
        String title,
        String description,
        String category,
        String difficulty,
        Long rewardPoint,
        LocalDateTime createdAt,
        List<MissionStepResponse> steps
) {
    public static MissionDetailResponse from(Mission mission, List<MissionStep> steps) {
        return new MissionDetailResponse(
                mission.getMissionId(),
                mission.getTitle(),
                mission.getDescription(),
                mission.getCategory(),
                mission.getDifficulty().name(),
                mission.getRewardPoint(),
                mission.getCreatedAt(),
                steps.stream().map(MissionStepResponse::from).toList()
        );
    }
}
