package com.baeumpay.backend.mission.dto;

import com.baeumpay.backend.mission.entity.MissionLog;
import com.baeumpay.backend.mission.entity.MissionLogStatus;

import java.time.LocalDateTime;

public record MissionLogResponse(
        Long logId,
        Long userId,
        Long missionId,
        MissionLogStatus status,
        Integer score,
        LocalDateTime completedAt,
        boolean pointRewarded,
        String message
) {
    public static MissionLogResponse from(MissionLog log, String message) {
        return new MissionLogResponse(
                log.getLogId(),
                log.getUserId(),
                log.getMissionId(),
                log.getStatus(),
                log.getScore(),
                log.getCompletedAt(),
                log.isPointRewarded(),
                message
        );
    }
}
